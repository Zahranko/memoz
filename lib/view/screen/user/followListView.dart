import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/followListController.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/view/screen/user/otherProfileView.dart';

// Import OtherUserProfileView to navigate when clicking a user

class FollowListView extends StatefulWidget {
  final String userId;
  final String title; // "Followers" or "Following"
  final String collectionName; // "followers" or "following" (lowercase for DB)

  const FollowListView({
    Key? key,
    required this.userId,
    required this.title,
    required this.collectionName,
  }) : super(key: key);

  @override
  State<FollowListView> createState() => _FollowListViewState();
}

class _FollowListViewState extends State<FollowListView> {
  final FollowListController controller = Get.put(FollowListController());

  @override
  void initState() {
    super.initState();
    // Fetch data when page loads
    controller.fetchUsersList(widget.userId, widget.collectionName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.pagePrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.userList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    "No ${widget.title.toLowerCase()} found",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.userList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final user = controller.userList[index];
              final String avatar = user['userAvatar'] ?? '';
              final String username = user['username'] ?? 'User';
              final String fullName =
                  "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
              final String uid = user['uid'];

              return GestureDetector(
                onTap: () {
                  // Navigate to that user's profile
                  // We use preventDuplicates: false to allow navigating to another profile from a profile
                  Get.to(
                    () => OtherUserProfileView(targetUserId: uid),
                    preventDuplicates: false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            (avatar.isNotEmpty)
                                ? NetworkImage(avatar)
                                : const NetworkImage(
                                      "https://i.pravatar.cc/150",
                                    )
                                    as ImageProvider,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (fullName.isNotEmpty)
                              Text(
                                fullName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
