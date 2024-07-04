import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_main.dart';
import 'admin_pages/admin.dart';
import 'helpers/database_helper.dart';
import 'pages/activity_preference_1.dart';
import 'activity_search.dart';
import 'models/user.dart';

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

    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    final User? user = await dbHelper.getUserById(id);

    if (user != null && user.password == pw) {
      Fluttertoast.showToast(msg: '${user.name}님 환영합니다.');
      _saveAutoLogin(_isAutoLoginChecked);
      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: {
          'name': user.name,
          'studentId': user.id.toString(),
          'birth': user.birthDate,
          'phone': user.phoneNumber,
          'gender': '알 수 없음', // 필요 시 user 모델에 gender 필드를 추가하세요
          'age': '알 수 없음', // 필요 시 user 모델에 age 필드를 추가하세요
        },
      );
    } else if (id == '000626' && pw == 'admin1234') {
      Fluttertoast.showToast(msg: '관리자님 환영합니다.');
      _saveAutoLogin(_isAutoLoginChecked);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else {
      Fluttertoast.showToast(msg: '아이디 또는 비밀번호가 잘못되었습니다!');
    }
  }

  void _navigateToPreferenceActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PreferencePage1()),
    );
  }

  void _navigateToSearchActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchActivity()),
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
                    backgroundColor: Colors.blue, // primary 대신 backgroundColor 사용
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
                    onTap: _navigateToSearchActivity,
                    child: Text(
                      '아이디 • 비밀번호 찾기',
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
