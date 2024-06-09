import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/widgets/main/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  final String docId;
  const ChatMessages(this.docId, {super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('message')
          .doc(docId)
          .collection('msglist')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong.'),
          );
        }
        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true, //this would start the list form bottom to the top
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              //return Text(loadedMessages[index].data()['text']);
              final chatMessages = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessages['uid'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['uid'] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessages['content'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: 'adsfafasdij9owiewfd',
                    username: '',
                    message: chatMessages['content'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}















//nextMessage is being used to check whether we have two different user ids. so if the index is not less than the length(idx : 1, lnt: 1) it means that we have only one user therefore there is no need to check for defferent id. And also every new message has an index of 1, so the index would always be less than the length when the length is more than 1.
//In this ListView, to get the best understanding of how the messages are displayed, think of it like the messages are there and you're displaying them. Don't think much about how new messages being added .
/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/widgets/main/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong.'),
          );
        }
        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true, //this would start the list form bottom to the top
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              //return Text(loadedMessages[index].data()['text']);
              final chatMessages = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessages['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessages['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMessages['userImage'],
                    username: chatMessages['username'],
                    message: chatMessages['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}
//nextMessage is being used to check whether we have two different user ids. so if the index is not less than the length(idx : 1, lnt: 1) it means that we have only one user therefore there is no need to check for defferent id. And also every new message has an index of 1, so the index would always be less than the length when the length is more than 1.
//In this ListView, to get the best understanding of how the messages are displayed, think of it like the messages are there and you're displaying them. Don't think much about how new messages being added .
 */