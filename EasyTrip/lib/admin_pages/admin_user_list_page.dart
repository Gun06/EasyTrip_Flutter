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

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final dbHelper = DatabaseHelper.instance;
    final users = await dbHelper.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  void _navigateToChat(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminChatPage(user: user),
      ),
    );
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
            onTap: () => _navigateToChat(user),
          );
        },
      ),
    );
  }
}
