import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/widgets/profile/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/main/reusable_widgets.dart';
import '../widgets/profile/edit_profile_screen.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  bool showPic = false;
  void _closeProfilePic() {
    setState(() {
      showPic = false;
    });
  }

  String? userName;
  String? userImage;
  String? userAbout;

  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final String uniqueNameIdentifier = user.uid;
    if (prefs.containsKey(uniqueNameIdentifier)) {
      setState(() {
        userName = prefs.getString(uniqueNameIdentifier);
      });
    } else {
      setState(() {
        userName = userData.data()!['username'];
      });
      prefs.setString(uniqueNameIdentifier, userName!);
    }
    setState(() {
      userImage = userData.data()!['imageUrl'];
      userAbout = userData.data()!['about'];
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  final bool secondStack = true;
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return GestureDetector(
      onTap: () {
        _closeProfilePic();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              return Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            if (showPic == true) {
                              _closeProfilePic();
                            } else {
                              final user = snapshot.data!;
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: ((context, animation,
                                      secondaryAnimation) {
                                    return EditProfileScreen(user['username'],
                                        user['imageUrl'], user['about']);
                                  }),
                                  transitionDuration: const Duration(
                                    microseconds: 0,
                                  ),
                                ),
                              );
                            }
                          },
                          leading: InkWell(
                            onTap: () {
                              setState(() {
                                showPic = !showPic;
                              });
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: userImage == null
                                  ? null
                                  : CachedNetworkImageProvider(
                                      snapshot.data!['imageUrl']),
                            ),
                          ),
                          title: userName == null
                              ? Text(
                                  '...',
                                  style: TextStyle(
                                      color: Theme.of(context).canvasColor),
                                )
                              : Text(
                                  snapshot.data!['username'],
                                  style: TextStyle(
                                    color: Theme.of(context).canvasColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          subtitle: Text(
                            userAbout != null
                                ? snapshot.data!['about']
                                : 'Available',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 1,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 26,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppThemeMode(closeProfilePic: _closeProfilePic),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: Icon(
                            Icons.exit_to_app,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          title: InkWell(
                            onTap: () {
                              FirebaseAuth.instance.signOut();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Log Out',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                showPic
                    ? stackPhoto(
                        context,
                        _closeProfilePic,
                        secondStack,
                        snapshot.data!['imageUrl'],
                        snapshot.data!['username'],
                        snapshot.data!['about'])
                    : Container(),
              ]);
            }),
      ),
    );
  }
}
