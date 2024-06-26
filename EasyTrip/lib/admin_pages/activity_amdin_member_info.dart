import 'package:flutter/material.dart';

class MemberInfoPage extends StatelessWidget {
  const MemberInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.8),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              title: Text('회원 아이디: user${index + 1}'),
              subtitle: Text('이름: 홍길동'),
              trailing: ElevatedButton(
                onPressed: () {
                  // 회원 상세정보 페이지로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.7),
                ),
                child: Text(
                  '상세보기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
