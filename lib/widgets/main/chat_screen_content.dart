import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/update_user_provider.dart';
import '../../sreens/messages_screen.dart';
import 'reusable_widgets.dart';

class ChatScreenContent extends StatefulWidget {
  final List<String> filteredFriendsNames;
  final TextEditingController controller;
  const ChatScreenContent(this.filteredFriendsNames, this.controller,
      {super.key});

  @override
  State<ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<ChatScreenContent> {
  @override
  void initState() {
    getSnapshot();
    super.initState();
  }

  late QuerySnapshot snapshot;

  void getSnapshot() async {
    QuerySnapshot getSnapshot =
        await FirebaseFirestore.instance.collection('message').get();
    setState(() {
      snapshot = getSnapshot;
      initiated = true;
    });
  }

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool initiated = false;
  String pendingMessage = 'An error occured!.';
  @override
  Widget build(BuildContext context) {
    final updateUser =
        Provider.of<UpdateUser>(context, listen: false).updateFriend;

    return GestureDetector(
      onTap: () {
        if (showProfile == true) {
          _closeProfilePic();
        } else {
          return;
        }
      },
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('friends')
                .orderBy(
                  'createdAt',
                  descending: true,
                )
                .snapshots(),
            builder: (context, friendsSnapshot) {
              if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }
              if (friendsSnapshot.hasError) {
                return Center(
                  child: Text(
                    pendingMessage,
                    style: TextStyle(color: Theme.of(context).canvasColor),
                  ),
                );
              }
              final loadedFriends = friendsSnapshot.data!.docs;
              return !initiated
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    )
                  : loadedFriends.isEmpty
                      ? Center(
                          child: Text(
                            'You have no friends.',
                            style: TextStyle(
                              color: Theme.of(context).canvasColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: loadedFriends.length,
                          itemBuilder: (context, index) {
                            final friendId = loadedFriends[index]['userId'];
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('message')
                                  .doc(snapshot.docs
                                      .firstWhere((doc) =>
                                          doc.id.contains(currentUserId) &
                                          doc.id.contains(friendId))
                                      .id)
                                  .snapshots(),
                              builder: (context, messageSnapshot) {
                                if (messageSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('');
                                }
                                final lastMessage =
                                    messageSnapshot.data?['last_message'];
                                final timestamp =
                                    messageSnapshot.data?['createdAt'];
                                final DateTime dateTime = timestamp.toDate();
                                String formattedTime =
                                    DateFormat('h:m a').format(dateTime);
                                String formattedDate =
                                    DateFormat('d/MM/yy').format(dateTime);
                                DateTime now = DateTime.now();

                                return widget.controller.text.isNotEmpty &&
                                        widget.filteredFriendsNames.contains(
                                                loadedFriends[index]
                                                    ['username']) ==
                                            false
                                    ? const SizedBox()
                                    : ListTile(
                                        onTap: () {
                                          if (showProfile == true) {
                                            _closeProfilePic();
                                          } else {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MessagesScreen(
                                                  friendId,
                                                  loadedFriends[index]
                                                      ['username'],
                                                  loadedFriends[index]
                                                      ['imageUrl'],
                                                  loadedFriends[index]['about'],
                                                ),
                                              ),
                                            );
                                            updateUser(friendId, false);
                                          }
                                        },
                                        leading: InkWell(
                                          onTap: () {
                                            setState(() {
                                              showProfile = !showProfile;
                                              imageUrl = loadedFriends[index]
                                                  ['imageUrl'];
                                              username = loadedFriends[index]
                                                  ['username'];
                                            });
                                          },
                                          child: CircleAvatar(
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            radius: 25,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    loadedFriends[index]
                                                        ['imageUrl']),
                                          ),
                                        ),
                                        title: Text(
                                          loadedFriends[index]['username'],
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).canvasColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          lastMessage.isNotEmpty
                                              ? lastMessage
                                              : 'No messages yet',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                        trailing: lastMessage.isNotEmpty
                                            ? Text(
                                                timestamp != null
                                                    ? dateTime.year ==
                                                                now.year &&
                                                            dateTime.month ==
                                                                now.month &&
                                                            dateTime.day ==
                                                                now.day - 1
                                                        ? 'Yesterday'
                                                        : dateTime.year ==
                                                                    now.year &&
                                                                dateTime.month ==
                                                                    now.month &&
                                                                dateTime.day ==
                                                                    now.day
                                                            ? formattedTime
                                                            : formattedDate
                                                    : "",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : const Text(''),
                                      );
                              },
                            );
                          },
                        );
            },
          ),
        ),
        showProfile
            ? stackPhoto(context, _closeProfilePic, secondStack, imageUrl,
                username, about)
            : Container(),
      ]),
    );
  }

  bool showProfile = false;
  String imageUrl = '';
  String username = '';
  final bool secondStack = false;
  final String about = '';

  //<<<<<------------FUNCTIONS ZONE-------->>>>
  void _closeProfilePic() {
    setState(() {
      showProfile = false;
    });
  }
}
