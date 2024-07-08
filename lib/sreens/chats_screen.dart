import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/widgets/main/app_bar_widgets.dart';
import 'package:i_chat/widgets/main/chat_screen_content.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_providers.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void dispose() {
    friendsNames.clear();
    filteredFriendsNames.clear();
    super.dispose();
  }

  @override
  void initState() {
    getValue();
    getFriendsNames();
    super.initState();
  }

  void getValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final fetchedVal = prefs.getString('groupvalue');
    if (fetchedVal != null) {
      fetchedVal == 'light'
          ? Provider.of<ThemeProvider>(context, listen: false).changeToLight()
          : Provider.of<ThemeProvider>(context, listen: false).changeToDark();
    }
  }

  bool initiated = false;
  String errorMessage = 'Loading chats...';

  List<String> friendsNames = [];
  List<String> filteredFriendsNames = [];
  bool showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final appBarWidgets = AppBarWidgets();
  @override
  Widget build(BuildContext context) {
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
      body: ChatScreenContent(filteredFriendsNames, _searchController),
    );
  }

  String imageUrl = '';
  String username = '';
  final bool secondStack = false;
  final String about = '';

  bool showProfile = false;

  //<<<<<------------FUNCTIONS ZONE-------->>>

  void getFriendsNames() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        setState(() {
          friendsNames.add(querySnapshot.docs[i]['username']);
        });
      }
    });
  }

  void onInteraction(String query) {
    final List<String> filteredNames = [];
    for (final name in friendsNames) {
      if (name.toLowerCase().contains(query.toLowerCase())) {
        filteredNames.add(name);
      }
    }
    setState(() {
      filteredFriendsNames = filteredNames;
    });
  }
}
