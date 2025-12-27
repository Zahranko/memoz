import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/controller/usercontroller/chatController.dart';
// Adjust path if needed
import 'package:memzoProject/controller/usercontroller/feedController.dart'; 

class OtherProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var userPosts = <PostModel>[].obs;

  // User Data
  var fullName = ''.obs;
  var username = ''.obs;
  var bio = ''.obs;
  var profilePic = ''.obs;

  // Stats
  var followers = 0.obs;
  var following = 0.obs;
  var postCount = 0.obs;

  // Follow Status
  var isFollowing = false.obs;

  // To store current user data for the notification
  String myUsername = '';
  String myAvatar = '';

  @override
  void onInit() {
    super.onInit();
    _fetchMyDetails(); 
  }

  void _fetchMyDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        myUsername = doc['username'] ?? 'Someone';
        myAvatar = doc['userAvatar'] ?? '';
      }
    }
  }

  Future<void> loadUserProfile(String targetUserId) async {
    try {
      isLoading(true);
      await checkIfFollowing(targetUserId);

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(targetUserId).get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        fullName.value = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        if (fullName.value.isEmpty) fullName.value = data['username'] ?? 'User';
        username.value = data['username'] ?? 'user';
        bio.value = data['bio'] ?? 'No bio available';
        profilePic.value = data['userAvatar'] ?? '';
        followers.value = data['followersCount'] ?? 0;
        following.value = data['followingCount'] ?? 0;
      }

      QuerySnapshot postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: targetUserId)
          .orderBy('createdAt', descending: true)
          .get();

      userPosts.value = postsSnapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
      postCount.value = userPosts.length;
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> checkIfFollowing(String targetUserId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('following')
          .doc(targetUserId)
          .get();
      isFollowing.value = doc.exists;
    } catch (e) {
      print("Error checking follow: $e");
    }
  }

  // =========================================================
  // --- UPDATED TOGGLE FOLLOW LOGIC ---
  // =========================================================
  Future<void> toggleFollow(String targetUserId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid == targetUserId) return;

    bool currentStatus = isFollowing.value;
    isFollowing.value = !currentStatus;

    if (isFollowing.value) followers.value++; else if (followers.value > 0) followers.value--;

    WriteBatch batch = _firestore.batch();

    DocumentReference myFollowingDoc = _firestore.collection('users').doc(currentUser.uid).collection('following').doc(targetUserId);
    DocumentReference theirFollowersDoc = _firestore.collection('users').doc(targetUserId).collection('followers').doc(currentUser.uid);
    DocumentReference myUserDoc = _firestore.collection('users').doc(currentUser.uid);
    DocumentReference theirUserDoc = _firestore.collection('users').doc(targetUserId);

    if (isFollowing.value) {
      // --- FOLLOW LOGIC ---
      batch.set(myFollowingDoc, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(theirFollowersDoc, {'timestamp': FieldValue.serverTimestamp()});
      
      batch.update(myUserDoc, {'followingCount': FieldValue.increment(1)});
      batch.update(theirUserDoc, {'followersCount': FieldValue.increment(1)});

      DocumentReference notificationRef = _firestore.collection('users').doc(targetUserId).collection('notifications').doc();
      batch.set(notificationRef, {
        'type': 'follow',
        'fromUserId': currentUser.uid,
        'username': myUsername,
        'userAvatar': myAvatar,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // --- NEW: REFRESH HOME FEED (Add their posts) ---
      if (Get.isRegistered<FeedControllerImp>()) {
        // This will re-fetch the list, now including the new person you followed
        Get.find<FeedControllerImp>().fetchFollowingPosts();
      }

    } else {
      // --- UNFOLLOW LOGIC ---
      batch.delete(myFollowingDoc);
      batch.delete(theirFollowersDoc);
      batch.update(myUserDoc, {'followingCount': FieldValue.increment(-1)});
      batch.update(theirUserDoc, {'followersCount': FieldValue.increment(-1)});

      try {
        QuerySnapshot oldNotifs = await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('notifications')
            .where('type', isEqualTo: 'follow')
            .where('fromUserId', isEqualTo: currentUser.uid)
            .get();

        for (var doc in oldNotifs.docs) {
          batch.delete(doc.reference); 
        }
      } catch (e) {
        print("Error finding notification to delete: $e");
      }

      // --- REMOVE FROM HOME FEED INSTANTLY ---
      if (Get.isRegistered<FeedControllerImp>()) {
        Get.find<FeedControllerImp>().removePostsByUser(targetUserId);
      }
    }

    try {
      await batch.commit();
    } catch (e) {
      isFollowing.value = currentStatus; // Revert UI
      if (currentStatus) followers.value++; else followers.value--;
      Get.snackbar("Error", "Action failed");
    }
  }

  // --- LIKE LOGIC ---
  Future<void> toggleLike(String postId) async {
    String currentUserId = _auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    int index = userPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    PostModel post = userPosts[index];
    List<String> newLikes = List.from(post.likes);
    bool isLiked = newLikes.contains(currentUserId);

    if (isLiked) {
      newLikes.remove(currentUserId);
    } else {
      newLikes.add(currentUserId);
    }

    userPosts[index] = post.copyWith(likes: newLikes);
    userPosts.refresh();

    try {
      if (isLiked) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });

        if (post.userId != currentUserId) {
          await _firestore.collection('users').doc(post.userId).collection('notifications').add({
            'type': 'like',
            'fromUserId': currentUserId,
            'username': myUsername,
            'userAvatar': myAvatar,
            'postId': postId,
            'postImage': post.images.isNotEmpty ? post.images.first : '',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });
        }
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  void startChatWithUser(String targetUserId) {
    String displayName = username.value.isNotEmpty ? username.value : "User";
    ChatController chatController = Get.put(ChatController());
    chatController.initiateChat(targetUserId, displayName);
  }
}