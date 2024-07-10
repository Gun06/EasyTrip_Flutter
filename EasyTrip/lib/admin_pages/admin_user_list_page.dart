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
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.nickname),
            subtitle: Text('ID: ${user.id}'),
            trailing: _unreadMessageCounts[user.id!]! > 0
                ? CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                _unreadMessageCounts[user.id!].toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
                : null,
            onTap: () => _navigateToChat(user),
          );
        },
      ),
    );
  }
}
