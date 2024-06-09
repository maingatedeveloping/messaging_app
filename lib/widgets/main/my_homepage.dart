import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_chat/sreens/splash_screen.dart';

import '../../sreens/auth_screen.dart';
import '../theme/theme.dart';
import 'tabs_widget.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterChat',
      theme: darkMode,
      home: const SplahScreen(),
    );
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplahScreen();
        }
        if (snapshot.hasData) {
          return const TabsWidget();
        }
        return const AuthScreen();
      }),
    );
  }
}
