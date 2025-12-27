import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:memzoProject/view/screen/chat/chatView.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initiateChat(String targetUserId, String targetUserName) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    String currentUserId = currentUser.uid;

    String chatId = getChatId(currentUserId, targetUserId);

    DocumentReference chatDoc = _firestore.collection('chats').doc(chatId);
    DocumentSnapshot docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      String myName = "User";
      try {
        var myDoc =
            await _firestore.collection('users').doc(currentUserId).get();
        if (myDoc.exists) {
          myName = myDoc['username'] ?? "User";
        }
      } catch (e) {
        print("Could not fetch my name: $e");
      }

      await chatDoc.set({
        'users': [currentUserId, targetUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdBy': currentUserId,
        'userNames': {currentUserId: myName, targetUserId: targetUserName},
      });
    }

    Get.to(
      () => ChatView(
        chatId: chatId,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
      ),
    );
  }
}

String getChatId(String user1, String user2) {
  return user1.compareTo(user2) < 0 ? "${user1}_$user2" : "${user2}_$user1";
}
