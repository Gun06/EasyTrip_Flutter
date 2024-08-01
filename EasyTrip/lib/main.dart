import 'package:flutter/material.dart';
import 'activity_preference_1.dart';
import 'activity_preference_2.dart';
import 'activity_preference_3.dart';
import 'activity_preference_4.dart';
import 'activity_start_page.dart';
import 'admin_pages/admin.dart';
import 'activity_login.dart';
import 'activity_sign_up.dart';
import 'pages/activity_main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<MainActivityState> mainActivityKey = GlobalKey<MainActivityState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => StartPageActivity(),
        '/login': (context) => LoginActivity(),
        '/admin': (context) => AdminPage(),
        '/step1': (context) => PreferencePage1(),
        '/step2': (context) => PreferencePage2(),
        '/step3': (context) => PreferencePage3(activityPreferences: []),
        '/step4': (context) => PreferencePage4(activityPreferences: [], foodPreferences: []),
        '/signup': (context) => SignUpActivity(activityPreferences: [], foodPreferences: [], accommodationPreferences: []),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final userId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => MainActivity(userId: userId, key: mainActivityKey),
          );
        }
        return null;
      },
    );
  }
}