import 'package:flutter/material.dart';
import 'activity_admin_member_info.dart';
import 'activity_admin_user_schedule.dart';

class FragmentAdminHome extends StatelessWidget {
  final String accessToken;

  FragmentAdminHome({required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.white.withOpacity(0.9), // 색상 변경 및 투명도 추가
              child: TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: '회원정보'),
                  Tab(text: '일정정보'),
                  Tab(text: 'SNS정보'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white, // 배경색 추가
                child: TabBarView(
                  children: [
                    AdminMemberInfoPage(accessToken: accessToken),
                    UserSchedulePage(accessToken: accessToken,),
                    Center(child: Text('신고계정 없음')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
