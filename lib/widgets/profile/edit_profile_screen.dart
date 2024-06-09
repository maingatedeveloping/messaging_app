import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String downloadedUsername;
  final String downloadedImageUrl;
  final String about;
  const EditProfileScreen(
      this.downloadedUsername, this.downloadedImageUrl, this.about,
      {super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isSending = false;
  late File? pickedImageFile;

  @override
  void initState() {
    super.initState();
    userNameController.text = widget.downloadedUsername;
    userAboutController.text = widget.about;
    pickedImageFile = null;
  }

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userAboutController = TextEditingController();

  void updateUserInfo() async {
    final String userName = userNameController.text;
    final String userAbout = userAboutController.text;
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    if (userName.trim().isEmpty) return;
    setState(() {
      isSending = true;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(authenticatedUser.uid)
        .update({
      'username': userName,
      'about': userAbout,
    });
    setState(() {
      isSending = false;
    });
  }

  void updateUserImageUrl() async {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    if (pickedImageFile == null) {
      return;
    }
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child('${authenticatedUser.uid}.jpg');
    await storageRef.delete();
    await storageRef.putFile(pickedImageFile!);
    final imageUrl = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(authenticatedUser.uid)
        .update({
      'imageUrl': imageUrl,
    });
  }

  void toastMessage() {
    Fluttertoast.showToast(
      msg: 'Profile updated',
      backgroundColor: Theme.of(context).canvasColor,
      textColor: Theme.of(context).colorScheme.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool smallScreen = MediaQuery.of(context).size.width < 325;
    //final bool largeScreen = MediaQuery.of(context).size.width > 690;
    final Color textColor = Theme.of(context).canvasColor;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(smallScreen ? 7 : 10.0),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                color: Colors.blue,
                child: pickedImageFile != null
                    ? Image.file(pickedImageFile!)
                    : CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.downloadedImageUrl,
                        errorWidget: (context, url, error) {
                          return const SizedBox(height: 0);
                        },
                      ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Change profile',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: smallScreen ? 15 : 20,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(smallScreen ? 7 : 10.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).canvasColor),
                            ),
                            onPressed: pickImageFromCamera,
                            child: Text(
                              'Camera',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(smallScreen ? 7 : 10),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Theme.of(context).canvasColor),
                            ),
                            onPressed: pickImageFromGallery,
                            child: Text(
                              'Gallery',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    isSending
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          )
                        : const SizedBox(height: 0)
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: userNameController,
                cursorColor: Theme.of(context).canvasColor,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Change Username',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: textColor,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: userAboutController,
                cursorColor: Theme.of(context).canvasColor,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '   What\'s on your mind',
                  hintStyle: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  labelText: 'About',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: textColor,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        updateUserInfo();
                        updateUserImageUrl();
                        toastMessage();
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: 720,
      maxHeight: 720,
    );
    if (pickedImage == null) return;

    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
  }

  void pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 720,
      maxHeight: 720,
    );

    if (pickedImage == null) return;
    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
  }
}
