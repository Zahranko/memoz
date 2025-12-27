import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/controller/usercontroller/feedController.dart';

class ExploreController extends GetxController {
  var isLoading = true.obs;
  var explorePosts = <PostModel>[].obs;

  var isSearching = false.obs;
  var searchResults = <DocumentSnapshot>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchExplorePosts();
  }

  Future<void> fetchExplorePosts() async {
    try {
      isLoading(true);
      DateTime threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      Timestamp timestamp = Timestamp.fromDate(threeDaysAgo);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('createdAt', isGreaterThanOrEqualTo: timestamp)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        explorePosts.value =
            snapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
      } else {
        explorePosts.clear();
      }
    } catch (e) {
      print("Explore Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- UPDATED SEARCH WITH IGNORE CASE ---
  void searchUsers(String query) async {
    if (query.trim().isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }
    isSearching.value = true;

    try {
      // 1. Fetch Users 
      // (For a small app this is fine. For millions of users, you should store a lowercase field in DB)
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      String lowerQuery = query.toLowerCase();

      // 2. Filter Client-Side (Ignoring Case)
      List<DocumentSnapshot> filteredList = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final String username = (data['username'] ?? '').toString().toLowerCase();
        
        // This checks if the username STARTS WITH the query (like standard search)
        // You can use .contains() if you want to find text in the middle too.
        return username.startsWith(lowerQuery); 
      }).toList();

      searchResults.value = filteredList;

    } catch (e) {
      print("Search Error: $e");
    }
  }

  void syncLikeStatus(String postId) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    int index = explorePosts.indexWhere((p) => p.id == postId);

    if (index == -1) return;

    PostModel post = explorePosts[index];
    List<String> newLikes = List.from(post.likes);

    if (newLikes.contains(currentUserId)) {
      newLikes.remove(currentUserId);
    } else {
      newLikes.add(currentUserId);
    }

    explorePosts[index] = post.copyWith(likes: newLikes);
    explorePosts.refresh();
  }

  Future<void> toggleLike(String postId) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    int index = explorePosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    PostModel post = explorePosts[index];
    List<String> newLikes = List.from(post.likes);

    bool isLiked = newLikes.contains(currentUserId);
    if (isLiked) {
      newLikes.remove(currentUserId);
    } else {
      newLikes.add(currentUserId);
    }

    explorePosts[index] = post.copyWith(likes: newLikes);
    explorePosts.refresh();

    if (Get.isRegistered<FeedControllerImp>()) {
      Get.find<FeedControllerImp>().syncLikeStatus(postId);
    }

    try {
      if (isLiked) {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }
}