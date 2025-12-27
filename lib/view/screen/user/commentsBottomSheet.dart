import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/commentsController.dart';
import 'package:memzoProject/view/screen/user/reportPage.dart';
import 'package:memzoProject/view/widget/user/AudioCommentBubble.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsBottomSheet extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final String? postImage;

  const CommentsBottomSheet({
    Key? key,
    required this.postId,
    required this.postOwnerId,
    this.postImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- 1. FIXED INITIALIZATION ---
    // We use the variables defined at the top of this class (postId, postImage)
    final CommentsController controller = Get.put(
      CommentsController(
        postId: postId,                 // Fixed: was 'currentPostId'
        postOwnerId: postOwnerId,
        postImageUrl: postImage ?? '',  // Fixed: was 'postImageUrl', added ?? '' for null safety
      ),
      tag: postId,
    );

    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final double sheetHeight = MediaQuery.of(context).size.height * 0.6;

    return Container(
      height: sheetHeight,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // --- Handle Bar ---
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            "Comments",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),

          // --- Comments List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No comments yet. Be the first!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  reverse: true, // Start from bottom
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String commentId = docs[index].id;

                    Timestamp? ts = data['createdAt'] ?? data['timestamp'];
                    String time = ts != null
                        ? timeago.format(ts.toDate(), locale: 'en_short')
                        : 'now';
                    String username = data['username'] ?? 'User';
                    String avatar = data['userAvatar'] ?? '';
                    String type = data['type'] ?? 'text';
                    String audioUrl = data['audioUrl'] ?? '';
                    String text = data['text'] ?? '';
                    bool isMe = (data['userId'] == currentUserId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: (avatar.isNotEmpty)
                                ? NetworkImage(avatar)
                                : const NetworkImage("https://i.pravatar.cc/150")
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 10),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name & Time
                                Row(
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Audio or Text Bubble
                                if (type == 'audio' && audioUrl.isNotEmpty)
                                  AudioCommentBubble(
                                      audioUrl: audioUrl, isMe: isMe)
                                else
                                  Text(
                                    text,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                              ],
                            ),
                          ),

                          // Three-Dot Menu (Report)
                          if (!isMe)
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.more_horiz,
                                    size: 20, color: Colors.grey[400]),
                                onSelected: (value) {
                                  if (value == 'report') {
                                    Get.to(() => ReportCommentPage(
                                          controller: controller,
                                          commentId: commentId,
                                        ));
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'report',
                                    height: 35,
                                    child: Row(
                                      children: [
                                        Icon(Icons.flag_outlined,
                                            color: Colors.red, size: 18),
                                        SizedBox(width: 8),
                                        Text("Report",
                                            style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- Input Area ---
          Obx(() {
            if (controller.isRecording.value) {
              return _buildRecordingUI(controller);
            } else {
              return _buildTextInputUI(context, controller);
            }
          }),
        ],
      ),
    );
  }

  // --- Widget: Recording UI ---
  Widget _buildRecordingUI(CommentsController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.red.withOpacity(0.05),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Recording...",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => controller.cancelRecording(),
          ),
          CircleAvatar(
            backgroundColor: Colors.red,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => controller.stopAndSendRecording(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Text Input UI ---
  Widget _buildTextInputUI(
      BuildContext context, CommentsController controller) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.grey),
                  onPressed: () => controller.startRecording(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF5C5470),
            child: Obx(
              () => controller.isUploading.value
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send,
                          color: Colors.white, size: 20),
                      onPressed: () {
                        if (controller.commentController.text.isNotEmpty) {
                          controller.sendTextComment();
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}