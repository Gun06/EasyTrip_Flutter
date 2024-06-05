import 'package:flutter/material.dart';
import 'pages/activity_start_page.dart';
import 'activity_login.dart';
import 'pages/activity_preference_1.dart';
import 'pages/activity_preference_2.dart';
import 'pages/activity_preference_3.dart';
import 'pages/activity_preference_4.dart';
import 'activity_sign_up.dart';
import 'activity_main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => StartPageActivity(),
        '/login': (context) => LoginActivity(),
        '/step1': (context) => PreferencePage1(),
        '/step2': (context) => PreferencePage2(),
        '/step3': (context) => PreferencePage3(),
        '/step4': (context) => PreferencePage4(),
        '/signup': (context) => SignUpActivity(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final userData = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => MainActivity(userData: userData),
          );
        }
        return null;
      },
    );
  }
}
