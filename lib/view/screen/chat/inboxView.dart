import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/inboxController.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/view/screen/chat/chatView.dart';

class InboxView extends StatelessWidget {
  InboxView({Key? key}) : super(key: key);

  final InboxController controller = Get.put(InboxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.pagePrimaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Messages", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: controller.getChatsStream(),
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. ERROR STATE (This is what you are missing!)
            if (snapshot.hasError) {
              print(
                "Inbox Error: ${snapshot.error}",
              ); // Check your Debug Console
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Error Loading Chats:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            // 3. Empty State
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            // 4. List of Chats
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var chatDoc = snapshot.data!.docs[index];
                Map<String, dynamic> chatData =
                    chatDoc.data() as Map<String, dynamic>;

                List<dynamic> users = chatData['users'] ?? [];
                String myId = controller.getCurrentUserId();
                String otherUserId = users.firstWhere(
                  (id) => id != myId,
                  orElse: () => '',
                );

                if (otherUserId.isEmpty) return const SizedBox();

                return ChatListItem(
                  chatId: chatDoc.id,
                  otherUserId: otherUserId,
                  lastMessage: chatData['lastMessage'] ?? 'Started a chat',
                  timestamp: chatData['lastMessageTime'],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.send_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No messages yet", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final Timestamp? timestamp;

  const ChatListItem({
    Key? key,
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We use a FutureBuilder here to fetch the LATEST Name/Avatar of the other user
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        // Default placeholders while loading
        String displayName = "Loading...";
        String avatarUrl = "";

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          displayName = userData['username'] ?? "User";
          avatarUrl = userData['userAvatar'] ?? "";
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          onTap: () {
            // Navigate to Chat
            Get.to(
              () => ChatView(
                chatId: chatId,
                targetUserName: displayName,
                targetUserId: otherUserId,
              ),
            );
          },
          // AVATAR
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : const NetworkImage("https://i.pravatar.cc/300")
                        as ImageProvider,
          ),

          // NAME
          title: Text(
            displayName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),

          // LAST MESSAGE
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),

          // TIME
          trailing: Text(
            _formatTimestamp(timestamp),
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        );
      },
    );
  }

  // Simple Helper to format time like Instagram (2m, 1h, etc.)
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";

    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration diff = now.difference(date);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}d";

    return "${diff.inDays ~/ 7}w";
  }
}
