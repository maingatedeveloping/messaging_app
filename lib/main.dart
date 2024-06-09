import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_chat/providers/update_user_provider.dart';
import 'package:i_chat/providers/view_profile_provider.dart';
import 'providers/remove_from_users_provider.dart';
import 'package:i_chat/sreens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_providers.dart';
import 'widgets/main/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => RemoveFromUsersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UpdateUser(),
        ),
        ChangeNotifierProvider(
          create: (context) => ViewProfileProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color.fromARGB(255, 200, 199, 199),
      systemNavigationBarColor: Colors.grey[900]!,
      //systemNavigationBarColor: const Color.fromARGB(255, 200, 199, 199),
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterChat',
      theme: Provider.of<ThemeProvider>(
        context,
        listen: true,
      ).appTheme,
      home: const SplahScreen(),
    );
  }
}
