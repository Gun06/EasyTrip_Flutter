import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Custom_WeeklyCalendar.dart';
import 'activity_Mappage.dart';
import 'activity_addschedule.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScheduleFragment extends StatefulWidget {
  final String username;
  final String accessToken;
  final int userId;

  ScheduleFragment({
    required this.username,
    required this.accessToken,
    required this.userId,
  });

  @override
  _ScheduleFragmentState createState() => _ScheduleFragmentState();
}

class _ScheduleFragmentState extends State<ScheduleFragment> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<CustomWeeklyCalendarState> _calendarKey =
  GlobalKey<CustomWeeklyCalendarState>();

  List<Map<String, dynamic>> displayedItems = [];
  List<bool> _expanded = [];
  bool showAll = false;
  bool isEmptySchedule = false;
  List<List<Map<String, dynamic>>> recommendations = [];
  bool _isLoadingSchedules = false;

  @override
  void initState() {
    super.initState();
    _loadSchedulesForDate(DateTime.now());
  }

  Future<void> _loadSchedulesForDate(DateTime selectedDate) async {
    String formattedDate = selectedDate.toIso8601String().split('T').first;

    setState(() {
      _isLoadingSchedules = true; // 로딩 시작
    });

    try {
      final url = Uri.parse('http://44.214.72.11:8080/api/schedules/all/1');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> schedules = json.decode(utf8.decode(response.bodyBytes));

        final filteredItems = schedules
            .where((item) => item['date'] == formattedDate)
            .map((item) => {
          'date': item['date'] ?? 'N/A',
          'title': item['title'] ?? 'No Title',
          'price': item['price']?.toString() ?? '0',
          'imageUrl': item['image'] ?? 'assets/150.png',
          'pathDetails': item['pathDetails'] ?? [],
        })
            .toList();

        final List<List<Map<String, dynamic>>> newRecommendations = filteredItems
            .map((item) => (item['pathDetails'] as List<dynamic>)
            .map((rec) => {
          'placeName': rec['placeName'] ?? 'Unknown Place',
          'price': rec['price']?.toString() ?? '0',
          'location': rec['address'] ?? 'Unknown Address',
        })
            .toList())
            .toList();

        setState(() {
          displayedItems = filteredItems;
          recommendations = newRecommendations;
          _expanded = List.generate(displayedItems.length, (index) => false);
          isEmptySchedule = displayedItems.isEmpty;
        });
      } else {
        print('Failed to load schedules. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making schedule request: $e');
    } finally {
      setState(() {
        _isLoadingSchedules = false; // 로딩 종료
      });
    }
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
      barrierDismissible: true, // 모달 외부 터치로 닫기 가능
      barrierLabel: '',
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter, // 상단에 모달 정렬
            child: Material(
              color: Colors.transparent,
              child: AddSchedulePage(
                userId: widget.userId,
                accessToken: widget.accessToken,
                onScheduleAdded: () {
                  Navigator.pop(context); // 모달 닫기
                  _loadSchedulesForDate(DateTime.now()); // 새 일정 데이터 불러오기
                },
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300), // 애니메이션 지속 시간
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1), // 시작 위치: 화면 위쪽 (-1)
            end: Offset(0, 0), // 끝 위치: 원래 위치 (0)
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // 부드러운 애니메이션
          )),
          child: child,
        );
      },
    );
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
      body: Column(
        children: [
          SizedBox(
            height: 180,
            child: CustomWeeklyCalendar(
              key: _calendarKey,
              onDateSelected: (date) async {
                setState(() {
                  _isLoadingSchedules = true; // 날짜 변경 시 로딩 시작
                });
                await _loadSchedulesForDate(date); // 새 데이터 로드
                setState(() {
                  _isLoadingSchedules = false; // 로딩 종료
                });
              },
              userId: widget.userId,
              accessToken: widget.accessToken,
            ),
          ),
          SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백 추가
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0), // 좌우 여백 추가
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 좌우 여백 추가
          child: _isLoadingSchedules
              ? Center(
            child: CircularProgressIndicator(), // 로딩 화면 표시
          )
              : isEmptySchedule
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
                displayedItems[index],
                animation,
                _expanded[index],
                index,
              );
            },
          ),
        ),
      ),
        ],
      ),
    );
  }

  void _showMapPage(int index) {
    List<Map<String, String>> routeDetails = [];

    routeDetails.add({
      'placeName': displayedItems[index]['title'] ?? 'Unknown Place',
      'address': displayedItems[index]['location'] ?? 'Unknown Address',
    });

    routeDetails.addAll(recommendations[index].map((rec) => {
      'placeName': rec['placeName'] ?? 'Unknown Place',
      'address': rec['location'] ?? 'Unknown Address',
    }));

    routeDetails.add({
      'placeName': displayedItems[index]['title'] ?? 'Unknown Place',
      'address': displayedItems[index]['location'] ?? 'Unknown Address',
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(routeDetails: routeDetails),
      ),
    );
  }

  Widget _buildRecommendedItem(
      BuildContext context,
      Map<String, dynamic> item,
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
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: item['imageUrl'] != null &&
                          item['imageUrl'].startsWith('http')
                          ? Image.network(
                        item['imageUrl'],
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/150.png',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          : Image.asset(
                        'assets/150.png',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['date'] ?? '',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          Text(
                            item['title'] ?? 'No Title',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item['price']}원',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showMapPage(index),
                      child: Text(
                        '지도보기',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: recommendations[index]
                          .map((rec) => Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.place,
                                  color: Colors.blue.shade300,
                                  size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec['placeName'] ??
                                          'Unknown Place',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      rec['location'] ??
                                          'Unknown Location',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${rec['price']}원',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
