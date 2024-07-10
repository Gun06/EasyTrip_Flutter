import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/user.dart';
import 'admin_chat_page.dart';

class AdminUserListPage extends StatefulWidget {
  @override
  _AdminUserListPageState createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  List<User> _users = [];
  Map<int, int> _unreadMessageCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final dbHelper = DatabaseHelper.instance;
    final users = await dbHelper.getAllUsers();
    Map<int, int> unreadCounts = {};
    for (var user in users) {
      int count = await dbHelper.getUnreadMessagesCount(user.id!, 'user');
      unreadCounts[user.id!] = count;
    }
    setState(() {
      _users = users;
      _unreadMessageCounts = unreadCounts;
      _isLoading = false;
    });
  }

  void _navigateToChat(User user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminChatPage(user: user),
      ),
    );
    _loadUsers(); // Refresh the user list and unread message counts after returning from chat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('유저 목록'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
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
              trailing: _unreadMessageCounts[user.id!]! > 0
                  ? Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.chat, color: Colors.green),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        _unreadMessageCounts[user.id!].toString(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
                  : Icon(Icons.chat, color: Colors.grey),
              onTap: () => _navigateToChat(user),
            ),
          );
        },
      ),
    );
  }
}
