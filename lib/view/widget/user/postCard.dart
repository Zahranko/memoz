import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:memzoProject/view/screen/user/CommentsBottomSheet.dart';
import 'package:memzoProject/view/widget/user/PickDriverPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/view/screen/user/otherProfileView.dart';
import 'package:memzoProject/view/screen/user/ProfilePageView.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:memzoProject/view/widget/user/AudioCommentBubble.dart'; // 1. Import your Audio Bubble

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback? onPostTap;

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  PostCard({Key? key, required this.post, required this.onLike, this.onPostTap})
    : super(key: key);

  Future<void> _openMap() async {
    if (post.locationName.isEmpty) return;
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(post.locationName)}",
    );
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to open map: $e");
    }
  }

  void _sharePost() {
    final String shareText =
        "Check out this memo by ${post.userName} on our App!\n\n"
        "${post.caption}\n\n"
        "Link: https://tadreebkom.app/post/${post.id}";
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the dynamic parts in a StreamBuilder listening to the specific post document
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('posts')
              .doc(post.id)
              .snapshots(),
      builder: (context, snapshot) {
        // Use the live data if available, otherwise fallback to the initial 'post' object
        var liveData = snapshot.data?.data() as Map<String, dynamic>?;

        // Get live counts
        int liveCommentCount = liveData?['comments'] ?? post.commentCount;
        List<dynamic> liveLikes = liveData?['likes'] ?? post.likes;

        // 2. Get Audio URL (Check both live data and initial model)
        String? audioUrl = liveData?['audioUrl'] ?? post.audioUrl;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (User Info)
              _buildUserInfo(),

              const SizedBox(height: 16),

              // 2. Content
              GestureDetector(
                onTap: onPostTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationRow(),
                    const SizedBox(height: 12),
                    _buildImageCarousel(),

                    // 3. Render Audio Player if URL exists
                    if (audioUrl != null && audioUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildAudioPlayer(audioUrl),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // 3. Action Bar (Pass live data here)
              _buildActionBar(context, liveLikes, liveCommentCount),

              const SizedBox(height: 12),

              // 4. Caption
              GestureDetector(onTap: onPostTap, child: _buildCaption()),

              const SizedBox(height: 8),

              // 5. Comments Link (Pass live data here)
              GestureDetector(
                onTap: () => _openComments(),
                child: Text(
                  _getCommentText(liveCommentCount),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfo() {
    if (post.userName != 'Unknown' &&
        post.userName.isNotEmpty &&
        post.userName != 'Unknown User' &&
        post.userAvatar.startsWith('http')) {
      return _userHeaderLayout(
        name: post.userName,
        image: post.userAvatar,
        feeling: post.feeling,
        timestamp: post.createdAt,
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(post.userId).get(),
      builder: (context, snapshot) {
        String displayImg = "";
        String displayName = "Loading...";

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          displayName = data['username'] ?? '';
          if (displayName.isEmpty) {
            displayName =
                "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
          }
          if (displayName.isEmpty) displayName = "Unknown User";

          displayImg = data['userAvatar'] ?? data['profilePic'] ?? '';
        } else if (snapshot.connectionState == ConnectionState.done) {
          displayName = "Unknown User";
        }

        return _userHeaderLayout(
          name: displayName,
          image: displayImg,
          feeling: post.feeling,
          timestamp: post.createdAt,
        );
      },
    );
  }

  Widget _userHeaderLayout({
    required String name,
    required String image,
    required String feeling,
    required DateTime? timestamp,
  }) {
    String timeString = "Just now";
    if (timestamp != null) {
      String rawTime = timeago.format(timestamp, locale: 'en_short');
      timeString = rawTime == "now" ? "Just now" : "$rawTime ago";
    }

    return GestureDetector(
      onTap: () {
        if (post.userId == currentUserId) {
          Get.to(() => ProfileView());
        } else {
          Get.to(() => OtherUserProfileView(targetUserId: post.userId));
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  (image.isNotEmpty && image.startsWith('http'))
                      ? NetworkImage(image)
                      : const NetworkImage(
                        "https://miro.medium.com/v2/resize:fit:1080/1*8ATQ6ycC0MkZo4DKMUuGnw.png",
                      ),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeString,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const Spacer(),

            if (feeling.isNotEmpty) _buildStatusTag(feeling),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text) {
    return Row(
      children: [
        const Text(
          "Feeling:",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 2),
        Container(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    if (post.locationName.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Existing Location Logic (Wrapped in Map Open)
        Expanded(
          child: GestureDetector(
            onTap: _openMap,
            child: Container(
              color: Colors.transparent, // expand hit test area
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.brown,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      post.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.brown,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. NEW: Car Icon Button
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.brown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Navigate to the Driver Page
              Get.to(() => PickDriverPage(location: post.locationName));
            },
            child: Row(
              children: const [
                Icon(
                  Icons.directions_car_filled,
                  color: Colors.brown,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  "Ride",
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    if (post.images.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: post.images.length,
            itemBuilder: (context, imgIndex) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    post.images[imgIndex],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, o, s) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                  ),
                ),
              );
            },
          ),
        ),
        if (post.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(post.images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // --- 4. NEW: Audio Player Widget Helper ---
  Widget _buildAudioPlayer(String audioUrl) {
    // Reuse the AudioCommentBubble but styled for the post body
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.graphic_eq,
            color: Colors.brown,
          ), // Icon to indicate audio
          const SizedBox(width: 10),
          Expanded(
            // We reuse the bubble logic. 'isMe: true' gives it the darker style,
            // 'isMe: false' gives it light style. Pick what fits your design.
            child: AudioCommentBubble(audioUrl: audioUrl, isMe: true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(
    BuildContext context,
    List<dynamic> likes,
    int commentCount,
  ) {
    final bool isLiked = likes.contains(currentUserId);
    return Row(
      children: [
        GestureDetector(
          onTap: onLike,
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.brown,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '${likes.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        GestureDetector(
          onTap: () => _openComments(),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.brown,
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                '$commentCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        GestureDetector(
          onTap: _sharePost,
          child: const Icon(Icons.send_outlined, color: Colors.brown, size: 26),
        ),
      ],
    );
  }

  Widget _buildCaption() {
    if (post.caption.isEmpty) return const SizedBox.shrink();
    return Text(
      post.caption,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF2D2D2D),
        height: 1.4,
      ),
    );
  }

  String _getCommentText(int count) {
    if (count == 0) {
      return "Add a comment...";
    } else if (count == 1) {
      return "View 1 comment";
    } else {
      return "View all $count comments";
    }
  }

  void _openComments() {
    Get.bottomSheet(
      CommentsBottomSheet(
        postId: post.id,
        postOwnerId: post.userId,
        postImage: post.images.isNotEmpty ? post.images.first : null,
      ),
      isScrollControlled: true,
    );
  }
}
