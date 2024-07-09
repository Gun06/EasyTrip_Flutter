import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../helpers/database_helper.dart';
import '../models/user.dart';
import '../profile_image_selector.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _studentIdController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneController;
  late TextEditingController _birthController;
  late int _selectedAge;
  late String _selectedGender;
  String? _profileImage;
  User? _user;
  String _formattedBirthDate = '';
  bool _isBirthDateValid = true;

  bool _isNameValid = true;
  bool _isNicknameValid = true;
  bool _isIdValid = true;
  bool _isPasswordValid = true;
  bool _isPasswordConfirmValid = true;
  bool _isPhoneNumberValid = true;
  String? _nicknameCheckMessage;
  String? _idCheckMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    _studentIdController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _birthController = TextEditingController();
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
        _nicknameController.text = _user!.nickname;
        _studentIdController.text = _user!.id.toString();
        _passwordController.text = _user!.password;
        _confirmPasswordController.text = _user!.password;
        _phoneController.text = _user!.phoneNumber;
        _birthController.text = _user!.birthDate;
        _selectedGender = _user!.gender;
        _selectedAge = _user!.age;
        _profileImage = _user!.profileImage;
        _formattedBirthDate = _formatBirthDate(_user!.birthDate);
      });
    } else {
      Fluttertoast.showToast(msg: '사용자 정보를 불러오는데 실패했습니다.');
    }
  }

  String _formatBirthDate(String birthDate) {
    if (birthDate.length == 8) {
      return birthDate.substring(2, 8);
    }
    return '';
  }

  int _calculateAge(String birthDate) {
    final DateTime today = DateTime.now();
    final DateTime dob = DateTime.parse(birthDate);
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  bool _validateBirthDate(String birthDate) {
    if (birthDate.length != 8) return false;
    final year = int.tryParse(birthDate.substring(0, 4));
    final month = int.tryParse(birthDate.substring(4, 6));
    final day = int.tryParse(birthDate.substring(6, 8));

    if (year == null || month == null || day == null) return false;
    if (year < 1900 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;

    try {
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day)
        return false;
    } catch (e) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _selectProfileImage() async {
    final selectedImage = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return ProfileImageSelector();
      },
    );

    if (selectedImage != null) {
      setState(() {
        _profileImage = selectedImage;
      });
    }
  }

  void _saveProfile() async {
    final String name = _nameController.text.trim();
    final String studentId = _studentIdController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final String phone = _phoneController.text.trim();
    final String birthDate = _birthController.text.trim();
    final String gender = _selectedGender;
    final int age = _calculateAge(birthDate);

    final bool pwCheck =
    RegExp(r'^(?=.*\d)(?=.*[~!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$')
        .hasMatch(password);

    if (name.isEmpty ||
        studentId.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty ||
        birthDate.isEmpty) {
      Fluttertoast.showToast(msg: '모든 필드를 입력하세요.');
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: '비밀번호가 일치하지 않습니다.');
      return;
    }

    if (!pwCheck) {
      Fluttertoast.showToast(msg: '비밀번호는 8자 이상의 숫자와 영문, 특수문자 조합이어야 합니다.');
      return;
    }

    if (!_validateBirthDate(birthDate)) {
      Fluttertoast.showToast(msg: '유효한 생년월일을 입력하세요.');
      return;
    }

    final dbHelper = DatabaseHelper.instance;
    final updatedUser = User(
      id: widget.userId,
      password: password,
      name: name,
      nickname: _nicknameController.text.trim(),
      birthDate: birthDate,
      phoneNumber: phone,
      profileImage: _profileImage ?? _user!.profileImage,
      isBlocked: _user!.isBlocked,
      age: age,
      gender: gender,
      activityPreferences: _user!.activityPreferences,
      foodPreferences: _user!.foodPreferences,
      accommodationPreferences: _user!.accommodationPreferences,
    );

    print('Updating user: $updatedUser'); // 디버깅용 로그 추가

    try {
      await dbHelper.updateUser(updatedUser);
      Fluttertoast.showToast(msg: '프로필이 업데이트되었습니다.');
      print('User updated successfully'); // 성공 로그 추가
      Navigator.pop(context, updatedUser); // 업데이트된 사용자 정보를 반환하며 팝
    } catch (e) {
      print('Error updating user: $e'); // 에러 로그 추가
      Fluttertoast.showToast(msg: '프로필 업데이트에 실패했습니다.');
    }
  }

  Future<void> _checkDuplicate(
      String type, TextEditingController controller) async {
    String? message;
    bool isUnique = false;
    final dbHelper = DatabaseHelper.instance;
    final users = await dbHelper.getAllUsers(); // 모든 사용자 포함

    if (type == 'nickname') {
      isUnique = !users.any((user) =>
      user.nickname == controller.text && user.id != widget.userId);
      message = isUnique ? null : '닉네임이 이미 사용 중입니다.';
      setState(() {
        _nicknameCheckMessage = message;
        _isNicknameValid = isUnique;
      });
    } else if (type == 'id') {
      isUnique = !users.any((user) =>
      user.id.toString() == controller.text && user.id != widget.userId);
      message = isUnique ? null : '아이디가 이미 사용 중입니다.';
      setState(() {
        _idCheckMessage = message;
        _isIdValid = isUnique;
      });
    }
  }

  void _onBirthDateChanged(String value) {
    setState(() {
      _formattedBirthDate = _formatBirthDate(value);
      _selectedAge = _calculateAge(value);
      _isBirthDateValid = _validateBirthDate(value);
    });
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
            onPressed: _isFormValid() ? _saveProfile : null,
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
                      onTap: _selectProfileImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? AssetImage(_profileImage!)
                            : NetworkImage(_user!.profileImage ??
                            'https://via.placeholder.com/150')
                        as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _user!.nickname,
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _user!.id.toString(),
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _selectProfileImage,
                      child: Text(
                        '프로필 사진 바꾸기',
                        style:
                        TextStyle(color: Colors.orange, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, '이름', '이름',
                  isValid: _isNameValid),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            _buildTextField(
                                _nicknameController, '닉네임', '닉네임',
                                isValid: _isNicknameValid),
                            if (_isNicknameValid)
                              Positioned(
                                right: 10,
                                top: 20,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 24.0,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          _buildDuplicateCheckButton('중복검사', () {
                            _checkDuplicate(
                                'nickname', _nicknameController);
                          }),
                        ],
                      ),
                    ],
                  ),
                  if (_nicknameCheckMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _nicknameCheckMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            _buildTextField(_studentIdController,
                                '아이디(학번)', '아이디(학번)',
                                isValid: _isIdValid, enabled: false), // Disabled
                            if (_isIdValid)
                              Positioned(
                                right: 10,
                                top: 20,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 24.0,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            _buildTextField(_passwordController, '비밀번호', '비밀번호',
                                obscureText: true, isValid: _isPasswordValid, enabled: false), // Disabled
                            if (!_isPasswordValid)
                              Positioned(
                                right: 10,
                                top: 20,
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.red,
                                  size: 24.0,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTextField(
                  _confirmPasswordController, '비밀번호 확인', '비밀번호 확인',
                  obscureText: true, isValid: _isPasswordConfirmValid, enabled: false), // Disabled
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('8자 이상의 숫자와 영문, 특수문자 조합'),
              ),
              SizedBox(height: 20),
              _buildTextField(
                  _birthController, '생년월일 (YYYYMMDD)', '생년월일',
                  isValid: _isBirthDateValid, onChanged: (value) {
                _onBirthDateChanged(value);
                if (!_validateBirthDate(value)) {
                  setState(() {
                    _isBirthDateValid = false;
                  });
                } else {
                  setState(() {
                    _isBirthDateValid = true;
                  });
                }
              }, formattedText: _formattedBirthDate),
              SizedBox(height: 20),
              _buildAgeGenderField(),
              SizedBox(height: 20),
              _buildTextField(
                  _phoneController, '전화번호 (ex.010-1234-5678)', '전화번호',
                  isValid: _isPhoneNumberValid),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0),
                    backgroundColor:
                    _isFormValid() ? Colors.blue : Colors.grey,
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

  bool _isFormValid() {
    return _isNameValid &&
        _isNicknameValid &&
        _isIdValid &&
        _isPasswordValid &&
        _isPasswordConfirmValid &&
        _isPhoneNumberValid &&
        _isBirthDateValid;
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, String labelText,
      {bool obscureText = false,
        bool isValid = true,
        Function(String)? onChanged,
        String? formattedText,
        bool enabled = true}) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(20.0),
          ),
          obscureText: obscureText,
          onChanged: onChanged,
          enabled: enabled,
        ),
        if (formattedText != null && formattedText.isNotEmpty)
          Positioned(
            right: 120,
            top: 21.5,
            child: Text(
              formattedText,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        if (!isValid)
          Positioned(
            right: 10,
            top: 20,
            child: Icon(
              Icons.info_outline,
              color: Colors.red,
              size: 24.0,
            ),
          ),
        if (isValid && controller.text.isNotEmpty)
          Positioned(
            right: 10,
            top: 20,
            child: Icon(
              Icons.check,
              color: Colors.green,
              size: 24.0,
            ),
          ),
      ],
    );
  }

  Widget _buildDuplicateCheckButton(String text, VoidCallback onPressed) {
    return Container(
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAgeGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                enabled: false,
                controller:
                TextEditingController(text: _selectedAge.toString()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '나이',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(20.0),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: Text('성별'),
                value: _selectedGender.isNotEmpty &&
                    ['남성', '여성'].contains(_selectedGender)
                    ? _selectedGender
                    : null,
                items: ['남성', '여성'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                dropdownColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
