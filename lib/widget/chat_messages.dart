import 'package:chat_app/widget/message_bubble.dart';
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
          .collection("chat")
          .orderBy(
            "createdAt",
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatsnapshot) {
        if (chatsnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatsnapshot.hasData || chatsnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Messages Found"),
          );
        }

        if (chatsnapshot.hasError) {
          return const Center(
            child: Text("Something Went Wrong!!"),
          );
        }

        final loadedMessages = chatsnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessages = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final curerntChatMessageUserId = chatMessages['userId'];
              final nextMessageUsername =
                  nextChatMessage != null ? nextChatMessage["usernId"] : null;
              final nextUserIsSame =
                  nextMessageUsername == curerntChatMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessages['text'],
                    isMe: authenticatedUser.uid == curerntChatMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMessages['userImage'],
                    username: chatMessages['username'],
                    message: chatMessages['text'],
                    isMe: authenticatedUser.uid == curerntChatMessageUserId);
              }
            });
      },
    );
  }
}
