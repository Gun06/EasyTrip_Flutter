import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'activity_mypage_edit.dart'; // 프로필 편집 페이지 import

class MyPageFragment extends StatefulWidget {
  final Map<String, String> userData;

  MyPageFragment({required this.userData});

  @override
  _MyPageFragmentState createState() => _MyPageFragmentState();
}

class _MyPageFragmentState extends State<MyPageFragment> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, dynamic>> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _addMenuItems();
  }

  void _addMenuItems() {
    final items = [
      {"icon": Icons.person, "text": "마이페이지"},
      {"icon": Icons.shopping_cart, "text": "장바구니"},
      {"icon": Icons.people, "text": "친구관리"},
      {"icon": Icons.settings, "text": "문의하기"},
      {"icon": Icons.share, "text": "SNS 공유하기"},
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
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: Map<String, String>.from(widget.userData)),
      ),
    );

    if (updatedUserData != null) {
      setState(() {
        widget.userData.addAll(updatedUserData);
      });
    }
  }

  void _logout() {
    Fluttertoast.showToast(msg: '${widget.userData['name']}님 안녕히가세요.');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://via.placeholder.com/150', // 이미지 URL
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.userData['name']!,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.userData['studentId']!, // 회원가입 시 입력한 학번을 표시
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
                          spreadRadius: 5,
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
                    // 각 항목 클릭 시
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

  Widget _buildMenuItem(
      {required IconData icon,
        required String text,
        required GestureTapCallback onTap,
        required Animation<double> animation}) {
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
              spreadRadius: 5,
              blurRadius: 7,
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
