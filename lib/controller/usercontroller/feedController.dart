import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/controller/usercontroller/ExploreController.dart';

class FeedControllerImp extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var posts = <PostModel>[].obs;

  String myUsername = '';
  String myAvatar = '';

  @override
  void onInit() {
    super.onInit();
    fetchFollowingPosts();
    _loadMyInfo();
  }

  void updatePostInList(
    String postId,
    String caption,
    String location,
    String feeling,
  ) {
    int index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      PostModel current = posts[index];
      posts[index] = current.copyWith(
        caption: caption,
        locationName: location,
        feeling: feeling,
      );
      posts.refresh();
    }
  }

  void removePostsByUser(String userId) {
    posts.removeWhere((p) => p.userId == userId);
    posts.refresh();
  }

  void _loadMyInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        myUsername = doc['username'] ?? 'User';
        myAvatar = doc['userAvatar'] ?? '';
      }
    }
  }

  Future<void> fetchFollowingPosts() async {
  User? user = _auth.currentUser;
  if (user == null) return;

  try {
    isLoading(true);

    // 1. Fetch the list of users you follow
    var followingSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .get();

    // 2. Extract IDs into a list
    List<String> followingIds =
        followingSnapshot.docs.map((doc) => doc.id).toList();

    // --- CHANGE STARTS HERE ---
    // 3. Add YOUR own ID to this list so your posts are included
    followingIds.add(user.uid); 
    // --- CHANGE ENDS HERE ---

    // Note: We removed the "if empty return" check because 
    // the list now contains at least your ID.

    // 4. Fetch the latest 100 posts from the database
    QuerySnapshot snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    if (snapshot.docs.isNotEmpty) {
      List<PostModel> allPosts =
          snapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();

      // 5. Filter: Keep post if the userId is in the list (Friend OR Me)
      posts.value =
          allPosts.where((p) => followingIds.contains(p.userId)).toList();
    } else {
      posts.clear();
    }
  } catch (e) {
    print("Feed Error: $e");
  } finally {
    isLoading(false);
  }
}

  void removePostFromList(String postId) {
    posts.removeWhere((p) => p.id == postId);
    posts.refresh();
  }

  void syncLikeStatus(String postId) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    int index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    PostModel post = posts[index];
    List<String> newLikes = List.from(post.likes);

    if (newLikes.contains(currentUserId)) {
      newLikes.remove(currentUserId);
    } else {
      newLikes.add(currentUserId);
    }

    posts[index] = post.copyWith(likes: newLikes);
    posts.refresh();
  }

  Future<void> toggleLike(String postId) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

   
    int index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    PostModel post = posts[index];
    List<String> newLikes = List.from(post.likes);

    bool isLiked = newLikes.contains(currentUserId);
    
    if (isLiked) {
  
      newLikes.remove(currentUserId);
    } else {

      newLikes.add(currentUserId);
    }

  
    posts[index] = post.copyWith(likes: newLikes);
    posts.refresh();

 
    if (Get.isRegistered<ExploreController>()) {
      Get.find<ExploreController>().syncLikeStatus(postId);
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

       
        if (post.userId != currentUserId) {
           await _sendLikeNotification(
             targetUserId: post.userId, 
             postId: postId, 
             postImage: post.images.isNotEmpty ? post.images.first : null
           );
        }
      }
    } catch (e) {
      print("Like Error: $e");
      
    }
  }

  Future<void> addComment(
    String postId,
    String postOwnerId,
    String commentText,
    String? postImage,
  ) async {
    User? user = _auth.currentUser;
    if (user == null || commentText.trim().isEmpty) return;

    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'userId': user.uid,
            'username': myUsername,
            'userAvatar': myAvatar,
            'text': commentText.trim(),
            'timestamp': FieldValue.serverTimestamp(),
          });

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      int index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        PostModel currentPost = posts[index];
        posts[index] = currentPost.copyWith(
          commentCount: currentPost.commentCount + 1,
        );
        posts.refresh();
      }

      if (postOwnerId != user.uid) {
        await _firestore
            .collection('users')
            .doc(postOwnerId)
            .collection('notifications')
            .add({
              'type': 'comment',
              'fromUserId': user.uid,
              'username': myUsername,
              'userAvatar': myAvatar,
              'postId': postId,
              'postImage': postImage ?? '',
              'commentText': commentText.trim(),
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
            });
      }

      Get.snackbar("Success", "Comment posted!");
    } catch (e) {
      print("Comment Error: $e");
      Get.snackbar("Error", "Failed to post comment");
    }
  }
  // --- NEW HELPER FUNCTION ---
  Future<void> _sendLikeNotification({
    required String targetUserId, 
    required String postId, 
    String? postImage
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('notifications')
          .add({
        'type': 'like', // Matches your NotificationView logic
        'fromUserId': user.uid,
        'username': myUsername,
        'userAvatar': myAvatar,
        'postId': postId,
        'postImage': postImage ?? '',
        'commentText': '', // Empty for likes
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print("Notification Error: $e");
    }
  }
  Future<void> reportPost(String postId, String reason) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Create a new document in the 'reports' collection
      await _firestore.collection('reports').add({
        'postId': postId,
        'reporterId': user.uid,
        'reporterUsername': myUsername,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // Pending admin review
      });

      Get.snackbar(
        "Report Submitted",
        "Thank you for helping keep our community safe.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Report Error: $e");
      Get.snackbar(
        "Error",
        "Failed to submit report. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}
