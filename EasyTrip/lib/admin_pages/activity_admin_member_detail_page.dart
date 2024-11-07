import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminMemberDetailPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String accessToken;

  AdminMemberDetailPage({required this.userData, required this.accessToken});

  Future<void> _deleteUser(BuildContext context) async {
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/users/${userData['id']}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
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
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/users/${userData['id']}/block');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
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
    final String defaultProfileImage = 'assets/150.png';
    final String? profileImage = userData['profileImage'] ?? defaultProfileImage;

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
                      backgroundImage: NetworkImage(profileImage ?? defaultProfileImage),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData['name'] ?? 'N/A',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userData['id']?.toString() ?? 'N/A',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow('아이디(학번)', userData['id']?.toString() ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('이름', userData['name'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('닉네임', userData['nickname'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('생년월일', userData['birthDate'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('전화번호', userData['phoneNumber'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('이메일', userData['email'] ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('나이', userData['age']?.toString() ?? 'N/A'),
              SizedBox(height: 20),
              _buildDetailRow('성별', userData['gender'] ?? 'N/A'),
              Divider(height: 40, thickness: 1),
              _buildPreferenceSection('활동 선호도', userData['activityPreferences'] ?? []),
              SizedBox(height: 20),
              _buildPreferenceSection('음식 선호도', userData['foodPreferences'] ?? []),
              SizedBox(height: 20),
              _buildPreferenceSection('숙박 선호도', userData['accommodationPreferences'] ?? []),
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

  Widget _buildPreferenceSection(String title, List<dynamic> preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      preference.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Text(
                      '>',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
