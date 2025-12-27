import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/notificationController.dart';
import 'package:memzoProject/data/model/notificationModel.dart';
import 'package:memzoProject/view/screen/user/otherProfileView.dart'; 
import 'package:timeago/timeago.dart' as timeago;

class NotificationView extends StatelessWidget {
  NotificationView({Key? key}) : super(key: key);

  final NotificationController controller = Get.put(NotificationController());
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              return _buildNotificationItem(notif, context);
            },
          );
        }),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notif, BuildContext context) {
    // Helper to determine text based on type
    String notificationText = "";
    if (notif.type == 'follow') {
      notificationText = " started following you.";
    } else if (notif.type == 'like') {
      notificationText = " liked your memo.";
    } else if (notif.type == 'comment') {
      notificationText = " commented: ${notif.commentText ?? 'Nice!'}";
    }

    // Wrap the entire item in InkWell for clickability
    return InkWell(
      onTap: () {
        // 1. If it's a follow, go to their profile
        if (notif.type == 'follow') {
          Get.to(() => OtherUserProfileView(targetUserId: notif.fromUserId));
        }
        // 2. If it's a comment or like, go to the post's comments
        else if ((notif.type == 'comment' || notif.type == 'like') &&
            notif.postId != null) {
         controller.fetchAndNavigateToPost(notif.postId!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 1. Avatar
            GestureDetector(
              onTap: () {
                Get.to(
                  () => OtherUserProfileView(targetUserId: notif.fromUserId),
                );
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (notif.userAvatar.isNotEmpty)
                        ? NetworkImage(notif.userAvatar)
                        : const NetworkImage("https://i.pravatar.cc/150")
                            as ImageProvider,
              ),
            ),
            const SizedBox(width: 12),

            // 2. Text Content
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: notif.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: notificationText),
                    TextSpan(
                      text:
                          "  ${timeago.format(notif.timestamp.toDate(), locale: 'en_short')}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Trailing (View Button or Post Image)
            if (notif.type == 'follow')
              ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => OtherUserProfileView(targetUserId: notif.fromUserId),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C5470),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(
                  "View",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              )
            else if ((notif.type == 'like' || notif.type == 'comment') &&
                notif.postImage != null &&
                notif.postImage!.isNotEmpty)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                  image: DecorationImage(
                    image: NetworkImage(notif.postImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
