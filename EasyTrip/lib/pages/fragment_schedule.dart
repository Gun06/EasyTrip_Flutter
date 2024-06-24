import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../Custom_WeeklyCalendar.dart';

class ScheduleFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // back 버튼 제거
        centerTitle: true, // 이 속성으로 제목을 가운데로 정렬
        title: Text(
          'Schedule',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: TextButton(
          onPressed: _editSchedule,
          child: Text(
            '수정',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _viewMySchedule,
            child: Text(
              '내 일정',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomWeeklyCalendar(), // CustomWeeklyCalendar 위젯 사용
      ),
    );
  }

  void _editSchedule() {
    // 일정 수정 함수 구현
  }

  void _viewMySchedule() {
    // 내 일정 보기 함수 구현
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
