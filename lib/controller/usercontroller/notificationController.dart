// lib/controller/usercontroller/notificationController.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/data/model/notificationModel.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/view/screen/user/memoDetailView.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;

  // --- NEW: Helper to check if we have unread items ---
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    bindNotifications();
  }

  void bindNotifications() {
    User? user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      notifications.value = snapshot.docs
          .map((doc) => NotificationModel.fromSnapshot(doc))
          .toList();
      isLoading.value = false;
    }, onError: (e) {
      print("Notification Stream Error: $e");
      isLoading.value = false;
    });
  }

  // --- NEW: Mark notifications as read when page opens ---
  Future<void> markAllAsRead() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Filter only unread ones to save writes
    var unreadDocs = notifications.where((n) => !n.isRead).toList();
    
    if (unreadDocs.isEmpty) return;

    WriteBatch batch = _firestore.batch();

    for (var notif in unreadDocs) {
      var ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notif.id);
      
      batch.update(ref, {'isRead': true});
    }

    await batch.commit();
  }
  
Future<void> fetchAndNavigateToPost(String postId) async {
    try {
      // 1. Show Loading
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // 2. Fetch Document
      DocumentSnapshot doc = await _firestore.collection('posts').doc(postId).get();

      // 3. Hide Loading
      Get.back(); 

      if (doc.exists) {
        // 4. Convert to PostModel
        // NOTE: Adjust 'fromMap' or 'fromJson' based on your actual PostModel code
       // This handles the ID and data automatically
PostModel post = PostModel.fromSnapshot(doc);

        // 5. Navigate to MemoDetailView
        Get.to(() => MemoDetailView(
          initialPost: post,
          sourceList: [post], // We only have this one post context
          onToggleLike: (id) async {
             // Simple like logic since we aren't in the main feed
             // You might want to copy logic from HomeController here
             await _firestore.collection('posts').doc(id).update({
               'likes': FieldValue.arrayUnion([_auth.currentUser?.uid]) 
               // logic is complex for toggle, but this prevents crash
             });
          },
        ));
      } else {
        Get.snackbar("Unavailable", "This post has been deleted.");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Ensure loading closes on error
      print("Error fetching post: $e");
      Get.snackbar("Error", "Could not load post.");
    }
  }
}