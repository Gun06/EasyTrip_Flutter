import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final Map<String, String> userData;

  EditProfilePage({required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late String _selectedGender;
  late String _selectedAge;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _studentIdController = TextEditingController(text: widget.userData['studentId']);
    _passwordController = TextEditingController(text: widget.userData['password']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _selectedGender = widget.userData['gender'] ?? '남성';
    _selectedAge = widget.userData['age'] ?? '18';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Image picker error: $e');
    }
  }

  void _saveProfile() {
    final String name = _nameController.text.trim();
    final String studentId = _studentIdController.text.trim();
    final String password = _passwordController.text.trim();
    final String phone = _phoneController.text.trim();
    final bool pwCheck = RegExp(r'^(?=.*\d)(?=.*[~`!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$').hasMatch(password);

    if (name.isEmpty || studentId.isEmpty || password.isEmpty || phone.isEmpty) {
      Fluttertoast.showToast(msg: '빈칸 없이 모두 입력하세요!');
      return;
    }

    if (_selectedGender.isEmpty) {
      Fluttertoast.showToast(msg: '성별을 선택해주세요!');
      return;
    }

    if (_selectedAge.isEmpty) {
      Fluttertoast.showToast(msg: '나이를 선택해주세요!');
      return;
    }

    if (!pwCheck) {
      Fluttertoast.showToast(msg: '비밀번호는 8자 이상의 숫자와 영문, 특수문자 조합이어야 합니다!');
      return;
    }

    setState(() {
      widget.userData['name'] = name;
      widget.userData['studentId'] = studentId;
      widget.userData['password'] = password;
      widget.userData['phone'] = phone;
      widget.userData['gender'] = _selectedGender;
      widget.userData['age'] = _selectedAge;
      if (_profileImage != null) {
        widget.userData['profileImage'] = _profileImage!.path; // 이미지 경로를 저장
      }
    });

    Navigator.pop(context, widget.userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('프로필 편집'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              '완료',
              style: TextStyle(color: Colors.orange, fontSize: 16),
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
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : NetworkImage(widget.userData['profileImage'] ?? 'https://via.placeholder.com/150') as ImageProvider,
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.userData['name']!,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.userData['studentId']!,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        '프로필 사진 바꾸기',
                        style: TextStyle(color: Colors.orange, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text('이름', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              SizedBox(height: 20),
              Text('아이디(학번)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  hintText: '아이디(학번)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text('비밀번호', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('성별', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          items: ['남성', '여성'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('나이', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButtonFormField<String>(
                          value: _selectedAge,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          items: List.generate(100, (index) => (index + 1).toString()).map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedAge = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('전화번호', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '010-9465-6269',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    '완료',
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
}
