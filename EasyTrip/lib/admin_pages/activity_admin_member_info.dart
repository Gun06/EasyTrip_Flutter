import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'activity_admin_member_detail_page.dart';

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
        // UTF-8 디코딩 처리
        final List<dynamic> users = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          _users = users;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("사용자 목록을 불러오지 못했습니다. 상태 코드: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("사용자 목록 가져오는 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(child: Text("사용자를 찾을 수 없습니다."))
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
                '아이디: ${user['username'] ?? "N/A"}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '이름: ${user['name'] ?? "N/A"}\n닉네임: ${user['nickname'] ?? "N/A"}',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  final userId = user['id'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminMemberDetailPage(
                        userId: userId,
                        accessToken: widget.accessToken,
                      ),
                    ),
                  );
                },
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
