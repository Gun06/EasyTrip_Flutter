import 'package:flutter/material.dart';
import '../models/user.dart';
import '../helpers/database_helper.dart';
import 'activity_admin_member_detail_page.dart';

class AdminMemberInfoPage extends StatefulWidget {
  @override
  _AdminMemberInfoPageState createState() => _AdminMemberInfoPageState();
}

class _AdminMemberInfoPageState extends State<AdminMemberInfoPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper.instance.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _deleteUser(int userId) async {
    await DatabaseHelper.instance.deleteUser(userId);
    _loadUsers(); // 목록 새로고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.5), // 전체 배경색 흰색으로 설정
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4, // 그림자 효과 추가
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
                      builder: (context) =>
                          AdminMemberDetailPage(user: user),
                    ),
                  );
                  if (result == true) {
                    _loadUsers(); // 삭제 후 목록 새로고침
                  }
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
