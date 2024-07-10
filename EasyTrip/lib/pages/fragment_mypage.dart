import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../helpers/database_helper.dart';
import '../models/user.dart';
import 'activity_contact_admin_page.dart';
import 'activity_mypage_edit.dart';
import 'activity_shopping_cart.dart';
import 'activity_preference_edit.dart';

class MyPageFragment extends StatefulWidget {
  final int userId;

  MyPageFragment({required this.userId});

  @override
  _MyPageFragmentState createState() => _MyPageFragmentState();
}

class _MyPageFragmentState extends State<MyPageFragment> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, dynamic>> _menuItems = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _addMenuItems();
  }

  Future<void> _loadUserData() async {
    final dbHelper = DatabaseHelper.instance;
    _user = await dbHelper.getUser(widget.userId);
    setState(() {});
  }

  void _addMenuItems() {
    final items = [
      {"icon": Icons.person, "text": "선호도 수정"},
      {"icon": Icons.shopping_cart, "text": "위시리스트"},
      {"icon": Icons.people, "text": "게시글"},
      {"icon": Icons.settings, "text": "문의하기"},
    ];

    Future ft = Future(() {});
    for (int i = 0; i < items.length; i++) {
      ft = ft.then((_) {
        return Future.delayed(const Duration(milliseconds: 100), () {
          _menuItems.add(items[i]);
          _listKey.currentState?.insertItem(_menuItems.length - 1);
        });
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userId: widget.userId),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  void _logout() {
    Fluttertoast.showToast(msg: '${_user?.nickname ?? '사용자'}님 안녕히가세요.');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _navigateToShoppingCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCartPage()),
    );
  }

  void _navigateToActivityPreferenceEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityPreferenceEditPage(userId: widget.userId),
      ),
    );
  }

  void _navigateToContactAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactAdminPage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // back 버튼 제거
        centerTitle: true, // 이 속성으로 제목을 가운데로 정렬
        title: Text(
          '프로필',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          onPressed: _logout,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _getUserProfileImage(),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _user!.nickname,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _user!.id.toString(), // 회원가입 시 입력한 학번을 표시
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '게시글',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '300',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          height: 50,
                          width: 2,
                          color: Colors.grey[200],
                        ),
                        Column(
                          children: [
                            Text(
                              '팔로워',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '238',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          height: 50,
                          width: 2,
                          color: Colors.grey[200],
                        ),
                        Column(
                          children: [
                            Text(
                              '팔로잉',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '473',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 메뉴 섹션
            AnimatedList(
              key: _listKey,
              shrinkWrap: true,
              initialItemCount: _menuItems.length,
              itemBuilder: (context, index, animation) {
                return _buildMenuItem(
                  icon: _menuItems[index]['icon'],
                  text: _menuItems[index]['text'],
                  onTap: () {
                    if (_menuItems[index]['text'] == "위시리스트") {
                      _navigateToShoppingCart();
                    } else if (_menuItems[index]['text'] == "선호도 수정") {
                      _navigateToActivityPreferenceEdit();
                    } else if (_menuItems[index]['text'] == "문의하기") {
                      _navigateToContactAdmin();
                    }
                    // 다른 항목 클릭 시 추가 동작
                  },
                  animation: animation,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getUserProfileImage() {
    if (_user?.profileImage != null) {
      if (_user!.profileImage!.startsWith('assets/')) {
        return AssetImage(_user!.profileImage!);
      } else if (File(_user!.profileImage!).existsSync()) {
        return FileImage(File(_user!.profileImage!));
      } else {
        return NetworkImage(_user!.profileImage!);
      }
    } else {
      return AssetImage('assets/ph_profile_img_01.jpg');
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    required Animation<double> animation,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, size: 24),
          title: Text(text, style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
