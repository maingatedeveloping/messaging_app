import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/main/my_homepage.dart';

class SplahScreen extends StatefulWidget {
  const SplahScreen({super.key});

  @override
  State<SplahScreen> createState() => _SplahScreenState();
}

class _SplahScreenState extends State<SplahScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _navigateToHome();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _navigateToHome() async {
    await Future.delayed(
      const Duration(milliseconds: 2000),
      () {},
    );
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: ((context, animation, secondaryAnimation) {
          return const MyHomePage();
        }),
        transitionDuration: const Duration(
          microseconds: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 320;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, left: 20, right: 20, bottom: 20),
                width: 150,
                child: Image.asset('assets/images/chat.png'),
              ),
              const SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                'Chat with friends, share images and videos',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  fontSize: isSmallScreen ? 21 : 24,
                  color: Colors.white,
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
