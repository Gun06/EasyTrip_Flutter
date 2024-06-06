import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../Custom_WeeklyCalendar.dart';

class ScheduleFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomWeeklyCalendar(), // CustomWeeklyCalendar 위젯 사용
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ScheduleFragment(),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', 'US'), // English
      const Locale('ko', 'KR'), // Korean
      // Add other supported locales here
    ],
  ));
}
