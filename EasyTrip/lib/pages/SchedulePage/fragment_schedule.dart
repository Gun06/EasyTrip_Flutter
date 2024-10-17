// ScheduleFragment.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Custom_WeeklyCalendar.dart';
import 'activity_addschedule.dart'; // 추가

class ScheduleFragment extends StatefulWidget {
  @override
  _ScheduleFragmentState createState() => _ScheduleFragmentState();
}

class _ScheduleFragmentState extends State<ScheduleFragment> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, String>> recommendedItems = [
    {
      'date': '2023-10-16',
      'title': '북한산',
      'location': 'Panjer, South Denpasar',
      'imageUrl': 'assets/150.png'
    },
    {
      'date': '2023-10-16',
      'title': '정동진 해변',
      'location': 'Sanur, South Denpasar',
      'imageUrl': 'assets/150.png'
    },
    {
      'date': '2023-06-27',
      'title': '정동진 해변',
      'location': 'Sanur, South Denpasar',
      'imageUrl': 'assets/150.png'
    },
    {
      'date': '2023-06-28',
      'title': '정동진 해변',
      'location': 'Sanur, South Denpasar',
      'imageUrl': 'assets/150.png'
    },
    {
      'date': '2023-06-29',
      'title': '정동진 해변',
      'location': 'Sanur, South Denpasar',
      'imageUrl': 'assets/150.png'
    },
  ];

  List<Map<String, String>> displayedItems = [];
  List<bool> _expanded = [];
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    _initializeDisplayedItems();
  }

  void _initializeDisplayedItems() {
    setState(() {
      displayedItems = List.from(recommendedItems.take(3));
      _expanded = List.generate(displayedItems.length, (index) => false);
    });
  }

  void _toggleShowAll() {
    setState(() {
      if (showAll) {
        for (int i = displayedItems.length - 1; i >= 3; i--) {
          final removedItem = displayedItems.removeAt(i);
          _expanded.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
                (context, animation) => _buildRecommendedItem(
              context,
              removedItem['date']!,
              removedItem['title']!,
              removedItem['location']!,
              removedItem['imageUrl']!,
              animation,
              false,
              i,
            ),
          );
        }
      } else {
        for (int i = 3; i < recommendedItems.length; i++) {
          displayedItems.add(recommendedItems[i]);
          _expanded.add(false);
          _listKey.currentState?.insertItem(i);
        }
      }
      showAll = !showAll;
    });
  }

  void _toggleExpanded(int index) {
    setState(() {
      _expanded[index] = !_expanded[index];
    });
  }

  void _addSchedule() {
    // 모달이 상단에서 나타나도록 showGeneralDialog 사용
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 배리어를 누르면 닫히도록 설정
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54, // 배경색
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter, // 상단에서 나타나도록 설정
            child: Material(
              color: Colors.white, // 배경을 흰색으로 설정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                margin: EdgeInsets.only(top: 20), // 상단 여백
                child: AddSchedulePage(),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 상단에서 아래로 내려오는 애니메이션
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1.0),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 전체보기 버튼 활성화 여부 결정
    bool isSeeAllEnabled = recommendedItems.length > 4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true, // back 버튼 표시
        centerTitle: true, // 제목을 가운데로 정렬
        title: Text(
          'Schedule',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.add, color: Colors.black),
          onPressed: _addSchedule, // 수정된 부분: 일정 추가 함수 호출
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: <Widget>[
                Icon(Icons.notifications_none, color: Colors.black),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // 알림 버튼 누를 때의 동작 추가
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200, // 원하는 높이로 고정
              child: CustomWeeklyCalendar(), // CustomWeeklyCalendar 위젯 사용
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // 왼쪽 여유값 추가
                  child: Text(
                    '내 일정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: isSeeAllEnabled ? _toggleShowAll : null,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0), // 오른쪽 여유값 추가
                    child: Text(
                      showAll ? '간편보기' : '전체보기',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSeeAllEnabled ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: displayedItems.length,
                itemBuilder: (context, index, animation) {
                  return _buildRecommendedItem(
                    context,
                    displayedItems[index]['date']!,
                    displayedItems[index]['title']!,
                    displayedItems[index]['location']!,
                    displayedItems[index]['imageUrl']!,
                    animation,
                    _expanded[index],
                    index,
                  );
                },
              ),
            ),
            if (!showAll && recommendedItems.length > 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 45.0),
                child: Text(
                  '더보기Ⅴ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedItem(
      BuildContext context,
      String date,
      String title,
      String location,
      String imageUrl,
      Animation<double> animation,
      bool isExpanded,
      int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        onTap: () => _toggleExpanded(index),
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        imageUrl,
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.place, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(height: 16),
                  _buildSubItem(context, '홍대 벽화거리', location),
                  Icon(Icons.expand_more, color: Colors.grey),
                  _buildSubItem(context, '어글리 베이커리', location),
                  Icon(Icons.expand_more, color: Colors.grey),
                  _buildSubItem(context, 'DDP', location),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubItem(BuildContext context, String title, String location) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/150.png'),
            radius: 20,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.place, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.favorite_border, color: Colors.grey),
              Text(
                '1.2K',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ScheduleFragment(),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', 'US'), // English
      const Locale('ko', 'KR'), // Korean
      // 다른 지원 언어 추가
    ],
  ));
}