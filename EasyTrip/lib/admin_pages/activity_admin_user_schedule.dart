import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserSchedulePage extends StatefulWidget {
  final String accessToken;

  const UserSchedulePage({
    Key? key,
    required this.accessToken,
  }) : super(key: key);

  @override
  _UserSchedulePageState createState() => _UserSchedulePageState();
}

class _UserSchedulePageState extends State<UserSchedulePage> {
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/schedules');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> schedules = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          _schedules = schedules.map((schedule) {
            final member = schedule['member'];
            return {
              'id': schedule['id'], // Schedule ID 추가
              'title': schedule['title'] ?? 'No Title',
              'writer': member != null ? member['username'] ?? 'Unknown Writer' : 'Unknown Writer',
              'details': (schedule['pathDetails'] ?? []).map<Map<String, dynamic>>((detail) {
                return {
                  'placeName': detail['placeName'] ?? 'Unknown Place',
                  'price': detail['price']?.toString() ?? '0',
                  'location': detail['address'] ?? 'Unknown Location',
                  'imageUrl': detail['image'] ?? '',
                };
              }).toList(),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to fetch schedules. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 일정 삭제 함수
  Future<void> _deleteSchedule(int index) async {
    final scheduleId = _schedules[index]['id']; // 해당 일정의 ID 가져오기
    final url = Uri.parse('http://44.214.72.11:8080/api/admin/schedules/$scheduleId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _schedules.removeAt(index); // 삭제된 일정은 목록에서 제거
        });
        print("Schedule with ID $scheduleId deleted successfully.");
      } else {
        print("Failed to delete schedule. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting schedule: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_schedules.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('일정 없음', style: TextStyle(fontSize: 16, color: Colors.black)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          final isExpanded = _expandedIndex == index;

          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    schedule['title'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('작성자: ${schedule['writer']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.7),
                        ),
                        child: Text(
                          isExpanded ? '닫기' : '상세보기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteSchedule(index); // 일정 삭제 후 실시간 반영
                        },
                      ),
                    ],
                  ),
                ),
                // 세부 일정 표시
                if (isExpanded)
                  schedule['details'].isEmpty
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      '세부 정보 없음',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  )
                      : Column(
                    children: schedule['details'].map<Widget>((detail) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail['placeName'],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      detail['location'],
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      '${detail['price']}원',
                                      style: TextStyle(color: Colors.black87, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
