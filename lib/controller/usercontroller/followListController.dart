import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FollowListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var userList = <Map<String, dynamic>>[].obs; // Stores user details {id, username, avatar, etc}

  /// [userId]: The ID of the profile we are looking at
  /// [collectionName]: Must be 'followers' or 'following'
  Future<void> fetchUsersList(String userId, String collectionName) async {
    try {
      isLoading(true);
      userList.clear();

      // 1. Get the list of IDs from the subcollection
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .get();

      if (snapshot.docs.isEmpty) {
        isLoading(false);
        return;
      }

      // 2. Loop through the documents to get the User IDs
      List<String> userIds = snapshot.docs.map((doc) => doc.id).toList();

      // 3. Fetch details for each user (Future.wait runs them in parallel)
      List<Map<String, dynamic>> loadedUsers = [];

      // Note: Firestore 'whereIn' is limited to 10, so we loop or use batches. 
      // For simplicity in this example, we fetch individually. 
      // For production with 1000s of users, you would use pagination.
      for (String id in userIds) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(id).get();
        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          data['uid'] = id; // Attach the ID to the data
          loadedUsers.add(data);
        }
      }

      userList.value = loadedUsers;
    } catch (e) {
      print("Error fetching $collectionName: $e");
    } finally {
      isLoading(false);
    }
  }
}