import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/functions/functions.dart';
import 'package:i_chat/providers/remove_from_users_provider.dart';
import 'package:i_chat/sreens/messages_screen.dart';
import 'package:i_chat/sreens/users_details_screen.dart';
import 'package:provider/provider.dart';

import '../widgets/main/app_bar_widgets.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    getFriendsIds();
    getUsersNames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool loading = true;
  final functions = Functions();

  List<String> friendUserIds = [];
  List<String> usersNames = [];
  List<String> filteredUserNames = [];
  bool showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final appBarWidgets = AppBarWidgets();

  @override
  Widget build(BuildContext context) {
    final bool bigScreen = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: showSearchBar ? true : false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        leading: showSearchBar
            ? appBarWidgets.leading(() {
                _searchController.clear();
                setState(() {
                  showSearchBar = false;
                });
              })
            : null,
        title: showSearchBar
            ? appBarWidgets.titleA((_) {
                onInteraction(_searchController.text);
              }, _searchController)
            : appBarWidgets.titleB(),
        actions: [
          IconButton(
            onPressed: () {
              showSearchBar
                  ? _searchController.clear()
                  : setState(() {
                      showSearchBar = true;
                    });
            },
            icon: Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: Icon(
                !showSearchBar
                    ? Icons.search
                    : _searchController.text.isEmpty
                        ? null
                        : Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('userId')
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
                            final bool userIsNotAllowed =
                                friendUserIds.contains(loadedUsers[index]
                                            .data()['userId']) ==
                                        true ||
                                    _searchController.text.isNotEmpty &&
                                        filteredUserNames.contains(
                                                loadedUsers[index]
                                                    .data()['username']) ==
                                            false;
                            return Column(children: [
                              userIsNotAllowed
                                  ? const SizedBox(height: 0)
                                  : Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ListTile(
                                        onTap: () {
                                          final String userName =
                                              loadedUsers[index]
                                                  .data()['username'];
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
                                              transitionDuration:
                                                  const Duration(
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
                                            color:
                                                Theme.of(context).canvasColor,
                                          ),
                                        ),
                                        textColor:
                                            Theme.of(context).canvasColor,
                                        trailing:
                                            Consumer<RemoveFromUsersProvider>(
                                                builder:
                                                    (context, value, child) {
                                          String buttonText = value
                                                  .selectedIndexes
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
                                                functions.addFriend(
                                                    context,
                                                    loadedUsers[index]
                                                        .data()['userId'],
                                                    loadedUsers[index]);
                                                createChat(loadedUsers[index]
                                                    .data()['userId']);
                                              } else {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MessagesScreen(
                                                      loadedUsers[index]
                                                          ['userId'],
                                                      loadedUsers[index]
                                                          ['username'],
                                                      loadedUsers[index]
                                                          ['imageUrl'],
                                                      loadedUsers[index]
                                                          ['about'],
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              buttonText,
                                              style: TextStyle(
                                                fontSize: bigScreen ? 19 : 16,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }),
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

  void createChat(String recieverId) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final String senderId = currentUser.uid;
    final String chatUniqueId = recieverId + senderId;
    FirebaseFirestore.instance.collection('message').doc(chatUniqueId).set({
      'createdAt': Timestamp.now(),
      'last_message': '',
    });
  }

  ///<<<<<<<--------FUNCTIONS ZONE ------>>>>>>
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

  void getUsersNames() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        setState(() {
          usersNames.add(querySnapshot.docs[i]['username']);
        });
      }
    });
  }

  void onInteraction(String query) {
    final List<String> filteredNames = [];
    for (final name in usersNames) {
      if (name.toLowerCase().contains(query.toLowerCase())) {
        filteredNames.add(name);
      }
    }
    setState(() {
      filteredUserNames = filteredNames;
    });
  }
}
