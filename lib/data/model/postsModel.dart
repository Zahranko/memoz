import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String locationName;
  final String feeling;
  final String caption;
  final List<String> images;
  final List<String> likes;
  final int commentCount;
  final DateTime? createdAt;

  // ✅ 1. The Field
  final String? audioUrl;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.locationName,
    required this.feeling,
    required this.caption,
    required this.images,
    required this.likes,
    required this.commentCount,
    this.createdAt,

    // ✅ 2. Fixed Constructor: Make it a named optional parameter
    this.audioUrl,
  });

  bool isLikedBy(String? uid) {
    if (uid == null) return false;
    return likes.contains(uid);
  }

  int get likeCount => likes.length;

  factory PostModel.fromSnapshot(
    DocumentSnapshot doc, {
    String? overrideName,
    String? overrideAvatar,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    List<String> imgList = [];
    if (data['images'] != null) {
      imgList = List<String>.from(data['images']);
    } else if (data['postImages'] != null) {
      imgList = List<String>.from(data['postImages']);
    } else if (data['postImage'] != null) {
      imgList.add(data['postImage']);
    }

    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName:
          overrideName ??
          data['userName'] ??
          data['username'] ??
          data['name'] ??
          data['fullName'] ??
          'Unknown User',
      userAvatar:
          overrideAvatar ??
          data['userAvatar'] ??
          data['userImage'] ??
          data['profilePic'] ??
          data['profileImage'] ??
          data['image'] ??
          'https://i.pravatar.cc/150',
      locationName: data['locationName'] ?? data['location'] ?? '',
      feeling: data['feeling'] ?? '',
      caption: data['caption'] ?? data['body'] ?? data['description'] ?? '',
      images: imgList,
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? data['comments'] ?? 0,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,

      // ✅ 3. Read audioUrl from Firestore data
      audioUrl: data['audioUrl'],
    );
  }

  // --- UPDATED COPYWITH METHOD ---
  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? locationName,
    String? feeling,
    String? caption,
    List<String>? images,
    List<String>? likes,
    int? commentCount,
    DateTime? createdAt,
    String? audioUrl, // ✅ 4. Add to copyWith arguments
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      locationName: locationName ?? this.locationName,
      feeling: feeling ?? this.feeling,
      caption: caption ?? this.caption,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,

      // ✅ 5. Update audioUrl
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
