import 'package:flutter/material.dart';
import '../activity_login.dart';
import 'fragment_admin_home.dart';
import 'fragment_admin_profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginActivity(),
        '/admin': (context) => AdminPage(),
      },
    );
  }
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  bool _isFabOpen = false;
  String _searchQuery = "";
  String _sortOption = "";

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(AdminHomePage(
      searchQuery: _searchQuery,
      sortOption: _sortOption,
      onSort: _updateSortOption,
    ));
    _pages.add(AdminProfilePage());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        _isFabOpen = false; // AdminProfilePage에서는 FAB를 닫음
      }
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _pages[0] = AdminHomePage(
        searchQuery: _searchQuery,
        sortOption: _sortOption,
        onSort: _updateSortOption,
      );
    });
  }

  void _updateSortOption(String option) {
    setState(() {
      _sortOption = option;
      _pages[0] = AdminHomePage(
        searchQuery: _searchQuery,
        sortOption: _sortOption,
        onSort: _updateSortOption,
      );
    });
  }

  void _showSearchDialog() {
    TextEditingController _searchController = TextEditingController();
    _searchController.text = _searchQuery;
    List<String> suggestions = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: EdgeInsets.all(16.0),
                height: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          '검색',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "검색어를 입력하세요",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          suggestions = _getSuggestions(value);
                        });
                      },
                      onSubmitted: (value) {
                        _updateSearchQuery(value);
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(suggestions[index]),
                            onTap: () {
                              _searchController.text = suggestions[index];
                            },
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          _updateSearchQuery(_searchController.text);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          '검색',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _getSuggestions(String query) {
    // 예시로 간단한 데이터셋을 사용했습니다. 실제 데이터셋으로 대체하세요.
    List<String> dataSet = [
      "회원 정보 1",
      "회원 정보 2",
      "작성 리뷰 1",
      "작성 리뷰 2",
      "신고 리뷰 1",
      "신고 리뷰 2",
      "차단 계정 1",
      "차단 계정 2",
    ];

    if (query.isEmpty) {
      return [];
    }

    return dataSet.where((item) => item.contains(query)).toList();
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정렬 옵션',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                tileColor: Colors.white,
                leading: Icon(Icons.sort_by_alpha),
                title: Text('이름 순 (한글)'),
                onTap: () {
                  _updateSortOption("이름 순 (한글)");
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                tileColor: Colors.white,
                leading: Icon(Icons.sort_by_alpha),
                title: Text('이름 순 (영어)'),
                onTap: () {
                  _updateSortOption("이름 순 (영어)");
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                tileColor: Colors.white,
                leading: Icon(Icons.date_range),
                title: Text('날짜 순'),
                onTap: () {
                  _updateSortOption("날짜 순");
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _pages.elementAt(_selectedIndex),
          if (_selectedIndex == 0)
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFabOpen) ...[
                    FloatingActionButton(
                      onPressed: _showSearchDialog,
                      heroTag: null,
                      child: Icon(Icons.search),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: _showSortOptions,
                      heroTag: null,
                      child: Icon(Icons.sort),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 10),
                  ],
                  FloatingActionButton(
                    onPressed: _toggleFab,
                    child: Icon(_isFabOpen ? Icons.close : Icons.menu),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
