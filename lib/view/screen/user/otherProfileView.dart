import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/otherProfileController.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/view/screen/user/followListView.dart';
import 'package:memzoProject/view/screen/user/memoDetailView.dart';

class OtherUserProfileView extends StatefulWidget {
  final String targetUserId;

  const OtherUserProfileView({Key? key, required this.targetUserId})
    : super(key: key);

  @override
  State<OtherUserProfileView> createState() => _OtherUserProfileViewState();
}

class _OtherUserProfileViewState extends State<OtherUserProfileView> {
  // Inject the controller
  final OtherProfileController controller = Get.put(OtherProfileController());

  @override
  void initState() {
    super.initState();
    // Load the specific user's data when page opens
    controller.loadUserProfile(widget.targetUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.pagePrimaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.username.value.isNotEmpty
                ? controller.username.value
                : "User Profile",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildCenteredHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 25)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Memos",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              _buildPostsGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCenteredHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // 1. Avatar
        Obx(() {
          String picUrl = controller.profilePic.value;
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.buttonColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  (picUrl.isNotEmpty)
                      ? NetworkImage(picUrl)
                      : const NetworkImage(
                            "https://miro.medium.com/v2/resize:fit:1080/1*8ATQ6ycC0MkZo4DKMUuGnw.png",
                          )
                          as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
          );
        }),

        const SizedBox(height: 16),

        // 2. Name and Handle
        Obx(
          () => Column(
            children: [
              if (controller.fullName.value.isNotEmpty)
                Text(
                  controller.fullName.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              Text(
                "@${controller.username.value.isNotEmpty ? controller.username.value : 'user'}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 3. Bio
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              controller.bio.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 4. Stats Box
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5C5470).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => _buildStatItem(
                  controller.postCount.value,
                  "Memos",
                  onTap: () {},
                ),
              ),

              Container(width: 1, height: 30, color: Colors.grey[200]),

              // Followers
              Obx(
                () => _buildStatItem(
                  controller.followers.value,
                  "Followers",
                  onTap: () {
                    if (controller.followers.value > 0) {
                      Get.to(
                        () => FollowListView(
                          userId: widget.targetUserId, // Use the target user ID
                          title: "Followers",
                          collectionName: "followers",
                        ),
                      );
                    }
                  },
                ),
              ),

              Container(width: 1, height: 30, color: Colors.grey[200]),

              // Following
              Obx(
                () => _buildStatItem(
                  controller.following.value,
                  "Following",
                  onTap: () {
                    if (controller.following.value > 0) {
                      Get.to(
                        () => FollowListView(
                          userId: widget.targetUserId, // Use the target user ID
                          title: "Following",
                          collectionName: "following",
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 5. Action Buttons (Message & Follow)
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- FOLLOW BUTTON ---
        Obx(() {
          bool isFollowing = controller.isFollowing.value;
          return ElevatedButton(
            onPressed: () {
              controller.toggleFollow(widget.targetUserId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isFollowing ? Colors.white : AppColor.buttonColor,
              foregroundColor: isFollowing ? Colors.black : Colors.white,
              side:
                  isFollowing
                      ? BorderSide(color: Colors.grey[300]!)
                      : BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              elevation: isFollowing ? 0 : 2,
            ),
            child: Text(
              isFollowing ? "Following" : "Follow",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }),

        const SizedBox(width: 12),

        // --- MESSAGE BUTTON (UPDATED) ---
        OutlinedButton(
          onPressed: () {
            // CALL THE NEW METHOD IN CONTROLLER
            controller.startChatWithUser(widget.targetUserId);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Icon(
            Icons.mail_outline,
            size: 20,
            color: AppColor.buttonColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    int count,
    String label, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Text(
              "$count",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5C5470),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    return Obx(() {
      if (controller.userPosts.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text("No Memos shared yet"),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final PostModel post = controller.userPosts[index];
            String? imageUrl =
                post.images.isNotEmpty ? post.images.first : null;

            return GestureDetector(
              onTap: () {
                Get.to(
                  () => MemoDetailView(
                    initialPost: post,
                    sourceList: controller.userPosts,
                    onToggleLike: (id) => controller.toggleLike(id),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (c, o, s) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
              ),
            );
          }, childCount: controller.userPosts.length),
        ),
      );
    });
  }
}
