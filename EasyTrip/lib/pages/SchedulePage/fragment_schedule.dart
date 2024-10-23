import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Custom_WeeklyCalendar.dart';
import 'activity_addschedule.dart';
import '../../helpers/database_helper.dart'; // DatabaseHelper import 추가

class ScheduleFragment extends StatefulWidget {
  @override
  _ScheduleFragmentState createState() => _ScheduleFragmentState();
}

class _ScheduleFragmentState extends State<ScheduleFragment> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<CustomWeeklyCalendarState> _calendarKey = GlobalKey<CustomWeeklyCalendarState>();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance; // DatabaseHelper 인스턴스 생성

  List<Map<String, String>> displayedItems = [];
  List<bool> _expanded = [];
  bool showAll = false;
  bool isEmptySchedule = false; // 일정이 비어있는지 여부를 확인하는 변수
  List<List<Map<String, String>>> recommendations = []; // 추천 일정 리스트

  @override
  void initState() {
    super.initState();
    _loadSchedulesForDate(DateTime.now()); // 현재 날짜의 일정을 불러옵니다.
  }

  // 날짜에 맞는 일정 데이터를 DB에서 불러오는 메서드
  Future<void> _loadSchedulesForDate(DateTime selectedDate) async {
    String formattedDate = selectedDate.toIso8601String().split('T').first; // yyyy-MM-dd 형식

    // DB에서 일정 데이터를 가져옵니다.
    final List<Map<String, dynamic>> schedules = await _dbHelper.getScheduleWithRecommendations(1);
    final filteredItems = schedules
        .where((item) => item['date'] == formattedDate)
        .map((item) => {
      'date': item['date'] as String,
      'title': item['scheduleName'] as String,
      'location': item['allPrice'] as String, // 총 금액으로 변경
      'imageUrl': 'assets/150.png' // 이미지 URL은 임의로 설정
    })
        .toList();

    // 추천 일정 데이터 설정
    final List<List<Map<String, String>>> newRecommendations = schedules
        .where((item) => item['date'] == formattedDate)
        .map((item) => (item['recommendations'] as List)
        .map<Map<String, String>>((rec) => {
      'placeName': rec['placeName'] as String,
      'price': rec['price'] as String,
      'location': rec['location'] as String,
    })
        .toList())
        .toList();

    // List<Map<String, dynamic>>에서 List<Map<String, String>>으로 변환
    setState(() {
      displayedItems = filteredItems.cast<Map<String, String>>();
      recommendations = newRecommendations;
      _expanded = List.generate(displayedItems.length, (index) => false);
      isEmptySchedule = displayedItems.isEmpty; // 일정이 비어있는지 확인
    });
  }

  void _toggleShowAll() {
    setState(() {
      showAll = !showAll;
    });
  }

  void _toggleExpanded(int index) {
    setState(() {
      _expanded[index] = !_expanded[index];
    });
  }

  void _addSchedule() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: AddSchedulePage(),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1.0),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        );
      },
    ).then((_) {
      _calendarKey.currentState?.updateSchedules(); // CustomWeeklyCalendar의 일정을 업데이트
      _loadSchedulesForDate(DateTime.now()); // 일정 추가 후 현재 날짜의 일정을 다시 로드
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSeeAllEnabled = displayedItems.length > 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
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
          onPressed: _addSchedule,
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
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CustomWeeklyCalendar(
                key: _calendarKey,
                onDateSelected: _loadSchedulesForDate, // 날짜 선택 시 일정 업데이트
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
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
                    padding: const EdgeInsets.only(right: 8.0),
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
              child: isEmptySchedule
                  ? Center(
                child: Text(
                  '일정 없음',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : AnimatedList(
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
      int index,
      ) {
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
                          Text(date, style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(location, style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                  ],
                ),
                if (isExpanded)
                  Column(
                    children: recommendations[index]
                        .map((rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.place, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${rec['placeName']} - ${rec['price']}원',
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
