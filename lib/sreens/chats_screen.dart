import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/providers/update_user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/main/reusable_widgets.dart';
import 'messages_screen.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({Key? key}) : super(key: key);

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late QuerySnapshot snapshot;

  @override
  void initState() {
    getSnapshot();
    super.initState();
  }

  bool initiated = false;
  String errorMessage = 'Loading chats...';

  void getSnapshot() async {
    QuerySnapshot getSnapshot =
        await FirebaseFirestore.instance.collection('message').get();
    setState(() {
      snapshot = getSnapshot;
      initiated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateUser =
        Provider.of<UpdateUser>(context, listen: false).updateFriend;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () {
          if (showProfile == true) {
            _closeProfilePic();
          } else {
            return;
          }
        },
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(10),
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
                if (friendsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }
                if (friendsSnapshot.hasError) {
                  return Center(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Theme.of(context).canvasColor),
                    ),
                  );
                }
                final loadedFriends = friendsSnapshot.data!.docs;
                return !initiated
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).canvasColor,
                            fontWeight: FontWeight.bold,
                          ),
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

                                  return ListTile(
                                    onTap: () {
                                      if (showProfile == true) {
                                        _closeProfilePic();
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              friendId,
                                              loadedFriends[index]['username'],
                                              loadedFriends[index]['imageUrl'],
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
                                          imageUrl =
                                              loadedFriends[index]['imageUrl'];
                                          username =
                                              loadedFriends[index]['username'];
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
                                        color: Theme.of(context).canvasColor,
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
                                                ? dateTime.year == now.year &&
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
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
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
      ),
    );
  }

  String imageUrl = '';
  String username = '';
  final bool secondStack = false;
  final String about = '';

  bool showProfile = false;

  void _closeProfilePic() {
    setState(() {
      showProfile = false;
    });
  }
}
