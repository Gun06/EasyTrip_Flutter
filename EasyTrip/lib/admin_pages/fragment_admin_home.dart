import 'package:flutter/material.dart';
import 'activity_admin_blocked_accounts.dart';
import 'activity_admin_reported_reviews.dart';
import 'activity_admin_written_reviews.dart';
import 'activity_amdin_member_info.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 0,
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,  // TabBar의 배경색을 흰색으로 설정
              child: TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: '회원 정보'),
                  Tab(text: '작성 리뷰'),
                  Tab(text: '신고 리뷰'),
                  Tab(text: '차단 계정'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MemberInfoPage(),
                  WrittenReviewsPage(),
                  ReportedReviewsPage(),
                  BlockedAccountsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
