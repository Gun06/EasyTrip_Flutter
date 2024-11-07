import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'HomePage/fragment_home.dart';
import 'MyPage/fragment_mypage.dart';
import 'ReviewPage/fragment_review.dart';
import 'SchedulePage/fragment_schedule.dart';
import 'TrafficPage/fragment_traffic.dart';

class MainActivity extends StatefulWidget {
  final int userId;

  MainActivity({required this.userId, Key? key}) : super(key: key);

  @override
  MainActivityState createState() => MainActivityState();
}

class MainActivityState extends State<MainActivity> {
  int _selectedIndex = 2; // Home의 인덱스를 초기 인덱스로 설정

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ReviewFragment(),
      ScheduleFragment(),
      HomeFragment(),
      TrafficFragment(),
      MyPageFragment(userId: widget.userId), // userId 전달
    ];
  }

  void _onTabItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => _pages[_selectedIndex],
          );
        },
      ),
      bottomNavigationBar: MotionTabBar(
        initialSelectedTab: "Home", // 초기 선택 탭을 Home으로 설정
        labels: ["Review", "Schedule", "Home", "Traffic", "My Page"],
        icons: [
          Icons.rate_review,
          Icons.schedule,
          Icons.home,
          Icons.traffic,
          Icons.person
        ],
        tabSize: 50,
        tabBarHeight: 60,
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        tabIconColor: Colors.grey,
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: Colors.blue,
        tabIconSelectedColor: Colors.white,
        tabBarColor: Colors.white,
        onTabItemSelected: _onTabItemSelected,
      ),
    );
  }
}
