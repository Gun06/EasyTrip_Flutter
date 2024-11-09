import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_search.dart';
import 'pages/activity_main.dart';
import 'admin_pages/admin.dart';
import 'helpers/database_helper.dart';
import 'activity_preference_1.dart';
import 'models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginActivity extends StatefulWidget {
  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _loginPwController = TextEditingController();
  bool _isAutoLoginChecked = false; // 자동 로그인 체크 상태

  @override
  void initState() {
    super.initState();
    _loadAutoLogin(); // 자동 로그인 상태를 불러옴
  }

  Future<void> _loadAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isAutoLogin = prefs.getBool('autoLogin') ?? false;
    setState(() {
      _isAutoLoginChecked = isAutoLogin!;
      if (_isAutoLoginChecked) {
        _loginIdController.text = prefs.getString('loginId') ?? '';
        _loginPwController.text = prefs.getString('loginPw') ?? '';
      }
    });
  }

  Future<void> _saveAutoLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoLogin', value);
    if (value) {
      prefs.setString('loginId', _loginIdController.text);
      prefs.setString('loginPw', _loginPwController.text);
    } else {
      prefs.remove('loginId');
      prefs.remove('loginPw');
    }
  }

  Future<void> _handleLogin() async {
    final String id = _loginIdController.text;
    final String pw = _loginPwController.text;

    if (id.isEmpty || pw.isEmpty) {
      Fluttertoast.showToast(msg: '아이디 또는 비밀번호를 입력하세요!');
      return;
    }

    final url = Uri.parse('http://44.214.72.11:8080/eztrip/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': id, 'password': pw}),
      );

      print('로그인 응답: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final userDisplayName = responseData['name'] ?? responseData['nickname'] ?? responseData['username'];

        // 토큰을 SharedPreferences에 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['accessToken']);
        await prefs.setString('refreshToken', responseData['refreshToken']);

        // 관리자 계정 확인
        if (id == 'admin' && pw == '1234') {
          Fluttertoast.showToast(msg: '관리자님 환영합니다.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(accessToken: responseData['accessToken']),
            ),
          );
        } else {
          Fluttertoast.showToast(msg: '$userDisplayName님 환영합니다.');
          _saveAutoLogin(_isAutoLoginChecked);

          Navigator.pushReplacementNamed(
            context,
            '/main',
            arguments: responseData['id'],
          );
        }
      } else {
        Fluttertoast.showToast(msg: '아이디 또는 비밀번호가 잘못되었습니다!');
      }
    } catch (error) {
      print('로그인 요청 오류: $error');
      Fluttertoast.showToast(msg: '네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  void _navigateToPreferenceActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PreferencePage1()),
    );
  }

  // 비밀번호 찾기 모달 창 띄우기
  void _showPasswordRecoveryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PasswordRecoveryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 140.0, bottom: 20.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please sign in to continue our app',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7D848D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: _loginIdController,
                decoration: InputDecoration(
                  hintText: '아이디',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(20.0),
                ),
                keyboardType: TextInputType.number,
                maxLength: 10,
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _loginPwController,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(20.0),
                ),
                obscureText: true,
                maxLength: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Checkbox(
                    value: _isAutoLoginChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAutoLoginChecked = value ?? false;
                      });
                    },
                  ),
                  Text('자동 로그인'),
                ],
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    '로그인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: _showPasswordRecoveryModal,
                    child: Text(
                      '비밀번호 찾기',
                      style: TextStyle(color: Colors.orange, fontSize: 16),
                    ),
                  ),
                  Text(
                    '   /   ',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: _navigateToPreferenceActivity,
                    child: Text(
                      '회원가입',
                      style: TextStyle(color: Colors.orange, fontSize: 15),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 220.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Ver 1.0',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
