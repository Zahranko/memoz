import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have this in pubspec.yaml
import 'package:memzoProject/core/constant/color.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  final String targetUserId; // New field
  final String targetUserName;

  const ChatView({
    Key? key,
    required this.chatId,
    required this.targetUserId, // Receive ID
    required this.targetUserName,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variable to store the target user's avatar URL
  String? targetUserAvatar;

  @override
  void initState() {
    super.initState();
    _loadTargetUserAvatar();
  }

  void _loadTargetUserAvatar() async {
    try {
      var doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.targetUserId)
              .get();
      if (doc.exists) {
        setState(() {
          targetUserAvatar = doc['userAvatar'];
        });
      }
    } catch (e) {
      print("Error loading avatar: $e");
    }
  }

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'text': _messageController.text.trim(),
          'senderId': _auth.currentUser!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

    FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': _messageController.text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Instagram Style AppBar
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            // Small Avatar in AppBar
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  (targetUserAvatar != null && targetUserAvatar!.isNotEmpty)
                      ? NetworkImage(targetUserAvatar!)
                      : const NetworkImage("https://i.pravatar.cc/150")
                          as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(
              widget.targetUserName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chatId)
                        .collection('messages')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index].data() as Map<String, dynamic>;
                      bool isMe = msg['senderId'] == _auth.currentUser!.uid;

                      // Check timestamp
                      Timestamp? ts = msg['createdAt'] as Timestamp?;
                      String timeText =
                          ts != null
                              ? DateFormat('h:mm a').format(ts.toDate())
                              : "Sending...";

                      return _buildMessageBubble(msg['text'], isMe, timeText);
                    },
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String timeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // Align avatar to bottom
        children: [
          // 1. Show Avatar ONLY if it's NOT ME (Left Side)
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  (targetUserAvatar != null && targetUserAvatar!.isNotEmpty)
                      ? NetworkImage(targetUserAvatar!)
                      : const NetworkImage("https://i.pravatar.cc/150")
                          as ImageProvider,
            ),
            const SizedBox(width: 8),
          ],

          // 2. The Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // Instagram-like colors: Grey for them, Blue/Primary for me
                color: isMe ? AppColor.buttonColor : const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft:
                      isMe
                          ? const Radius.circular(22)
                          : const Radius.circular(4),
                  bottomRight:
                      isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Time Text
                  Text(
                    timeText,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Input Field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1), // Light grey input background
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: "Message...",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Send Button
            GestureDetector(
              onTap: sendMessage,
              child: const Text(
                "Send",
                style: TextStyle(
                  color: AppColor.buttonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
