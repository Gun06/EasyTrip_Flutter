import 'package:flutter/material.dart';
import 'activity_amdin_member_info.dart';

class FragmentAdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          children: [
            // 배경 이미지 추가
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'), // 배경 이미지 경로
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  color: Colors.white.withOpacity(0.9), // 색상 변경 및 투명도 추가
                  child: TabBar(
                    labelColor: Colors.black,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(text: '회원정보'),
                      Tab(text: '신고리뷰'),
                      Tab(text: '신고계정'),
                      Tab(text: '차단계정'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      AdminMemberInfoPage(),
                      Center(child: Text('신고리뷰 페이지 구현')),
                      Center(child: Text('신고계정 페이지 구현')),
                      Center(child: Text('차단계정 페이지 구현')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
