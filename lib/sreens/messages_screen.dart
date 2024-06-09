import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/widgets/main/chat_messages.dart';
import 'package:i_chat/widgets/main/new_message.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String about;
  final String imageUrl;
  const ChatScreen(this.userId, this.userName, this.imageUrl, this.about,
      {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String docId = 'default';
  void getDocId() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('message').get();
    final user = FirebaseAuth.instance.currentUser!;

    final usersId = snapshot.docs.firstWhere(
      (doc) => doc.id.contains(user.uid) & doc.id.contains(widget.userId),
    );
    setState(() {
      docId = usersId.id;
    });
  }

  @override
  void initState() {
    super.initState();
    getDocId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: InkWell(
          onTap: () {
            return Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(widget.imageUrl),
          ),
          title: Text(
            widget.userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).canvasColor,
            ),
          ),
          subtitle: Text(
            widget.about,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: ChatMessages(docId),
        ),
        NewMessage(widget.userId),
      ]),
    );
  }
}
