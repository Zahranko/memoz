import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class CommentsController extends GetxController {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;
CommentsController({
    required this.postId,
    required this.postOwnerId,
    required this.postImageUrl,
  });

  // --- Text Input ---
  final TextEditingController commentController = TextEditingController();

  // --- Recording State ---
  var isRecording = false.obs;
  var isUploading = false.obs;

  // --- Recorder Instance ---
  late AudioRecorder audioRecorder;
  String? recordedPath;

  @override
  void onInit() {
    super.onInit();
    audioRecorder = AudioRecorder();
  }

  @override
  void onClose() {
    audioRecorder.dispose();
    commentController.dispose();
    super.onClose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        String fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        String path = '${directory.path}/$fileName';

        await audioRecorder.start(const RecordConfig(), path: path);
        isRecording.value = true;
        recordedPath = path;
        print("Recording started at $path");
      } else {
        Get.snackbar("Permission Denied", "Please allow microphone access.");
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }
  Future<void> reportComment(String commentId, String reason) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String uid = user?.uid ?? 'anon';

     
      await FirebaseFirestore.instance.collection('reports').add({
        'target': 'comment', 
        'postId': postId,
        'commentId': commentId,
        'reportedBy': uid,
        'reason': reason,
        'status': 'pending',   
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar(
        "Report Submitted", 
        "Thanks for letting us know. We will review this shortly.",
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to submit report: $e");
    }
  }

  Future<void> stopAndSendRecording() async {
    try {
      final path = await audioRecorder.stop();
      isRecording.value = false;

      if (path != null) {
        recordedPath = path;
        await _uploadAndSaveComment(audioPath: path);
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
  }

  Future<void> cancelRecording() async {
    await audioRecorder.stop();
    isRecording.value = false;
    recordedPath = null;
  }

  void sendTextComment() {
    String text = commentController.text.trim();
    if (text.isEmpty) return;
    _uploadAndSaveComment(text: text);
  }

  Future<void> _uploadAndSaveComment({String? text, String? audioPath}) async {
    isUploading.value = true;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String uid = user?.uid ?? 'anon';

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String username =
          userDoc.exists ? (userDoc['username'] ?? 'User') : 'User';
      String avatar = userDoc.exists ? (userDoc['userAvatar'] ?? '') : '';

      String? audioUrl;
      if (audioPath != null) {
        File file = File(audioPath);
        String refName =
            "comments/${DateTime.now().millisecondsSinceEpoch}.m4a";
        Reference storageRef = FirebaseStorage.instance.ref().child(refName);
        await storageRef.putFile(file);
        audioUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'userId': uid,
            'username': username,
            'userAvatar': avatar,
            'text': text ?? '',
            'audioUrl': audioUrl ?? '',
            'type': audioUrl != null ? 'audio' : 'text',
            'createdAt': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });
      

if (uid != postOwnerId) {
        await addToNotification(
          targetUserId: postOwnerId,
          fromUserId: uid,
          fromUsername: username,
          fromUserAvatar: avatar,
          commentContent: audioUrl != null ? "Sent a voice note" : text ?? "",
          postImage: postImageUrl,
        );
      }

      commentController.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to send comment: $e");
    } finally {
      isUploading.value = false;
    }
  }
  
  Future<void> addToNotification({
    required String targetUserId,
    required String fromUserId,
    required String fromUsername,
    required String fromUserAvatar,
    required String commentContent,
    required String postImage,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('notifications')
          .add({
        'type': 'comment',
        'fromUserId': fromUserId,
        'username': fromUsername,
        'userAvatar': fromUserAvatar,
        'postId': postId,
        'postImage': postImage, 
        'commentText': commentContent,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

}
