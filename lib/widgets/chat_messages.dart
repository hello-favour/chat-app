import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found"),
          );
        }
        if (chatSnapshots.hasError) {
          return const Center(
            child: Text("Something went wrong..."),
          );
        }
        final loadMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            right: 13,
            left: 13,
          ),
          reverse: true,
          itemCount: loadMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadMessages[index].data();
            final nextChatMessage = index + 1 < loadMessages.length
                ? loadMessages[index + 1].data()
                : null;

            final currentMessageUserid = chatMessage["userId"];
            final nextMessageUserid =
                nextChatMessage != null ? nextChatMessage["userId"] : null;
            final nextUserIsMe = nextMessageUserid == currentMessageUserid;

            if (nextUserIsMe) {
              return MessageBubble.next(
                  message: chatMessage["text"],
                  isMe: authenticatedUser.uid == currentMessageUserid);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage["userImage"],
                  username: chatMessage["username"],
                  message: chatMessage["text"],
                  isMe: authenticatedUser.uid == currentMessageUserid);
            }
          },
        );
      },
    );
  }
}
