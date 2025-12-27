import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String type; // 'follow', 'like', 'comment'
  final String fromUserId;
  final String username;
  final String userAvatar;
  final String? postId;
  final String? postImage;
  final String? commentText; // <--- ADD THIS
  final Timestamp timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.username,
    required this.userAvatar,
    this.postId,
    this.postImage,
    this.commentText, // <--- ADD THIS
    required this.timestamp,
    required this.isRead,
  });

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      type: data['type'] ?? '',
      fromUserId: data['fromUserId'] ?? '',
      username: data['username'] ?? 'User',
      userAvatar: data['userAvatar'] ?? '',
      postId: data['postId'],
      postImage: data['postImage'],
      commentText: data['commentText'], // <--- ADD THIS MAPPER
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}