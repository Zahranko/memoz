import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memzoProject/data/model/postsModel.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Stream of Posts with User Details
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // We use Future.wait to fetch all user details in parallel for better performance
      List<Future<PostModel>> futures = snapshot.docs.map((doc) async {
        return await _generatePostModelWithUser(doc);
      }).toList();

      return await Future.wait(futures);
    });
  }

  // Helper to fetch User data and merge with Post data
  Future<PostModel> _generatePostModelWithUser(DocumentSnapshot postDoc) async {
    final postData = postDoc.data() as Map<String, dynamic>;
    final userId = postData['userId'];

    String userName = 'Unknown';
    String userAvatar = 'https://i.pravatar.cc/150'; // Default Avatar

    // 1. Try to fetch fresh data from the 'users' collection
    if (userId != null && userId.toString().isNotEmpty) {
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          // Check if fields exist and are not null/empty
          if (userData?['username'] != null && userData!['username'].toString().isNotEmpty) {
            userName = userData['username'];
          }
          if (userData?['userAvatar'] != null && userData!['userAvatar'].toString().isNotEmpty) {
            userAvatar = userData['userAvatar'];
          }
        }
      } catch (e) {
        print("Error fetching user details for post ${postDoc.id}: $e");
        // Fallback to what is inside the post document if the fetch fails
        userName = postData['userName'] ?? 'Unknown';
        userAvatar = postData['userAvatar'] ?? 'https://i.pravatar.cc/150';
      }
    }

    // 2. Return the Model using the fetched user data
    return PostModel.fromSnapshot(postDoc, overrideName: userName, overrideAvatar: userAvatar);
  }

  // Toggle Like (Unchanged)
  Future<void> toggleLikeInDb(String postId, String uid, bool currentlyLiked) async {
    final docRef = _firestore.collection('posts').doc(postId);

    if (currentlyLiked) {
      await docRef.update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }
}