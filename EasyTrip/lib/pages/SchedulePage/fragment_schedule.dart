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

  @override
  void initState() {
    super.initState();
    _loadSchedulesForDate(DateTime.now());
  }

  Future<void> _loadSchedulesForDate(DateTime selectedDate) async {
    String formattedDate = selectedDate.toIso8601String().split('T').first;

    // 서버 요청
    final url = Uri.parse('http://44.214.72.11:8080/api/schedules/all/1');
    print('Requesting schedules from URL: $url');
    print('Using accessToken: ${widget.accessToken}');
    print('Formatted Date for filtering: $formattedDate');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> schedules =
              json.decode(utf8.decode(response.bodyBytes));
          print('Parsed schedules: $schedules');

          // 필터링된 데이터
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

          print('Filtered items for the date $formattedDate: $filteredItems');

          // 세부 경로 데이터 정리
          final List<List<Map<String, dynamic>>> newRecommendations =
              filteredItems.map((item) {
            final List<dynamic> pathDetails = item['pathDetails'];
            return pathDetails.map<Map<String, dynamic>>((rec) {
              return {
                'placeName': rec['placeName'] ?? 'Unknown Place',
                'price': rec['price']?.toString() ?? '0',
                'location': rec['address'] ?? 'Unknown Address',
              };
            }).toList();
          }).toList();

          setState(() {
            displayedItems = filteredItems;
            recommendations = newRecommendations;
            _expanded = List.generate(displayedItems.length, (index) => false);
            isEmptySchedule = displayedItems.isEmpty;
          });
          print('Successfully updated displayed items: $displayedItems');
        } catch (e) {
          print('Error parsing schedules JSON data: $e');
        }
      } else {
        print('Failed to load schedules. Status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
      }
    } catch (e) {
      print('Error making schedule request: $e');
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
    print('Add schedule button pressed');
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
                onDateSelected: _loadSchedulesForDate,
                userId: widget.userId,
                accessToken: widget.accessToken,
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
                          displayedItems[index],
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

  void _showMapPage(int index) {
    List<Map<String, String>> routeDetails = [];

    // 출발지 추가
    routeDetails.add({
      'placeName': displayedItems[index]['title'] ?? 'Unknown Place',
      'address': displayedItems[index]['location'] ?? 'Unknown Address',
    });

    // 경유지 추가
    routeDetails.addAll(recommendations[index].map((rec) => {
      'placeName': rec['placeName'] ?? 'Unknown Place',
      'address': rec['location'] ?? 'Unknown Address',
    }));

    // 도착지 추가
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
            borderRadius: BorderRadius.circular(12.0), // 모서리 둥글기 줄이기
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
                        'assets/150.png', // 기본 이미지 경로 설정
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
                      onPressed: () => _showMapPage(index), // 지도 페이지 호출
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
                                  color: Colors.blue.shade300, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec['placeName'] ?? 'Unknown Place',
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
                                    fontSize: 13, color: Colors.black87),
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
