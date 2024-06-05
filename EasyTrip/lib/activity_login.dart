import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 자동 로그인 기능에 필요한 패키지
import 'activity_main.dart';
import 'pages/activity_preference_1.dart';
import 'activity_search.dart';

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

  void _handleLogin() {
    final String id = _loginIdController.text;
    final String pw = _loginPwController.text;

    final String validId = '20202300';
    final String validPw = 'admin';
    final String userName = '고재건';

    if (id.isEmpty || pw.isEmpty) {
      Fluttertoast.showToast(msg: '아이디 또는 비밀번호를 입력하세요!');
      return;
    }

    if (id == validId && pw == validPw) {
      Fluttertoast.showToast(msg: '$userName님 환영합니다.');
      _saveAutoLogin(_isAutoLoginChecked);
      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: {
          'name': userName,
          'studentId': '20202300',
          'birth': '000626',
          'phone': '010-9465-6269',
          'gender': '남성',
          'age': '18',
        },
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
      body: Padding(
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
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Ver 1.0',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
