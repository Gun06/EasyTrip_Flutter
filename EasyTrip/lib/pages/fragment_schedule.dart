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
        automaticallyImplyLeading: true, // back 버튼 표시
        centerTitle: true, // 이 속성으로 제목을 가운데로 정렬
        title: Text(
          'Schedule',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: <Widget>[
                Icon(Icons.notifications_none, color: Colors.black),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // 알림 버튼 누를 때의 동작 추가
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200, // 원하는 높이로 고정
              child: CustomWeeklyCalendar(), // CustomWeeklyCalendar 위젯 사용
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // 왼쪽 여유값 추가
                  child: Text(
                    '내 일정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0), // 오른쪽 여유값 추가
                  child: Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildRecommendedItem(
                    context,
                    '북한산',
                    'Panjer, South Denpasar',
                    '3.3 km',
                    'https://via.placeholder.com/150',
                  ),
                  _buildRecommendedItem(
                    context,
                    '정동진 해변',
                    'Sanur, South Denpasar',
                    '10.4 km',
                    'https://via.placeholder.com/150',
                  ),
                  _buildRecommendedItem(
                    context,
                    '정동진 해변',
                    'Sanur, South Denpasar',
                    '10.4 km',
                    'https://via.placeholder.com/150',
                  ),
                  _buildRecommendedItem(
                    context,
                    '정동진 해변',
                    'Sanur, South Denpasar',
                    '10.4 km',
                    'https://via.placeholder.com/150',
                  ),
                  _buildRecommendedItem(
                    context,
                    '정동진 해변',
                    'Sanur, South Denpasar',
                    '10.4 km',
                    'https://via.placeholder.com/150',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedItem(BuildContext context, String title, String location,
      String distance, String imageUrl) {
    return Card(
      color: Colors.white,
      // 배경을 흰색으로 설정
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  distance,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                // 자세히 버튼 클릭 시 동작
              },
              child: Text(
                '자세히',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
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
      // 다른 지원 언어 추가
    ],
  ));
}
