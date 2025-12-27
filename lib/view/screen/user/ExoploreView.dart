import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/ExploreController.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/view/screen/user/otherProfileView.dart';
import 'package:memzoProject/view/widget/user/postCard.dart';

class ExploreView extends StatelessWidget {
  ExploreView({Key? key}) : super(key: key);

  final ExploreController controller = Get.put(ExploreController());

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pagePrimaryColor,
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: AppColor.pagePrimaryColor,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  pinned: false,
                  title: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (val) => controller.searchUsers(val),
                      decoration: const InputDecoration(
                        hintText: "Search for users...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
          body: SafeArea(
            child: Obx(() {
              // --- SEARCH RESULTS LIST ---
              if (controller.isSearching.value) {
                var filteredList =
                    controller.searchResults.where((doc) {
                      return doc.id != currentUserId;
                    }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredList.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = filteredList[index];
                    Map<String, dynamic> user =
                        doc.data() as Map<String, dynamic>;

                    // 1. Username
                    String username =
                        user['username'] ??
                        user['userName'] ??
                        user['name'] ??
                        'Unknown';

                    // 2. Profile Picture
                    String profilePic =
                        user['profilePic'] ??
                        user['userAvatar'] ??
                        user['image'] ??
                        '';

                    // 3. --- CHANGED: Construct Full Name instead of Bio ---
                    String firstName = user['firstName'] ?? '';
                    String lastName = user['lastName'] ?? '';
                    String fullName = "$firstName $lastName".trim();

                    // Fallback: if constructed name is empty, try 'fullName' key or just use username
                    if (fullName.isEmpty) {
                      fullName = user['fullName'] ?? '';
                    }

                    return Card(
                      elevation: 0,
                      color: Colors.white.withValues(alpha: 0.9),
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              (profilePic.isNotEmpty)
                                  ? NetworkImage(profilePic)
                                  : const NetworkImage(
                                    "https://miro.medium.com/v2/resize:fit:1080/1*8ATQ6ycC0MkZo4DKMUuGnw.png",
                                  ),
                          onBackgroundImageError:
                              (_, __) => const Icon(Icons.person),
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // 4. Display Full Name in Subtitle
                        subtitle:
                            fullName.isNotEmpty
                                ? Text(
                                  fullName,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                                : null,
                        onTap: () {
                          Get.to(
                            () => OtherUserProfileView(targetUserId: doc.id),
                          );
                        },
                      ),
                    );
                  },
                );
              }

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.explorePosts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No recent memos found.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchExplorePosts,
                color: Colors.black,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: controller.explorePosts.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = controller.explorePosts[index];

                    return PostCard(
                      post: post,
                      onLike: () => controller.toggleLike(post.id),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
