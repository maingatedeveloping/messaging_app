import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/update_user_provider.dart';

class NewMessage extends StatefulWidget {
  final String userId;
  const NewMessage(this.userId, {super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    _messageController.clear();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('message').get();

    final usersId = snapshot.docs.firstWhere(
        (doc) => doc.id.contains(user.uid) & doc.id.contains(widget.userId));

    FirebaseFirestore.instance.collection('message').doc(usersId.id).set({
      'last_message': enteredMessage,
      'createdAt': Timestamp.now(),
    });

    FirebaseFirestore.instance
        .collection('message')
        .doc(usersId.id)
        .collection('msglist')
        .add({
      'createdAt': Timestamp.now(),
      'content': enteredMessage,
      'uid': user.uid,
      'sender_name': userData.data()!['username'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateTimestamp =
        Provider.of<UpdateUser>(context, listen: false).updateFriend;
    return Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 1,
          bottom: 10,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 200,
            minHeight: 70,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                
                  style: const TextStyle(color: Colors.white,),
                  maxLines: 5,
                  minLines: 1,
                  cursorColor: Theme.of(context).canvasColor,
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red,),
                        ),
                    
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: 'Send a message...',
                    prefixIcon: Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _submitMessage();
                  updateTimestamp(widget.userId, true);
                },
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).canvasColor,
                ),
              ),
            ],
          ),
        ),
      );
  }
}
