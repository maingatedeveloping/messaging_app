import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/sreens/users_details_screen.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedUsers1;
  CustomSearchDelegate(this.loadedUsers1);

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedUsers = [];

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        return close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

//applicationUsers
  @override
  ListView buildResults(BuildContext context) {
    final bigScreen = MediaQuery.of(context).size.width > 500;
    List<QueryDocumentSnapshot<Map<String, dynamic>>> matchQuery = [];
    for (var user in loadedUsers) {
      if (user['username'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(user);
      }
    }
    return buildSearchItem(matchQuery, bigScreen);
  }

  @override
  ListView buildSuggestions(BuildContext context) {
    final bigScreen = MediaQuery.of(context).size.width > 500;
    List<QueryDocumentSnapshot<Map<String, dynamic>>> matchQuery = [];
    for (var user in loadedUsers) {
      if (user['username'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(user);
      }
    }
    return buildSearchItem(matchQuery, bigScreen);
  }

  Widget divider() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 50,
        right: 20,
        top: 0,
        bottom: 0,
      ),
      child: Divider(
        color: Color.fromARGB(171, 158, 158, 158),
      ),
    );
  }

  buildSearchItem(
    matchQuery,
    bigScreen,
  ) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              matchQuery.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      ),
                    )
                  : Offstage(
                      offstage: FirebaseAuth.instance.currentUser!.uid ==
                              matchQuery[index]['userId']
                          ? true
                          : false,
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return UsersDetailScreens(
                              userName: matchQuery[index]['username'],
                              imageUrl: 'imageurl',
                            );
                          }));
                        },
                        leading: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                        ),
                        title: Text(
                          matchQuery[index]['username'],
                          style: TextStyle(
                            color: Theme.of(context).canvasColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          'Add friend',
                          style: TextStyle(
                            fontSize: bigScreen ? 19 : 17,
                            color: Theme.of(context).canvasColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        horizontalTitleGap: 25,
                      ),
                    ),
              const SizedBox(height: 10)
            ],
          ),
        );
      },
      itemCount: matchQuery.length,
    );
  }
}
