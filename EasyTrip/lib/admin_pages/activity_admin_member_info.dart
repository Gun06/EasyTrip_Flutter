import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminMemberInfoPage extends StatefulWidget {
  final String accessToken;

  AdminMemberInfoPage({required this.accessToken});

  @override
  _AdminMemberInfoPageState createState() => _AdminMemberInfoPageState();
}

class _AdminMemberInfoPageState extends State<AdminMemberInfoPage> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/users');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _users = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Failed to load users. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching users: $e");
    }
  }

  Future<void> _fetchUserDetails(String username) async {
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/users/$username');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMemberDetailPage(userData: userData),
          ),
        );
      } else {
        print("Failed to fetch user details. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(child: Text("No users found."))
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
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
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              title: Text(
                'ID: ${user['username']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '이름: ${user['name']}\n닉네임: ${user['nickname']}',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: ElevatedButton(
                onPressed: () => _fetchUserDetails(user['username']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.7),
                ),
                child: Text(
                  '상세보기',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminMemberDetailPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  AdminMemberDetailPage({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${userData['username']} 상세 정보'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${userData['username']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('이름: ${userData['name']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('닉네임: ${userData['nickname']}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
