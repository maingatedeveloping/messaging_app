import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Functions {
  //<<<<<<------------- ADD FRIEND ------------------>>>>>>>
  void addFriend(BuildContext context, String recieverId,
      DocumentSnapshot<Map<String, dynamic>> friendInfo) async {
    toastMessage(context);
    final currentUser = FirebaseAuth.instance.currentUser!;
    final String senderId = currentUser.uid;
    final currentUserInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();
//Add to current user
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
//Add to friend
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

  void toastMessage(BuildContext context) {
    Fluttertoast.showToast(
      msg: 'Friend Added',
      backgroundColor: Theme.of(context).canvasColor,
      textColor: Theme.of(context).colorScheme.surface,
    );
  }
}
