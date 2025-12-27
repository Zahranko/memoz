import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/feedController.dart';
import 'package:memzoProject/controller/usercontroller/profilePageController.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/view/screen/user/editPostView.dart';
import 'package:memzoProject/view/widget/user/postCard.dart';

class MemoDetailView extends StatelessWidget {
  final PostModel initialPost;
  final List<PostModel> sourceList;
  final Function(String) onToggleLike;

  MemoDetailView({
    Key? key,
    required this.initialPost,
    required this.sourceList,
    required this.onToggleLike,
  }) : super(key: key);

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    // Logic to check ownership
    final bool isMyPost = initialPost.userId == currentUserId;

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
        title: const Text(
          "Memo Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // --- UPDATED 3-DOT MENU ---
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                Get.to(() => EditPostView(post: initialPost));
              } else if (value == 'delete') {
                _confirmDelete(context);
              } else if (value == 'report') {
                _showReportDialog(context);
              } else if (value == 'recommendation') {
                _showRecommendations(context);
              }
            },
            itemBuilder: (BuildContext context) {
              if (isMyPost) {
                // Options for the Post Owner
                return [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: Colors.black54),
                        SizedBox(width: 10),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Delete", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              } else {
                // Options for Other Users (Viewers)
                return [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 20, color: Colors.orange),
                        SizedBox(width: 10),
                        Text("Report"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'recommendation',
                    child: Row(
                      children: [
                        Icon(Icons.recommend, size: 20, color: Colors.blue),
                        SizedBox(width: 10),
                        Text("Similar Places"),
                      ],
                    ),
                  ),
                ];
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // Use PostCard, but disable the 'onTap' so it doesn't open itself again
              PostCard(
                post: initialPost,
                onLike: () => onToggleLike(initialPost.id),
                onPostTap: null, 
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- DELETE LOGIC ---
  void _confirmDelete(BuildContext context) {
    Get.defaultDialog(
      title: "Delete Memo",
      middleText: "Are you sure you want to delete this memo? This cannot be undone.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // Close Dialog
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().deletePost(initialPost.id);
        } else {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(initialPost.id)
              .delete();
        }
        Get.back(); // Close Page
      },
    );
  }

  // --- REPORT LOGIC (New) ---
  void _showReportDialog(BuildContext context) {
    final TextEditingController reportController = TextEditingController();
    Get.defaultDialog(
      title: "Report Post",
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text("Why are you reporting this post?"),
            const SizedBox(height: 10),
            TextField(
              controller: reportController,
              decoration: const InputDecoration(
                hintText: "Enter reason (e.g., spam, abusive)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      textConfirm: "Submit",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
     onConfirm: () {
  Get.back(); // Close dialog first

  // Call the controller method
  Get.find<FeedControllerImp>().reportPost(
     initialPost.id, 
     reportController.text.trim()
  );
},
    );
  }

  // --- RECOMMENDATION LOGIC (New with Dummy Data) ---
  void _showRecommendations(BuildContext context) {
    // Dummy Data
    final List<Map<String, String>> dummyPlaces = [
      {
        "name": "Sunset Café",
        "distance": "1.2 km away",
        "image": "https://via.placeholder.com/150"
      },
      {
        "name": "City Park Plaza",
        "distance": "3.5 km away",
        "image": "https://via.placeholder.com/150"
      },
      {
        "name": "Ocean View Point",
        "distance": "5.0 km away",
        "image": "https://via.placeholder.com/150"
      },
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Places like this",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Based on the photo and location",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dummyPlaces.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final place = dummyPlaces[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      place['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(place['name']!),
                  subtitle: Text(place['distance']!),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.back();
                    Get.snackbar("Exploring", "Navigating to ${place['name']}");
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}