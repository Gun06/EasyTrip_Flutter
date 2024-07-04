import 'package:flutter/material.dart';
import '../models/user.dart';
import '../helpers/database_helper.dart';

class AdminBlockedAccountDetailPage extends StatelessWidget {
  final User user;

  const AdminBlockedAccountDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 기본 프로필 이미지 설정
    final String defaultProfileImage = 'assets/ph_profile_img_01.jpg';
    final String? profileImage = user.profileImage;

    // 나이 계산
    int _calculateAge(String birthDate) {
      final now = DateTime.now();
      final birthYear = int.parse(birthDate.substring(0, 2)) + 2000;
      return now.year - birthYear;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('차단된 계정 정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.unblockUser(user.id!);
              Navigator.pop(context, true);  // 차단 해제 후 true를 반환하여 업데이트 신호 전달
            },
            child: Text(
              '차단 해제',
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
                      backgroundImage: profileImage != null && profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : AssetImage(defaultProfileImage) as ImageProvider,
                    ),
                    SizedBox(height: 10),
                    Text(
                      user.name,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.id.toString(),
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow('아이디(학번)', user.id.toString()),
              SizedBox(height: 20),
              _buildDetailRow('이름', user.name),
              SizedBox(height: 20),
              _buildDetailRow('닉네임', user.nickname),
              SizedBox(height: 20),
              _buildDetailRow('생년월일', user.birthDate),
              SizedBox(height: 20),
              _buildDetailRow('전화번호', user.phoneNumber),
              SizedBox(height: 20),
              _buildDetailRow('나이', _calculateAge(user.birthDate).toString()), // 추가된 부분
              SizedBox(height: 20),
              _buildDetailRow('성별', user.gender), // 추가된 부분
              SizedBox(height: 40), // 간격 조정
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await DatabaseHelper.instance.unblockUser(user.id!);
                    Navigator.pop(context, true);  // 차단 해제 후 true를 반환하여 업데이트 신호 전달
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0),
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    '차단 해제',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
          width: 100, // 레이블의 고정된 넓이
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10), // 간격 조정
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
}
