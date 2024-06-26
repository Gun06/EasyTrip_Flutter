import 'package:flutter/material.dart';

import 'activity_admin_blocked_account_detail.dart';

class BlockedAccountsPage extends StatelessWidget {
  const BlockedAccountsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text('아이디: user${index + 1}'),
            subtitle: Text('차단 사유: 불법 활동'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlockedAccountDetailPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.3),
              ),
              child: Text('상세보기'),
            ),
          ),
        );
      },
    );
  }
}
