// lib/view/widget/user/header.dart (or wherever AppHeader is)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/constant/imagesasset.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/view/screen/user/notification_view.dart';
// Import the controller
import 'package:memzoProject/controller/usercontroller/notificationController.dart';

class AppHeader extends StatelessWidget {
  final String title;

  // We ensure the controller is found or initialized
  final NotificationController notifController = Get.put(NotificationController());

  AppHeader({Key? key, this.title = 'memzo'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Left: Add Button
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Get.offNamed(AppRoute.AddPostView),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(ImagesAsset.addButton),
                backgroundColor: AppColor.pagePrimaryColor,
              ),
            ),
          ),

          // 2. Center: Logo/Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C5470),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bookmark, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),

          // 3. Right: Notification Icon with Red Dot
          Align(
            alignment: Alignment.centerRight,
            child: Stack(
              clipBehavior: Clip.none, // Allow dot to go slightly outside if needed
              children: [
                IconButton(
                  onPressed: () {
                    // Mark as read when clicking
                    notifController.markAllAsRead();
                    Get.to(() => NotificationView());
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    size: 30,
                    color: Color(0xFF5C5470),
                  ),
                ),
                
                // THE RED DOT LOGIC
                Obx(() {
                  if (notifController.unreadCount > 0) {
                    return Positioned(
                      right: 12, // Adjust position
                      top: 10,   // Adjust position
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}