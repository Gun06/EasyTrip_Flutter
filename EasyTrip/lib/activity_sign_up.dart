import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class SignUpActivity extends StatefulWidget {
  final List<String> activityPreferences;
  final List<String> foodPreferences;
  final List<String> accommodationPreferences;

  SignUpActivity({
    required this.activityPreferences,
    required this.foodPreferences,
    required this.accommodationPreferences,
  });

  @override
  _SignUpActivityState createState() => _SignUpActivityState();
}

class _SignUpActivityState extends State<SignUpActivity> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // 이메일 컨트롤러 추가
  bool _isPushChecked = false;
  bool _isInformChecked = false;

  String _gender = '';
  int _age = 0;

  bool _isIdValid = false;
  bool _isNicknameValid = false;
  bool _isBirthDateValid = false;
  bool _isNameValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordConfirmValid = false;
  bool _isPhoneNumberValid = false;
  bool _isEmailValid = false; // 이메일 유효성 검사 변수 추가

  String? _idCheckMessage;
  String? _nicknameCheckMessage;
  String? _emailCheckMessage;
  String _selectedEmailDomain = 'gmail.com';
  String? _passwordMessage;

  OverlayEntry? _tooltip; // Tooltip overlay entry

  final LayerLink _genderLink = LayerLink();
  final LayerLink _ageLink = LayerLink();
  OverlayEntry? _genderOverlayEntry;
  OverlayEntry? _ageOverlayEntry;

  // 이메일 관련 컨트롤러와 변수들
  final TextEditingController _emailPrefixController = TextEditingController();

  bool _termsViewed1 = false;
  bool _termsViewed2 = false;

  ScrollController _scrollController = ScrollController();
  bool _exposureAppBar = true;

// 이메일 도메인 리스트
  final List<String> _emailDomains = [
    'gmail.com',
    'naver.com',
    'daum.net',
    'hotmail.com',
    'yahoo.com'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _idController.addListener(() {
      setState(() {
        _idCheckMessage = null;
        _isIdValid = false;
      });
    });
    _nicknameController.addListener(() {
      if (!_isNicknameValid) {
        setState(() {
          _nicknameCheckMessage = null;
          _isNicknameValid = false;
        });
      }
    });
    _birthController.addListener(() {
      _checkBirthDate(_birthController.text);
      _calculateAge(_birthController.text);
    });
    _nameController.addListener(() {
      _checkName(_nameController.text);
    });
    _passwordController.addListener(() {
      _checkPassword(_passwordController.text);
    });
    _confirmPasswordController.addListener(() {
      _checkPasswordConfirm(_confirmPasswordController.text);
    });
    _phoneController.addListener(() {
      _formatPhoneNumber();
      _checkPhoneNumber(_phoneController.text);
    });
    _emailController.addListener(() {
      _checkEmail(_emailController.text);
    });
  }

  void _formatPhoneNumber() {
    String text = _phoneController.text;
    text = text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 3 && text.length <= 7) {
      text = text.replaceFirstMapped(
          RegExp(r'(\d{3})(\d+)'), (Match m) => '${m[1]}-${m[2]}');
    } else if (text.length > 7) {
      text = text.replaceFirstMapped(RegExp(r'(\d{3})(\d{4})(\d+)'),
          (Match m) => '${m[1]}-${m[2]}-${m[3]}');
    }

    _phoneController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_exposureAppBar) {
        setState(() {
          _exposureAppBar = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_exposureAppBar) {
        setState(() {
          _exposureAppBar = true;
        });
      }
    }
  }

  bool _isNumeric(String str) {
    return int.tryParse(str) != null;
  }

  bool _isValidNickname(String str) {
    return RegExp(r'^[a-z0-9가-힣]+$').hasMatch(str);
  }

  bool _isValidDate(String value) {
    if (value.length != 8) return false;
    final year = int.tryParse(value.substring(0, 4));
    final month = int.tryParse(value.substring(4, 6));
    final day = int.tryParse(value.substring(6, 8));

    if (year == null || month == null || day == null) return false;

    if (month < 1 || month > 12) return false;

    final daysInMonth = <int, int>{
      1: 31,
      2: 28,
      3: 31,
      4: 30,
      5: 31,
      6: 30,
      7: 31,
      8: 31,
      9: 30,
      10: 31,
      11: 30,
      12: 31
    };

    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
      daysInMonth[2] = 29;
    }

    return day >= 1 && day <= daysInMonth[month]!;
  }

  void _checkBirthDate(String value) {
    setState(() {
      _isBirthDateValid = _isValidDate(value);
    });
  }

  void _checkName(String value) {
    setState(() {
      _isNameValid = value.isNotEmpty;
    });
  }

  void _checkPassword(String value) {
    setState(() {
      final pwCheck =
          RegExp(r'^(?=.*\d)(?=.*[~`!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$')
              .hasMatch(value);
      _isPasswordValid = pwCheck;
      _passwordMessage =
          pwCheck ? null : '8자 이상의 숫자와 영문, 특수문자 조합이어야 합니다.';
    });
  }

  void _checkPasswordConfirm(String value) {
    setState(() {
      _isPasswordConfirmValid = value == _passwordController.text;
    });
  }

  void _checkPhoneNumber(String value) {
    setState(() {
      _isPhoneNumberValid = RegExp(r'^\d{3}-\d{4}-\d{4}$').hasMatch(value);
    });
  }

  void _checkEmail(String value) {
    setState(() {
      _isEmailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
    });
  }

  void _calculateAge(String birthDate) {
    if (_isValidDate(birthDate)) {
      final now = DateTime.now();
      final birthYear = int.parse(birthDate.substring(0, 4));
      final birthMonth = int.parse(birthDate.substring(4, 6));
      final birthDay = int.parse(birthDate.substring(6, 8));
      DateTime birthdayThisYear = DateTime(now.year, birthMonth, birthDay);

      if (birthdayThisYear.isBefore(now) ||
          birthdayThisYear.isAtSameMomentAs(now)) {
        setState(() {
          _age = now.year - birthYear;
        });
      } else {
        setState(() {
          _age = now.year - birthYear - 1;
        });
      }
      _ageController.text = _age.toString();
    } else {
      setState(() {
        _age = 0;
        _ageController.text = '';
      });
    }
  }

  Future<void> _checkDuplicate(String type) async {
    String? message;
    bool isUnique = false;

    // 검사할 값을 지정
    String valueToCheck;
    String url;

    if (type == 'id') {
      valueToCheck = _idController.text;
      url = 'http://44.214.72.11:8080/eztrip/check-username';
    } else if (type == 'nickname') {
      valueToCheck = _nicknameController.text;
      url = 'http://44.214.72.11:8080/eztrip/check-nickname';
    } else if (type == 'email') {
      valueToCheck = '${_emailPrefixController.text}@$_selectedEmailDomain';
      url = 'http://44.214.72.11:8080/eztrip/check-email';
    } else {
      return; // 잘못된 type이면 중단
    }

    print("중복검사 버튼 클릭 - 서버에 요청을 보냅니다: $type = $valueToCheck");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': valueToCheck}),
      );

      if (response.statusCode == 200) {
        print("서버 응답 body: ${response.body}");
        if (response.body.isNotEmpty) {
          final result = jsonDecode(response.body);
          isUnique = result['isUnique'];
          setState(() {
            if (type == 'id') {
              _isIdValid = isUnique;
              _idCheckMessage = isUnique ? null : '아이디가 이미 사용 중입니다.';
            } else if (type == 'nickname') {
              _isNicknameValid = isUnique;
              _nicknameCheckMessage = isUnique ? null : '닉네임이 이미 사용 중입니다.';
            } else if (type == 'email') {
              _isEmailValid = isUnique;
              _emailCheckMessage = isUnique ? null : '이 이메일은 이미 사용 중입니다.';
            }
          });
        } else {
          // 빈 응답일 때는 사용 가능으로 간주
          print("빈 응답이므로 사용 가능한 것으로 간주합니다.");
          setState(() {
            if (type == 'id') {
              _isIdValid = true;
              _idCheckMessage = null;
            } else if (type == 'nickname') {
              _isNicknameValid = true;
              _nicknameCheckMessage = null;
            } else if (type == 'email') {
              _isEmailValid = true;
              _emailCheckMessage = null;
            }
          });
        }
      } else {
        print("서버 오류: 상태 코드 ${response.statusCode}");
        setState(() {
          if (type == 'id') {
            _idCheckMessage = '서버 오류가 발생했습니다.';
          } else if (type == 'nickname') {
            _nicknameCheckMessage = '서버 오류가 발생했습니다.';
          } else if (type == 'email') {
            _emailCheckMessage = '서버 오류가 발생했습니다.';
          }
        });
      }
    } catch (error) {
      print("네트워크 오류 - 중복 확인 요청 실패: $error");
      setState(() {
        if (type == 'id') {
          _idCheckMessage = '네트워크 오류가 발생했습니다.';
        } else if (type == 'nickname') {
          _nicknameCheckMessage = '네트워크 오류가 발생했습니다.';
        } else if (type == 'email') {
          _emailCheckMessage = '네트워크 오류가 발생했습니다.';
        }
      });
    }
  }


  Future<void> _saveUser() async {
    // 전달된 preferences를 코드 형식의 문자열로 병합 후 앞 10자리만 사용
    final String categories = (widget.activityPreferences.join() +
        widget.foodPreferences.join() +
        widget.accommodationPreferences.join()).substring(0, 10);

    // 생일을 YYYY년MM월DD일 형식으로 변환
    final String birthDate = _birthController.text;
    final String formattedBirthDate = "${birthDate.substring(0, 4)}년${birthDate.substring(4, 6)}월${birthDate.substring(6, 8)}일";

    final requestData = {
      'username': _idController.text,
      'email': '${_emailPrefixController.text}@$_selectedEmailDomain',
      'password': _passwordController.text,
      'name': _nameController.text,
      'nickname': _nicknameController.text,
      'phoneNumber': _phoneController.text,
      'image': 'assets/ph_profile_img_01.jpg',
      'birth': formattedBirthDate,
      'gender': _gender,
      'age': _age,
      'push': _isPushChecked,
      'information': _isInformChecked,
      'categories': categories, // 코드 형식 문자열 전송
    };

    print("Sending registration data: $requestData"); // JSON 요청 로그 출력

    final url = Uri.parse('http://44.214.72.11:8080/eztrip/join');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입이 완료되었습니다.')),
      );
      Navigator.pushNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입에 실패했습니다.')),
      );
      print("Registration failed. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _exposureAppBar
          ? AppBar(
              title: Text('회원가입'),
              centerTitle: true,
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            )
          : PreferredSize(
              preferredSize: Size(0.0, 0.0),
              child: Container(),
            ),
      body: GestureDetector(
        onTap: _removeOverlay,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      '계정생성',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '계정 생성을 위해 정보를 빠짐없이 입력해주세요.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7D848D),
                      ),
                    ),
                  ],
                ),
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
                            _buildTextField(
                              _idController,
                              '아이디 ( 학번 )',
                              TextInputType.number,
                              isValid: _isIdValid,
                            ),
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
                      SizedBox(width: 10),
                      Column(
                        children: [
                          _buildDuplicateCheckButton('중복검사', () {
                            _checkDuplicate('id');
                          }),
                        ],
                      ),
                    ],
                  ),
                  if (_idCheckMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      // 하단 메시지의 왼쪽 거리 조정
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _idCheckMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 15),
              _buildTextField(_passwordController, '비밀번호', TextInputType.text,
                  obscureText: true, isValid: _isPasswordValid),
              if (_passwordMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    _passwordMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 15),
              _buildTextField(
                  _confirmPasswordController, '비밀번호 확인', TextInputType.text,
                  obscureText: true, isValid: _isPasswordConfirmValid),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0), // 원하는 왼쪽 패딩 값
                child: Text('8자 이상의 숫자와 영문, 특수문자 조합'),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, '이름', TextInputType.text,
                  isValid: _isNameValid),
              SizedBox(height: 15),
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
                              _nicknameController,
                              '닉네임',
                              TextInputType.text,
                              isValid: _isNicknameValid,
                            ),
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
                            _checkDuplicate('nickname');
                          }),
                        ],
                      ),
                    ],
                  ),
                  if (_nicknameCheckMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      // 하단 메시지의 왼쪽 거리 조정
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
              SizedBox(height: 15),
              _buildBirthDateField(),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: _ageController,
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
                      value: _gender.isNotEmpty ? _gender : null,
                      items: ['남자', '여자'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue!;
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

              SizedBox(height: 15),
              _buildPhoneNumberField(),
              SizedBox(height: 15),
              _buildEmailField(), // 새로운 이메일 입력 필드
              SizedBox(height: 30),
              CheckboxListTile(
                title: Text('Push 알림에 동의합니다. (선택)'),
                value: _isPushChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isPushChecked = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('이용약관 및 사용자 정보제공에 동의합니다. (필수)'),
                value: _isInformChecked,
                onChanged: (bool? value) {
                  if (_termsViewed1 && _termsViewed2) {
                    setState(() {
                      _isInformChecked = value ?? false;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이용약관 및 개인정보정책 내용을 확인해주세요!')),
                    );
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Text('이용약관', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showPopupActivity1(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.all(10.0),
                    ),
                    child: Text(
                      '보기',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Text('개인정보정책', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showPopupActivity2(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.all(10.0),
                    ),
                    child: Text(
                      '보기',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isInformChecked
                ? () {
                    _saveUser();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.all(15.0),
            ),
            child: Text(
              '회원가입',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      TextInputType inputType,
      {bool obscureText = false, bool isValid = true}) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(20.0),
          ),
          keyboardType: inputType,
          obscureText: obscureText,
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

  Widget _buildBirthDateField() {
    return Stack(
      children: [
        TextField(
          controller: _birthController,
          decoration: InputDecoration(
            hintText: '생년월일 (ex.20000515)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(20.0),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _checkBirthDate(value);
            _calculateAge(value);
          },
        ),
        if (!_isBirthDateValid)
          Positioned(
            right: 10,
            top: 20,
            child: Icon(
              Icons.info_outline,
              color: Colors.red,
              size: 24.0,
            ),
          ),
        if (_isBirthDateValid && _birthController.text.isNotEmpty)
          Positioned(
            right: 120,
            top: 21.5,
            child: Text(
              _birthController.text.substring(2, 8),
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        if (_isBirthDateValid && _birthController.text.isNotEmpty)
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

  Widget _buildPhoneNumberField() {
    return Stack(
      children: [
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: '전화번호 (ex.010-1234-5678)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(20.0),
          ),
          keyboardType: TextInputType.phone,
        ),
        if (!_isPhoneNumberValid)
          Positioned(
            right: 10,
            top: 20,
            child: Icon(
              Icons.info_outline,
              color: Colors.red,
              size: 24.0,
            ),
          ),
        if (_isPhoneNumberValid && _phoneController.text.isNotEmpty)
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
                _checkDuplicate('email'); // 통합된 메서드를 호출
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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

  void _createGenderOverlay() {
    _removeOverlay();
    _genderOverlayEntry = _createDropdownOverlay(
      context,
      _genderLink,
      ['남자', '여자'],
      (value) {
        setState(() {
          _gender = value;
        });
        _removeOverlay();
      },
    );
    Overlay.of(context)?.insert(_genderOverlayEntry!);
  }

  void _createAgeOverlay() {
    _removeOverlay();
    _ageOverlayEntry = _createDropdownOverlay(
      context,
      _ageLink,
      List<String>.generate(83, (index) => (index + 1).toString()),
      // 1세부터 100세까지 나이로 설정
      (value) {
        setState(() {
          _age = value as int;
        });
        _removeOverlay();
      },
    );
    Overlay.of(context)?.insert(_ageOverlayEntry!);
  }

  void _removeOverlay() {
    _genderOverlayEntry?.remove();
    _ageOverlayEntry?.remove();
    _genderOverlayEntry = null;
    _ageOverlayEntry = null;
  }

  OverlayEntry _createDropdownOverlay(BuildContext context, LayerLink link,
      List<String> items, ValueChanged<String> onSelect) {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 228,
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          offset: Offset(0, 68),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: items.map((item) {
                  return ListTile(
                    title: Text(item),
                    onTap: () => onSelect(item),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPopupActivity1(BuildContext context) async {
    final String termsText =
        await DefaultAssetBundle.of(context).loadString('assets/text_1.txt');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('이용약관'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Text(termsText),
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _termsViewed1 = true;
                  _isInformChecked = _termsViewed1 && _termsViewed2;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showPopupActivity2(BuildContext context) async {
    final String policyText =
        await DefaultAssetBundle.of(context).loadString('assets/text_2.txt');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('개인정보정책'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Text(policyText),
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _termsViewed2 = true;
                  _isInformChecked = _termsViewed1 && _termsViewed2;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSignUp(BuildContext context) {
    final String tid = _idController.text.trim();
    final String tpw = _passwordController.text.trim();
    final String tpwConfirm = _confirmPasswordController.text.trim();
    final String tname = _nameController.text.trim();
    final String tnickname = _nicknameController.text.trim();
    final String tbirth = _birthController.text.trim();
    final bool pwCheck =
        RegExp(r'^(?=.*\d)(?=.*[~`!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$')
            .hasMatch(tpw);

    if (tid.isEmpty ||
        tpw.isEmpty ||
        tpwConfirm.isEmpty ||
        tname.isEmpty ||
        tnickname.isEmpty ||
        tbirth.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('빈칸 없이 모두 입력하세요!')),
      );
      return;
    }

    if (_gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('성별을 선택해주세요!')),
      );
      return;
    }

    if (tpw != tpwConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 일치하지 않습니다!')),
      );
      return;
    }

    if (!pwCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('8자 이상의 숫자와 영문, 특수문자 조합이어야 합니다.')),
      );
      return;
    }

    // 회원가입 처리 로직 추가

    Navigator.pushNamed(context, '/main', arguments: tid);
  }
}
