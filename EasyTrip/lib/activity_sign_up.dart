import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignUpActivity extends StatefulWidget {
  @override
  _SignUpActivityState createState() => _SignUpActivityState();
}

class _SignUpActivityState extends State<SignUpActivity> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isPushChecked = false;
  bool _isInformChecked = false;

  String _gender = '';
  String _age = '';

  String? result1;
  String? result2;

  final LayerLink _genderLink = LayerLink();
  final LayerLink _ageLink = LayerLink();
  OverlayEntry? _genderOverlayEntry;
  OverlayEntry? _ageOverlayEntry;

  bool _termsViewed1 = false;
  bool _termsViewed2 = false;

  ScrollController _scrollController = ScrollController();
  bool _exposureAppBar = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_exposureAppBar) {
        setState(() {
          _exposureAppBar = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_exposureAppBar) {
        setState(() {
          _exposureAppBar = true;
        });
      }
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
              _buildTextField(_idController, '아이디 ( 학번 )', TextInputType.number),
              SizedBox(height: 15),
              _buildTextField(_passwordController, '비밀번호', TextInputType.text, obscureText: true),
              SizedBox(height: 15),
              _buildTextField(_confirmPasswordController, '비밀번호 확인', TextInputType.text, obscureText: true),
              SizedBox(height: 10),
              Text('8자 이상의 숫자와 영문, 특수문자 조합'),
              SizedBox(height: 20),
              _buildTextField(_nameController, '이름', TextInputType.text),
              SizedBox(height: 15),
              _buildTextField(_birthController, '생년월일 ( ex.931104 )', TextInputType.number),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _genderLink,
                      child: GestureDetector(
                        onTap: () {
                          _createGenderOverlay();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_gender.isEmpty ? '성별' : _gender),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _ageLink,
                      child: GestureDetector(
                        onTap: () {
                          _createAgeOverlay();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_age.isEmpty ? '나이' : _age),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              _buildTextField(_phoneController, '010-0000-0000', TextInputType.phone),
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
              _handleSignUp(context);
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

  Widget _buildTextField(TextEditingController controller, String hintText, TextInputType inputType, {bool obscureText = false}) {
    return TextField(
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
      List<String>.generate(83, (index) => (index + 18).toString()), // 18세부터 100세까지 나이로 설정
          (value) {
        setState(() {
          _age = value;
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

  OverlayEntry _createDropdownOverlay(BuildContext context, LayerLink link, List<String> items, ValueChanged<String> onSelect) {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 228, // 드롭다운 너비 설정
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          offset: Offset(0, 68), // 드롭다운 위치 조정
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200), // 최대 높이 지정
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: items.map((item) {
                  return ListTile(
                    title: Text(item), // 나이 표시
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
    final String termsText = await DefaultAssetBundle.of(context).loadString('assets/text_1.txt');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이용약관'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 너비를 화면의 80%로 설정
            height: MediaQuery.of(context).size.height * 0.4, // 높이를 화면의 50%로 설정
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
                  _termsViewed1 = true; // 이용약관 확인 시 체크되도록 업데이트
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
    final String policyText = await DefaultAssetBundle.of(context).loadString('assets/text_2.txt');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('개인정보정책'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 너비를 화면의 80%로 설정
            height: MediaQuery.of(context).size.height * 0.4, // 높이를 화면의 50%로 설정
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
                  _termsViewed2 = true; // 개인정보정책 확인 시 체크되도록 업데이트
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
    final String tbirth = _birthController.text.trim();
    final bool pwCheck = RegExp(r'^(?=.*\d)(?=.*[~`!@#$%^&*()-])(?=.*[a-zA-Z]).{8,16}$').hasMatch(tpw);

    if (tid.isEmpty || tpw.isEmpty || tpwConfirm.isEmpty || tname.isEmpty || tbirth.isEmpty) {
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

    if (_age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('나이를 선택해주세요!')),
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
        SnackBar(content: Text('비밀번호는 8자 이상의 숫자와 영문, 특수문자 조합이어야 합니다!')),
      );
      return;
    }

    // 회원가입 처리 로직 추가

    // 회원가입이 성공하면 로그인 페이지로 이동
    Navigator.pushNamed(context, '/main', arguments: tid);
  }
}
