import 'package:flutter/material.dart';

class FragmentAdminProfile extends StatelessWidget {
  const FragmentAdminProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(height: 16),
            Text(
              'user1',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '차단된 계정',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('상세정보'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 상세정보 페이지로 이동
              },
            ),
            ListTile(
              title: Text('작성된 리뷰'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 작성된 리뷰 페이지로 이동
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 차단 해제 기능 추가
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50), // 버튼 크기 설정
              ),
              child: Text('차단 해제',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}