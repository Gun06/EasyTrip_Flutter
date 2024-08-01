import 'package:flutter/material.dart';
import 'dart:async';
import '../activity_login.dart';

class StartPageActivity extends StatefulWidget {
  @override
  _StartPageActivityState createState() => _StartPageActivityState();
}

class _StartPageActivityState extends State<StartPageActivity> {
  @override
  void initState() {
    super.initState();
    // 3초 후에 로그인 페이지로 이동
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginActivity(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/ic_ez.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}