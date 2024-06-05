import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'pages/fragment_home.dart';
import 'pages/fragment_mypage.dart';
import 'pages/fragment_review.dart';
import 'pages/fragment_schedule.dart';
import 'pages/fragment_traffic.dart';

class MainActivity extends StatefulWidget {
  final Map<String, String> userData;

  MainActivity({required this.userData});

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2); // Home의 인덱스를 초기 인덱스로 설정
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ReviewFragment(),
          ScheduleFragment(),
          HomeFragment(),
          TrafficFragment(),
          MyPageFragment(userData: widget.userData),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        initialSelectedTab: "Home", // 초기 선택 탭을 Home으로 설정
        labels: ["Review", "Schedule", "Home", "Traffic", "My Page"],
        icons: [Icons.rate_review, Icons.schedule, Icons.home, Icons.traffic, Icons.person],
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
        onTabItemSelected: (int index) {
          setState(() {
            _tabController.index = index;
          });
        },
      ),
    );
  }
}
