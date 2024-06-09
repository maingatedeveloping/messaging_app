import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:i_chat/providers/remove_from_users_provider.dart';
import 'package:i_chat/sreens/messages_screen.dart';
import 'package:i_chat/sreens/users_details_screen.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getFriendsIds();
  }

  int indexToRemove = -100;
  void createChat(String recieverId) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final String senderId = currentUser.uid;
    final String chatUniqueId = recieverId + senderId;
    FirebaseFirestore.instance.collection('message').doc(chatUniqueId).set({
      'createdAt': Timestamp.now(),
      'last_message': '',
    });
  }

  List<String> friendUserIds = [
    'sHoaW2K7geT6gtGhlmacQXT80363',
  ];

  void getFriendsIds() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        setState(() {
          friendUserIds.add(querySnapshot.docs[i]['userId']);
        });
      }
    });
    setState(() {
      loading = false;
    });
  }

  void addFriend(String recieverId,
      DocumentSnapshot<Map<String, dynamic>> friendInfo) async {
    toastMessage();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final String senderId = currentUser.uid;
    final currentUserInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();
//add to current user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .add({
      'about': friendInfo.data()!['about'],
      'email': friendInfo.data()!['email'],
      'imageUrl': friendInfo.data()!['imageUrl'],
      'userId': friendInfo.data()!['userId'],
      'username': friendInfo.data()!['username'],
      'createdAt': Timestamp.now(),
    });
//add to friend
    await FirebaseFirestore.instance
        .collection('users')
        .doc(recieverId)
        .collection('friends')
        .add({
      'about': currentUserInfo.data()!['about'],
      'email': currentUserInfo.data()!['email'],
      'imageUrl': currentUserInfo.data()!['imageUrl'],
      'userId': currentUserInfo.data()!['userId'],
      'username': currentUserInfo.data()!['username'],
      'createdAt': Timestamp.now(),
    });
  }

  void toastMessage() {
    Fluttertoast.showToast(
      msg: 'Friend Added',
      backgroundColor: Theme.of(context).canvasColor,
      textColor: Theme.of(context).colorScheme.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool bigScreen = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('userId', whereNotIn: friendUserIds)
                .snapshots(),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ));
              }
              if (usersSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Something went wrong.',
                    style: TextStyle(color: Theme.of(context).canvasColor),
                  ),
                );
              }

              final loadedUsers = usersSnapshot.data!.docs;

              return loading
                  ? Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(
                          color: Theme.of(context).canvasColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : loadedUsers.length == 1
                      ? Center(
                          child: Text(
                            'No user found.',
                            style: TextStyle(
                              color: Theme.of(context).canvasColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: loadedUsers.length,
                          itemBuilder: (context, index) {
                            return Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Offstage(
                                  offstage:
                                      FirebaseAuth.instance.currentUser!.uid ==
                                                  loadedUsers[index]
                                                      .data()['userId'] ||
                                              friendUserIds.contains(
                                                  loadedUsers[index]
                                                      .data()['userId'])
                                          ? true
                                          : false,
                                  child: ListTile(
                                    onTap: () {
                                      final String userName =
                                          loadedUsers[index].data()['username'];
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: ((context, animation,
                                              sencondaryAnimation) {
                                            return UsersDetailScreens(
                                              userName: userName,
                                              imageUrl: loadedUsers[index]
                                                  .data()['imageUrl'],
                                            );
                                          }),
                                          transitionDuration: const Duration(
                                            microseconds: 0,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          loadedUsers[index]
                                              .data()['imageUrl']),
                                    ),
                                    title: Text(
                                      loadedUsers[index]['username'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).canvasColor,
                                      ),
                                    ),
                                    textColor: Theme.of(context).canvasColor,
                                    trailing: Consumer<RemoveFromUsersProvider>(
                                        builder: (context, value, child) {
                                      String buttonText = value.selectedIndexes
                                              .contains(loadedUsers[index]
                                                  .data()['userId'])
                                          ? "Message"
                                          : '+Add Friend';
                                      return TextButton(
                                        onPressed: () {
                                          if (buttonText == '+Add Friend') {
                                            value.updateButton(
                                                loadedUsers[index]
                                                    .data()['userId']);
                                            addFriend(
                                                loadedUsers[index]
                                                    .data()['userId'],
                                                loadedUsers[index]);
                                            createChat(loadedUsers[index]
                                                .data()['userId']);
                                          } else {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                  loadedUsers[index]['userId'],
                                                  loadedUsers[index]
                                                      ['username'],
                                                  loadedUsers[index]
                                                      ['imageUrl'],
                                                  loadedUsers[index]['about'],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          buttonText,
                                          style: TextStyle(
                                            fontSize: bigScreen ? 19 : 16,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4)
                            ]);
                          },
                        );
            }),
      ),
    );
  }
}
