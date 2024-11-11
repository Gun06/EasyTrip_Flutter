import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'activity_contact_admin_page.dart';
import 'activity_mypage_edit.dart';
import 'activity_shopping_cart.dart';
import '../../activity_preference_edit.dart';

class MyPageFragment extends StatefulWidget {
  final String username;
  final String accessToken;
  final VoidCallback onLogout; // 로그아웃 콜백 추가

  MyPageFragment({
    required this.username,
    required this.accessToken,
    required this.onLogout,
  });

  @override
  _MyPageFragmentState createState() => _MyPageFragmentState();
}

class _MyPageFragmentState extends State<MyPageFragment> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, dynamic>> _menuItems = [];
  Map<String, dynamic>? _userData;
  int _unreadMessagesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _addMenuItems();
  }

  Future<void> _loadUserData() async {
    final url = Uri.parse('http://44.214.72.11:8080/eztrip/my-info');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _userData = data;
          _isLoading = false;
        });
        print("User data loaded: $_userData");
      } else {
        print("Failed to fetch user data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _logout() async {
    int? userIdToLogout = _userData != null ? _userData!['id'] : null;
    if (userIdToLogout == null) {
      Fluttertoast.showToast(msg: '사용자 id를 찾을 수 없습니다.');
      return;
    }

    final url = Uri.parse('http://44.214.72.11:8080/eztrip/logout/$userIdToLogout?id=$userIdToLogout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      print("Logout response status: ${response.statusCode}");
      print("Logout response body: ${response.body}");

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // 저장된 모든 데이터 삭제

        Fluttertoast.showToast(msg: '${_userData?['nickname'] ?? '사용자'}님 안녕히가세요.');

        setState(() {
          _userData = null;
        });

        widget.onLogout(); // 로그아웃 콜백 호출
      } else {
        print("Failed to log out. Status code: ${response.statusCode}");
        print("Response body on logout failure: ${response.body}");
        Fluttertoast.showToast(msg: '로그아웃 실패');
      }
    } catch (e) {
      print("Error during logout: $e");
      Fluttertoast.showToast(msg: '로그아웃 중 오류 발생');
    }
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
    if (_userData != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            userId: _userData!['id'],
            accessToken: widget.accessToken,
          ),
        ),
      );

      if (result != 'logout') {
        _loadUserData();
      }
    } else {
      Fluttertoast.showToast(msg: '사용자 정보를 불러오는데 실패했습니다.');
    }
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
        builder: (context) => ActivityPreferenceEditPage(username: widget.username, accessToken: widget.accessToken),
      ),
    );
  }

  void _navigateToContactAdmin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactAdminPage(username: widget.username, accessToken: widget.accessToken),
      ),
    );
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    print("빌드 함수 호출, _userData: $_userData");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildUserProfile(),
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
                  _userData?['nickname'] ?? '',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  _userData?['username']?.toString() ?? 'N/A',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),
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
                },
                animation: animation,
                badgeCount: _menuItems[index]['text'] == "문의하기" ? _unreadMessagesCount : 0,
              );
            },
          ),
        ],
      ),
    );
  }

  ImageProvider _getUserProfileImage() {
    final String? profileImage = _userData?['profileImage'];
    if (profileImage != null && profileImage.startsWith('assets/')) {
      return AssetImage(profileImage);
    } else if (profileImage != null && File(profileImage).existsSync()) {
      return FileImage(File(profileImage));
    } else if (profileImage != null) {
      return NetworkImage(profileImage);
    } else {
      return AssetImage('assets/ph_profile_img_01.jpg');
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    required Animation<double> animation,
    int badgeCount = 0,
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
          leading: Stack(
            children: [
              Icon(icon, size: 24),
              if (badgeCount > 0)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      badgeCount.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(text, style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
