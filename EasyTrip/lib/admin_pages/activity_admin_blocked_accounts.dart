import 'package:flutter/material.dart';
import '../models/user.dart';
import '../helpers/database_helper.dart';
import 'activity_admin_blocked_account_detail.dart';

class AdminBlockedAccountsPage extends StatefulWidget {
  @override
  _AdminBlockedAccountsPageState createState() => _AdminBlockedAccountsPageState();
}

class _AdminBlockedAccountsPageState extends State<AdminBlockedAccountsPage> {
  List<User> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final blockedUsers = await DatabaseHelper.instance.getBlockedUsers();
    setState(() {
      _blockedUsers = blockedUsers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              title: Text(
                'ID: ${user.id}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '이름: ${user.name}\n닉네임: ${user.nickname}',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminBlockedAccountDetailPage(user: user),
                    ),
                  );
                  if (result == true) {
                    _loadBlockedUsers();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.7),
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
