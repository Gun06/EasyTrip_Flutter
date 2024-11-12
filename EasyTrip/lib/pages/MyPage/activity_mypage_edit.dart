import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../profile_image_selector.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;
  final String accessToken;

  EditProfilePage({
    required this.userId,
    required this.accessToken,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthController;
  late int _selectedAge;
  late String _selectedGender;
  String? _profileImage;
  String _formattedBirthDate = '';

  // 이메일 관련 컨트롤러 및 변수
  final TextEditingController _emailPrefixController = TextEditingController();
  String _selectedEmailDomain = 'gmail.com';
  final List<String> _emailDomains = [
    'gmail.com',
    'naver.com',
    'daum.net',
    'hotmail.com',
    'yahoo.com'
  ];

  bool _isBirthDateValid = true;
  bool _isNameValid = true;
  bool _isNicknameValid = true;
  bool _isPhoneNumberValid = true;
  bool _isEmailValid = true; // 이메일 유효성 검사 변수
  bool _isGenderValid = false; // 성별 유효성 검사 변수

  String? _nicknameCheckMessage;
  String? _emailCheckMessage;
  bool _isLoading = true; // 데이터 로딩 상태

  late final String _username; // username을 수정 불가능한 변수로 선언


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    _phoneController = TextEditingController();
    _birthController = TextEditingController();
    _selectedGender = ''; // 초기값은 빈 문자열로 설정
    _selectedAge = 18; // 기본 값
    _initializeUserData();

    // 이메일 입력 리스너 추가
    _emailPrefixController.addListener(() {
      _checkEmail();
    });

    // 이름 입력 리스너 추가
    _nameController.addListener(() {
      setState(() {
        _isNameValid = _nameController.text.trim().isNotEmpty;
      });
    });

    // 닉네임 입력 리스너 추가
    _nicknameController.addListener(() {
      setState(() {
        _isNicknameValid = _nicknameController.text.trim().isNotEmpty;
      });
    });

    // 전화번호 입력 리스너 추가
    _phoneController.addListener(() {
      setState(() {
        _isPhoneNumberValid =
            RegExp(r'^\d{3}-\d{3,4}-\d{4}$').hasMatch(_phoneController.text);
      });
    });

    // 생년월일 입력 리스너 추가
    _birthController.addListener(() {
      _onBirthDateChanged(_birthController.text);
    });
  }

  Future<void> _initializeUserData() async {
    final url = Uri.parse('http://44.214.72.11:8080/eztrip/my-info');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final userData = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _nicknameController.text = userData['nickname'] ?? '';
        _username = userData['username'] ?? ''; // 서버에서 불러온 username 값 저장
        _phoneController.text = userData['phoneNumber'] ?? '';
        _birthController.text = userData['birth'] ?? '';
        _selectedGender = userData['gender'] ?? '';
        _selectedAge = userData['age'] ?? 18;
        _profileImage = userData['image'];
        _formattedBirthDate = _formatBirthDate(userData['birth'] ?? '');
        // 이메일 설정
        if (userData['email'] != null) {
          final emailParts = userData['email'].split('@');
          if (emailParts.length == 2) {
            _emailPrefixController.text = emailParts[0];
            _selectedEmailDomain = emailParts[1];
          }
        }

        // 유효성 검사 플래그 설정
        _isNameValid = _nameController.text.trim().isNotEmpty;
        _isNicknameValid = true; // 기존 닉네임은 유효하다고 가정
        _isPhoneNumberValid =
            RegExp(r'^\d{3}-\d{3,4}-\d{4}$').hasMatch(_phoneController.text);
        _isBirthDateValid = _validateBirthDate(_birthController.text);
        _isEmailValid = true; // 기존 이메일은 유효하다고 가정
        _isGenderValid = _selectedGender.isNotEmpty;
        _isLoading = false;
      });
    } else {
      Fluttertoast.showToast(msg: '사용자 정보를 불러오는데 실패했습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatBirthDate(String birthDate) {
    if (birthDate.length >= 8) {
      return birthDate.substring(2, 8);
    }
    return '';
  }

  String _formatDateString(String date) {
    // 2000년06월26일 형식을 20000626 형식으로 변환
    return date.replaceAll(RegExp(r'[^\d]'), '');
  }

  int _calculateAge(String birthDate) {
    try {
      final formattedDate = _formatDateString(birthDate);
      final DateTime dob = DateTime.parse(formattedDate);
      final DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      print("Error parsing birth date: $e");
      return 0; // 파싱 실패 시 기본 값 반환
    }
  }

  bool _validateBirthDate(String birthDate) {
    final formattedDate = _formatDateString(birthDate);
    if (formattedDate.length != 8) return false;
    final year = int.tryParse(formattedDate.substring(0, 4));
    final month = int.tryParse(formattedDate.substring(4, 6));
    final day = int.tryParse(formattedDate.substring(6, 8));

    if (year == null || month == null || day == null) return false;
    if (year < 1900 || year > DateTime.now().year) return false;
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

  void _checkEmail() {
    final email = '${_emailPrefixController.text}@$_selectedEmailDomain';
    setState(() {
      _isEmailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _emailPrefixController.dispose();
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
    final String phone = _phoneController.text.trim();
    final String birthDate = _birthController.text.trim();
    final String gender = _selectedGender;
    final int age = _calculateAge(birthDate);
    final String image = _profileImage ?? '';
    final String email = '${_emailPrefixController.text}@$_selectedEmailDomain';

    if (name.isEmpty ||
        phone.isEmpty ||
        birthDate.isEmpty ||
        email.isEmpty ||
        gender.isEmpty) {
      Fluttertoast.showToast(msg: '모든 필드를 입력하세요.');
      return;
    }

    if (!_validateBirthDate(birthDate)) {
      Fluttertoast.showToast(msg: '유효한 생년월일을 입력하세요.');
      return;
    }

    if (!_isEmailValid) {
      Fluttertoast.showToast(msg: '유효한 이메일을 입력하세요.');
      return;
    }

    final Map<String, dynamic> updatedUser = {
      "username": _username, // 기존 username을 그대로 사용
      "email": email,
      "nickname": _nicknameController.text.trim(),
      "phoneNumber": phone,
      "image": image,
      "birth": _formatDateString(birthDate), // 날짜 형식 변환 후 저장
      "gender": gender,
      "age": age,
      "name": name,
    };

    print('Updating user: $updatedUser'); // 디버깅용 로그 추가

    final url =
    Uri.parse('http://44.214.72.11:8080/eztrip/update/${widget.userId}');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedUser),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: '프로필이 업데이트되었습니다.');
        print('User updated successfully'); // 성공 로그 추가
        Navigator.pop(context, updatedUser); // 업데이트된 사용자 정보를 반환하며 팝업 닫기
      } else {
        print('Error updating user: ${response.body}'); // 에러 로그 추가
        Fluttertoast.showToast(msg: '프로필 업데이트에 실패했습니다.');
      }
    } catch (e) {
      print('Error updating user: $e'); // 에러 로그 추가
      Fluttertoast.showToast(msg: '네트워크 오류가 발생했습니다.');
    }
  }

  Future<void> _checkDuplicate(
      String type, TextEditingController controller) async {
    String? message;
    bool isUnique = false;

    Uri url;
    String parameterName;

    // 타입에 따라 엔드포인트와 파라미터 이름 설정
    if (type == 'nickname') {
      url = Uri.parse('http://44.214.72.11:8080/eztrip/check-nickname');
      parameterName = 'nickname';
    } else if (type == 'email') {
      url = Uri.parse('http://44.214.72.11:8080/eztrip/check-email');
      parameterName = 'email';
    } else {
      // 잘못된 타입인 경우 함수 종료
      return;
    }

    String valueToCheck = controller.text.trim();
    if (type == 'email') {
      valueToCheck = '${_emailPrefixController.text}@$_selectedEmailDomain';
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        parameterName: valueToCheck,
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      isUnique = result['isUnique'];
      message = isUnique ? null : '${parameterName}이 이미 사용 중입니다.';
    } else {
      message = '중복 검사에 실패했습니다.';
    }

    setState(() {
      if (type == 'nickname') {
        _nicknameCheckMessage = message;
        _isNicknameValid = isUnique;
      } else if (type == 'email') {
        _emailCheckMessage = message;
        _isEmailValid = isUnique;
      }
    });
  }

  void _onBirthDateChanged(String value) {
    setState(() {
      _formattedBirthDate = _formatBirthDate(value);
      _selectedAge = _calculateAge(value);
      _isBirthDateValid = _validateBirthDate(value);
    });
  }

  bool _isFormValid() {
    return _isNameValid &&
        _isNicknameValid &&
        _isPhoneNumberValid &&
        _isBirthDateValid &&
        _isEmailValid &&
        _isGenderValid; // 성별 유효성 검사 추가
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailPrefixController,
                    decoration: InputDecoration(
                      hintText: '이메일',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.all(20.0),
                    ),
                    onChanged: (value) {
                      _checkEmail();
                    },
                  ),
                ),
                SizedBox(width: 8),
                Text('@', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEmailDomain,
                    items: _emailDomains.map((domain) {
                      return DropdownMenuItem(
                        value: domain,
                        child: Text(domain),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmailDomain = value!;
                        _checkEmail();
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 18.0,
                      ), // 높이 조절
                    ),
                    dropdownColor: Colors.white, // 드롭다운 배경색
                  ),
                ),
              ],
            ),
            Positioned(
              right: 45,
              top: 20,
              child: Icon(
                _isEmailValid ? Icons.check : Icons.info_outline,
                color: _isEmailValid ? Colors.green : Colors.red,
                size: 24.0,
              ),
            ),
          ],
        ),
        if (_emailCheckMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _emailCheckMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _checkDuplicate('email', _emailPrefixController);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            ),
            child: Text(
              '이메일 중복 검사',
              style: TextStyle(color: Colors.white),
            ),
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
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
                    _isGenderValid = _selectedGender.isNotEmpty;
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
              style: TextStyle(
                color: _isFormValid() ? Colors.orange : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
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
                            : NetworkImage(
                            'https://via.placeholder.com/150')
                        as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _nicknameController.text,
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _username,
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
              _buildTextField(
                  TextEditingController(text: _username), // 초기 값으로 기존 username 사용
                  '아이디(학번)',
                  '아이디(학번)',
                  enabled: false), // 수정 불가능
              SizedBox(height: 20),
              _buildTextField(
                  _birthController, '생년월일 (예: 2000년06월26일)', '생년월일',
                  isValid: _isBirthDateValid, onChanged: (value) {
                _onBirthDateChanged(value);
              }, formattedText: _formattedBirthDate),
              SizedBox(height: 20),
              _buildAgeGenderField(),
              SizedBox(height: 20),
              _buildTextField(_phoneController, '전화번호 (ex.010-1234-5678)', '전화번호',
                  isValid: _isPhoneNumberValid),
              SizedBox(height: 20),
              _buildEmailField(), // 이메일 입력 필드 추가
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
}