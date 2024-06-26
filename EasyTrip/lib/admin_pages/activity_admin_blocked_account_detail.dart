import 'package:flutter/material.dart';

class BlockedAccountDetailPage extends StatelessWidget {
  const BlockedAccountDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('차단 계정 상세', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('계정 상세 정보', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('아이디: user1', style: TextStyle(fontSize: 16)),
            Text('이름: 홍길동', style: TextStyle(fontSize: 16)),
            Text('차단 사유: 불법 활동', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 차단 해제 기능 추가
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50), // 버튼 크기 설정
              ),
              child: Text('차단 해제', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
