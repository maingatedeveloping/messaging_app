import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateUser with ChangeNotifier {
  String _docId = 'default';

  String get docId {
    return _docId;
  }

  void getDocId(String friendId) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('message').get();
    final currentUserId = FirebaseAuth.instance.currentUser!;

    final usersId = snapshot.docs.firstWhere(
      (doc) => doc.id.contains(currentUserId.uid) & doc.id.contains(friendId),
    );
    _docId = usersId.id;
    notifyListeners();
  }

  void updateFriend(String friendId, bool updateTimestamp) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final String currentUserId = currentUser.uid;
    final currentUserInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final currentUserData = currentUserInfo.data()!;
    final friendData = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .get();
    final friendInfo = friendData.data()!;
//UPDATE FRIEND INFO
    final myFriendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .get();
    final myFriendsDocId = myFriendsSnapshot.docs
        .firstWhere((doc) => doc['userId'] == friendId)
        .id;

    !updateTimestamp
        ? FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .doc(myFriendsDocId)
            .update(friendData.data()!)
        : FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .doc(myFriendsDocId)
            .update({
            "about": friendInfo['about'],
            "username": friendInfo['username'],
            "createdAt": Timestamp.now(),
          });

//UPDATE MY INFO
    final mySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .get();
    final myDocId =
        mySnapshot.docs.firstWhere((doc) => doc['userId'] == currentUserId).id;

    !updateTimestamp
        ? FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(myDocId)
            .update(currentUserInfo.data()!)
        : FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(myDocId)
            .update({
            "about": currentUserData['about'],
            "username": currentUserData['username'],
            "createdAt": Timestamp.now(),
          });
  }
}
