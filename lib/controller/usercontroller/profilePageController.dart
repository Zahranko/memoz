import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/controller/usercontroller/feedController.dart';
import 'package:memzoProject/data/model/postsModel.dart';
// Add ExploreController import to sync delete there too
import 'package:memzoProject/controller/usercontroller/ExploreController.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Reactive State ---
  var userPosts = <PostModel>[].obs;
  var isLoading = true.obs;

  // User Details (Reactive)
  var username = ''.obs;
  var fullName = ''.obs;
  var bio = ''.obs;
  var profilePic = ''.obs;

  // Stats
  var postCount = 0.obs;
  var followers = 0.obs;
  var following = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchUserPosts();
  }

  // 1. Get Real User Info from 'users' collection
  void fetchUserProfile() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      _firestore.collection('users').doc(currentUser.uid).snapshots().listen((
        DocumentSnapshot userDoc,
      ) {
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          username.value = data['username'] ?? '';
          fullName.value =
              "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
          profilePic.value = data['userAvatar'] ?? '';
          bio.value = data['bio'] ?? "No bio available.";
          followers.value = data['followersCount'] ?? 0;
          following.value = data['followingCount'] ?? 0;
        }
      });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  // 2. Fetch ONLY this user's posts
  void fetchUserPosts() {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      _firestore
          .collection('posts')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            List<PostModel> loadedPosts =
                snapshot.docs
                    .map((doc) => PostModel.fromSnapshot(doc))
                    .toList();

            userPosts.value = loadedPosts;
            postCount.value = loadedPosts.length;
            isLoading.value = false;
          });
    } catch (e) {
      print("Error fetching profile posts: $e");
      isLoading.value = false;
    }
  }

  // --- DELETE POST LOGIC (UPDATED) ---
  Future<void> deletePost(String postId) async {
    try {
      // 1. Delete from Firestore
      await _firestore.collection('posts').doc(postId).delete();

      // 2. Remove from Profile list (Local UI update)
      userPosts.removeWhere((post) => post.id == postId);
      postCount.value = userPosts.length;
      userPosts.refresh(); // <--- FORCE UI UPDATE FOR PROFILE

      // 3. Sync with Home Feed (Remove from Home immediately)
      if (Get.isRegistered<FeedControllerImp>()) {
        Get.find<FeedControllerImp>().removePostFromList(postId);
      }

      // 4. Sync with Explore Feed (Remove from Explore immediately)
      if (Get.isRegistered<ExploreController>()) {
        // Directly access the list in ExploreController and remove the post
        var exploreCtrl = Get.find<ExploreController>();
        exploreCtrl.explorePosts.removeWhere((p) => p.id == postId);
        exploreCtrl.explorePosts.refresh(); // <--- FORCE UI UPDATE FOR EXPLORE
      }

      Get.snackbar("Success", "Memo deleted");
    } catch (e) {
      Get.snackbar("Error", "Could not delete post");
      print("Delete Error: $e");
    }
  }

  // --- EDIT POST LOGIC ---
  Future<void> editPost(
    String postId,
    String newCaption,
    String newLocation,
    String newFeeling,
  ) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'caption': newCaption,
        'locationName': newLocation,
        'feeling': newFeeling,
      });

      int index = userPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        userPosts[index] = userPosts[index].copyWith(
          caption: newCaption,
          locationName: newLocation,
          feeling: newFeeling,
        );
        userPosts.refresh(); // Update Profile UI
      }

      if (Get.isRegistered<FeedControllerImp>()) {
        Get.find<FeedControllerImp>().updatePostInList(
          postId,
          newCaption,
          newLocation,
          newFeeling,
        );
      }

      Get.snackbar("Success", "Memo updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update post");
      print("Edit Error: $e");
    }
  }

  void shareProfile() {
    if (fullName.value.isEmpty || username.value.isEmpty) return;

    // Construct the message
    // Note: Since we don't have a real website, we use a placeholder link or just text.
    String message =
        "Check out ${fullName.value}'s profile on our App!\n"
        "Username: @${username.value}\n\n"
        "https://example.com/user/${username.value}"; // Fake link for visual

    // Trigger the native share dialog
    Share.share(message);
  }

  void signOut() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoute.login);
  }

  Future<void> toggleLike(String postId) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
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
        await FirebaseFirestore.instance.collection('posts').doc(postId).update(
          {
            'likes': FieldValue.arrayRemove([currentUserId]),
          },
        );
      } else {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update(
          {
            'likes': FieldValue.arrayUnion([currentUserId]),
          },
        );
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  Future<void> updatePostData(String postId, Map<String, dynamic> data) async {
    try {
      // 1. Update Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update(data);

      // 2. Update Local List (Instant UI Refresh)
      int index = userPosts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        // Fetch the fresh document to get the correct data (especially image URLs)
        DocumentSnapshot updatedDoc =
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .get();

        // Replace the old post in the list with the new one
        userPosts[index] = PostModel.fromSnapshot(updatedDoc);

        // Notify GetX that the list has changed
        userPosts.refresh();
      }
    } catch (e) {
      print("Error updating post: $e");
      throw e; // Pass error back to EditPostController so it stops the loading spinner
    }
  }
}
