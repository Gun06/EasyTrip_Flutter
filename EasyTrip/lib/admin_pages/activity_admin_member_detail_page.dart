import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminMemberDetailPage extends StatefulWidget {
  final int userId;
  final String accessToken;

  AdminMemberDetailPage({required this.userId, required this.accessToken});

  @override
  _AdminMemberDetailPageState createState() => _AdminMemberDetailPageState();
}

class _AdminMemberDetailPageState extends State<AdminMemberDetailPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // 사용자 정보 가져오기
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/users/${widget.userId}');
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
          userData = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });

        // preferences의 categoryTitle 값을 로그로 출력
        final preferences = userData?['preferences'] ?? [];
        for (var preference in preferences) {
          final categoryTitle = preference['categoryTitle'] ?? 'Unknown';
          print("Category: $categoryTitle");
        }
      } else {
        print("Failed to fetch user data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _deleteUser(BuildContext context) async {
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/users/${widget.userId}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // 삭제 후 업데이트 신호 전달
      } else {
        print("Failed to delete user. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  Future<void> _blockUser(BuildContext context) async {
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/users/${widget.userId}/block');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // 차단 후 업데이트 신호 전달
      } else {
        print("Failed to block user. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error blocking user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final String defaultProfileImage = 'assets/ph_profile_img_01.jpg';
    final String? profileImage = userData?['profileImage'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('회원 상세 정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _deleteUser(context),
            child: Text(
              '삭제하기',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImage != null
                          ? NetworkImage(profileImage)
                          : AssetImage(defaultProfileImage) as ImageProvider,
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData?['name'] ?? 'N/A',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userData?['username']?.toString() ?? 'N/A',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow('아이디(학번)', userData?['username']?.toString() ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('이름', userData?['name'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('닉네임', userData?['nickname'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('생년월일', userData?['birth'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('전화번호', userData?['phoneNumber'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('이메일', userData?['email'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('나이', userData?['age']?.toString() ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('성별', userData?['gender'] ?? 'N/A'),
              Divider(height: 40, thickness: 1),
              _buildPreferenceSection(userData?['preferences'] ?? []),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteUser(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15.0),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        '삭제하기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _blockUser(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15.0),
                        backgroundColor: Colors.grey,
                      ),
                      child: Text(
                        '차단하기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceSection(List<dynamic> preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선호도',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            spacing: 2.0,
            runSpacing: 2.0,
            children: preferences.map<Widget>((preference) {
              final categoryTitle = preference['categoryTitle'] ?? 'Unknown';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryTitle,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  if (preference != preferences.last)
                    Text(' > ', style: TextStyle(fontSize: 12, color: Colors.black)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
