import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordRecoveryModal extends StatefulWidget {
  @override
  _PasswordRecoveryModalState createState() => _PasswordRecoveryModalState();
}

class _PasswordRecoveryModalState extends State<PasswordRecoveryModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailPrefixController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  String _selectedEmailDomain = 'gmail.com';
  bool _isUserVerified = false;
  bool _isPasswordValid = false;
  bool _isPasswordConfirmed = false;

  String? _verificationError;

  final List<String> _emailDomains = [
    'gmail.com',
    'naver.com',
    'daum.net',
    'hotmail.com',
    'yahoo.com'
  ];

  @override
  void dispose() {
    _idController.dispose();
    _emailPrefixController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyUser() async {
    final String idText = _idController.text.trim();
    final String emailText =
        '${_emailPrefixController.text.trim()}@$_selectedEmailDomain';

    if (idText.isEmpty || emailText.isEmpty) {
      setState(() {
        _verificationError = '아이디와 이메일을 모두 입력하세요.';
      });
      return;
    }

    final url = Uri.parse('http://44.214.72.11:8080/eztrip/findMember');
    try {
      final requestData = jsonEncode({'username': idText, 'email': emailText});
      print('요청 데이터: $requestData');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestData,
      );

      print('서버 응답 코드: ${response.statusCode}');
      print('서버 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _isUserVerified = true;
          _verificationError = null;
        });
        print('사용자가 성공적으로 확인되었습니다.');
      } else {
        setState(() {
          _verificationError = '아이디와 이메일이 일치하지 않습니다.';
        });
        print('API 서버에서 사용자 확인 실패: ${response.body}');
      }
    } catch (error) {
      setState(() {
        _verificationError = '네트워크 오류가 발생했습니다.';
      });
      print('API 요청 오류: $error');
    }
  }

  Future<void> _resetPassword() async {
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    final bool pwValid = RegExp(r'^(?=.*\d)(?=.*[~!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$')
        .hasMatch(newPassword);

    setState(() {
      _isPasswordValid = pwValid;
      _isPasswordConfirmed = newPassword == confirmPassword;
    });

    if (!pwValid) {
      Fluttertoast.showToast(msg: '비밀번호는 8~16자의 영문, 숫자, 특수문자 조합이어야 합니다.');
      return;
    }

    if (!_isPasswordConfirmed) {
      Fluttertoast.showToast(msg: '비밀번호가 일치하지 않습니다.');
      return;
    }

    // API 요청을 보내어 비밀번호를 재설정합니다.
    final url = Uri.parse('http://44.214.72.11:8080/eztrip/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _idController.text.trim(),
          'email': '${_emailPrefixController.text.trim()}@$_selectedEmailDomain',
          'newPassword': newPassword, // 여기서 newPassword 키 사용
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: '비밀번호가 성공적으로 변경되었습니다.');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: '비밀번호 변경에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: '네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '비밀번호 찾기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      _buildVerificationForm(),
                      AnimatedOpacity(
                        opacity: _isUserVerified ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: _isUserVerified
                              ? _buildPasswordFields()
                              : Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      children: [
        TextField(
          controller: _idController,
          decoration: InputDecoration(
            hintText: '아이디(학번)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            contentPadding: EdgeInsets.all(20.0),
          ),
          keyboardType: TextInputType.number,
          enabled: !_isUserVerified,
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailPrefixController,
                decoration: InputDecoration(
                  hintText: '이메일',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: EdgeInsets.all(20.0),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isUserVerified,
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
                onChanged: !_isUserVerified
                    ? (value) {
                  setState(() {
                    _selectedEmailDomain = value!;
                  });
                }
                    : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                disabledHint: Text(_selectedEmailDomain),
                isExpanded: true,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        if (_verificationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _verificationError!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(height: 16.0),
        if (!_isUserVerified)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyUser,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(15.0),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        SizedBox(height: 16.0),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _newPasswordController,
              onChanged: (value) {
                setState(() {
                  _isPasswordValid = RegExp(r'^(?=.*\d)(?=.*[~!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$')
                      .hasMatch(value);
                });
              },
              decoration: InputDecoration(
                hintText: '새 비밀번호',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                contentPadding: EdgeInsets.all(20.0),
              ),
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(
                _isPasswordValid ? Icons.check : Icons.info_outline,
                color: _isPasswordValid ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        if (!_isPasswordValid)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '비밀번호는 8~16자의 영문, 숫자, 특수문자 조합이어야 합니다.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(height: 16.0),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _confirmPasswordController,
              onChanged: (value) {
                setState(() {
                  _isPasswordConfirmed = _newPasswordController.text == value;
                });
              },
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                contentPadding: EdgeInsets.all(20.0),
              ),
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(
                _isPasswordConfirmed ? Icons.check : Icons.info_outline,
                color: _isPasswordConfirmed ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        if (!_isPasswordConfirmed)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '비밀번호가 일치하지 않습니다.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _resetPassword,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(15.0),
              backgroundColor: Colors.blue,
            ),
            child: Text(
              '비밀번호 변경',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
