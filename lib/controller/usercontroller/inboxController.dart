import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class InboxController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable list of chat documents
  // We use dynamic because DocumentSnapshot can be complex
  Stream<QuerySnapshot> getChatsStream() {
    String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('users', arrayContains: uid) // Get chats where I am a participant
        .orderBy('lastMessageTime', descending: true) // Newest first
        .snapshots();
  }

  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }
}