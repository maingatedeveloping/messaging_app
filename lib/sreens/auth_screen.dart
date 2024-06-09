import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/main/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isAuthenticating = false;
  bool makePasswordVissible = true;
  bool _isLogIn = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUserName = '';
  File? _selectedImage;

  void makeVissible() {
    setState(() {
      makePasswordVissible = !makePasswordVissible;
    });
  }

  void submit() async {
    final validate = _formKey.currentState!.validate();

    if (!validate || !_isLogIn && _selectedImage == null) {
      //show error message...
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isAuthenticating = true;
    });
    try {
      setState(() {
        isAuthenticating = true;
      });

      if (_isLogIn) {
        //LOG USER IN
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        //CREATE USER
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance.ref().child('user_image').child(
            '${userCredentials.user!.uid}.jpg'); //this is unique for every user
        await storageRef.putFile(_selectedImage!);
        //await storageRef.delete();
        final imageUrl = await storageRef.getDownloadURL();
        final authenticatedUser = FirebaseAuth.instance.currentUser!;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUserName,
          'email': _enteredEmail,
          'imageUrl': imageUrl,
          'userId': authenticatedUser.uid.toString(),
          'about': '',
        }); //document files
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //'''
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication error'),
        ),
      );
      setState(() {
        isAuthenticating = false;
      });
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, left: 20, right: 20, bottom: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                color: Theme.of(context).colorScheme.secondary,
                margin: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key:
                          _formKey, //we get access to the form through the form key.
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, //to take as much space as needed,
                        children: [
                          if (!_isLogIn)
                            UserImagePicker(
                              onPickImage: ((pickedImage) {
                                _selectedImage = pickedImage;
                              }),
                            ),
                          const SizedBox(height: 10),
                          TextFormField(
                            cursorColor: Theme.of(context).canvasColor,
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.tertiary),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              labelText: 'Email Adress',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            autofocus: true,
                            textCapitalization: TextCapitalization.none,
                            autovalidateMode: _isLogIn
                                ? AutovalidateMode.disabled
                                : AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email adress.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          if (!_isLogIn) userNameTextField(),
                          passwordTextField(
                            makePasswordVissible,
                            () => makeVissible(),
                          ),
                          const SizedBox(height: 12),
                          if (isAuthenticating)
                            const CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          if (!isAuthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              /* style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ), */
                              child: Text(
                                _isLogIn ? 'Log In' : 'Sign Up',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: () {
                                _formKey.currentState!.reset();
                                setState(() {
                                  _isLogIn = !_isLogIn;
                                });
                              },
                              child: Text(
                                _isLogIn
                                    ? 'Create an account'
                                    : 'Already have an account? Log In',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget userNameTextField() {
    return TextFormField(
      cursorColor: Theme.of(context).canvasColor,
      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Username',
      ),
      enableSuggestions: false,
      validator: (value) {
        if (value == null || value.trim().length < 4 || value.isEmpty) {
          return 'Please enter at least 4 characters.';
        }
        return null;
      },
      onSaved: (value) {
        _enteredUserName = value!;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget passwordTextField(bool makePasswordVissible, Function func) {
    return TextFormField(
      cursorColor: Theme.of(context).canvasColor,
      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Password',
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
        suffixIcon: IconButton(
          onPressed: () => func(),
          icon: Icon(
            makePasswordVissible ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      obscureText: makePasswordVissible,
      autovalidateMode: _isLogIn
          ? AutovalidateMode.disabled
          : AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.trim().length < 6) {
          return 'Password must be at least 6 characters long.';
        }
        return null;
      },
      onSaved: (value) {
        _enteredPassword = value!;
      },
    );
  }
}
