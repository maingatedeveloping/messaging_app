import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/sreens/chats_screen.dart';
import 'package:i_chat/sreens/users_screen.dart';
import 'package:i_chat/sreens/settings_screen.dart';
import 'package:i_chat/widgets/main/app_bar_widgets.dart';

import '../../sreens/search_delegate_screen.dart';

class TabsWidget extends StatefulWidget {
  const TabsWidget({super.key});

  @override
  State<TabsWidget> createState() => _TabBarState();
}

class _TabBarState extends State<TabsWidget> {
  late List<Map<String, dynamic>> _pages;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedUsers;

  @override
  void initState() {
    _pages = [
      {
        'page': const ChatsScreen(),
      },
      {
        'page': const UsersScreen(),
      },
      {
        'page': const UserAccount(),
      },
    ];
    super.initState();
  }

  void loadUsers() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      loadedUsers = querySnapshot.docs.toList();
    });
  }

  @override
  void didChangeDependencies() {
    loadUsers();
    super.didChangeDependencies();
  }

  int _slectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _slectedPageIndex = index; //the index of the tapped tab
    });
  }

  void funcA() {
    //print('firts search');
  }

  void funcB() {
    showSearch(context: context, delegate: CustomSearchDelegate(loadedUsers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _slectedPageIndex == 2
          ? AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              title: AppBarWidgets().titleB(),
            )
          : null,
      body: _pages[_slectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          backgroundColor: Theme.of(context).colorScheme.surface,
          unselectedItemColor: Theme.of(context).canvasColor,
          selectedItemColor: Theme.of(context).primaryColor,
          //type: BottomNavigationBarType.shifting,
          currentIndex: _slectedPageIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
              label: 'Settings',
            ),
          ]),
    );
  }
}
