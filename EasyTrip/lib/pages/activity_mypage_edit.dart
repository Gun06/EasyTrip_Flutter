import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../helpers/database_helper.dart';
import '../models/user.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late String _selectedGender;
  late int _selectedAge;
  File? _profileImage;
  User? _user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _studentIdController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _selectedGender = '남성'; // Default value
    _selectedAge = 18; // Default value
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final dbHelper = DatabaseHelper.instance;
    _user = await dbHelper.getUser(widget.userId);

    if (_user != null) {
      setState(() {
        _nameController.text = _user!.name;
        _studentIdController.text = _user!.id.toString();
        _passwordController.text = _user!.password;
        _phoneController.text = _user!.phoneNumber;
        _selectedGender = _user!.gender;
        _selectedAge = _user!.age;
      });
    } else {
      Fluttertoast.showToast(msg: '사용자 정보를 불러오는데 실패했습니다.');
    }
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

  void _saveProfile() async {
    final String name = _nameController.text.trim();
    final String studentId = _studentIdController.text.trim();
    final String password = _passwordController.text.trim();
    final String phone = _phoneController.text.trim();
    final String gender = _selectedGender;
    final int age = _selectedAge;

    final bool pwCheck = RegExp(r'^(?=.*\d)(?=.*[~`!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$').hasMatch(password);

    if (name.isEmpty || studentId.isEmpty || password.isEmpty || phone.isEmpty) {
      Fluttertoast.showToast(msg: '모든 필드를 입력하세요.');
      return;
    }

    if (!pwCheck) {
      Fluttertoast.showToast(msg: '비밀번호는 8자 이상의 숫자와 영문, 특수문자 조합이어야 합니다!');
      return;
    }

    final dbHelper = DatabaseHelper.instance;
    final updatedUser = User(
      id: int.parse(studentId),
      password: password,
      name: name,
      nickname: _user!.nickname, // 유지
      birthDate: _user!.birthDate, // 유지
      phoneNumber: phone,
      profileImage: _profileImage?.path ?? _user!.profileImage,
      isBlocked: _user!.isBlocked,
      age: age,
      gender: gender,
    );

    await dbHelper.updateUser(updatedUser);

    Fluttertoast.showToast(msg: '프로필이 업데이트되었습니다.');
    Navigator.pop(context, updatedUser);
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
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : NetworkImage(_user!.profileImage ?? 'https://via.placeholder.com/150') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _user!.nickname,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _user!.id.toString(),
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
                readOnly: true,
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
                        DropdownButtonFormField<int>(
                          value: _selectedAge,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          items: List.generate(100, (index) => (index + 1)).map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
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
