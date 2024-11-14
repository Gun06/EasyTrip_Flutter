import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class CustomWeeklyCalendar extends StatefulWidget {
  final Future<void> Function(DateTime) onDateSelected;
  final VoidCallback? onScheduleUpdated;
  final int userId;
  final String accessToken;

  CustomWeeklyCalendar({
    Key? key,
    required this.onDateSelected,
    this.onScheduleUpdated,
    required this.userId,
    required this.accessToken,
  }) : super(key: key);

  @override
  CustomWeeklyCalendarState createState() => CustomWeeklyCalendarState();

  void updateSchedules() {
    final state = CustomWeeklyCalendarState();
    state.updateSchedules();
  }
}

class CustomWeeklyCalendarState extends State<CustomWeeklyCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _tempSelectedDate = DateTime.now();
  late ScrollController _scrollController;
  final double _dateWidth = 45.0;

  Map<DateTime, List<Map<String, dynamic>>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
    _loadSchedulesFromServer();
  }

  void updateSchedules() {
    _loadSchedulesFromServer();
  }

  // 서버에서 일정 불러오기
  Future<void> _loadSchedulesFromServer() async {
    final url = Uri.parse('http://44.214.72.11:8080/api/schedules/all/1');
    print('Requesting schedules from: $url with accessToken: ${widget.accessToken}');

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
          final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
          print('Parsed schedule data: $data');

          Map<DateTime, List<Map<String, dynamic>>> scheduleEvents = {};

          for (var schedule in data) {
            DateTime date = DateTime.parse(schedule['date']);
            if (scheduleEvents.containsKey(date)) {
              scheduleEvents[date]!.add({
                'scheduleId': schedule['id'].toString(),
                'scheduleName': schedule['title'] ?? '',
                'allPrice': schedule['price']?.toString() ?? '',
              });
            } else {
              scheduleEvents[date] = [
                {
                  'scheduleId': schedule['id'].toString(),
                  'scheduleName': schedule['title'] ?? '',
                  'allPrice': schedule['price']?.toString() ?? '',
                }
              ];
            }
          }

          print('Setting schedule data: $scheduleEvents');
          setState(() {
            _schedules = scheduleEvents;
          });
        } catch (e) {
          print('Error parsing schedules data: $e');
        }
      } else {
        print('Failed to load schedules. Status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
      }
    } catch (e) {
      print('Error loading schedules: $e');
    }
  }

  // 서버에서 일정 삭제
  Future<void> _deleteScheduleFromServer(int scheduleId) async {
    final url = Uri.parse('http://44.214.72.11:8080/api/schedules/$scheduleId');
    print('Deleting schedule with ID: $scheduleId at $url');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      print('Delete response status code: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        await _loadSchedulesFromServer();
        if (widget.onScheduleUpdated != null) {
          widget.onScheduleUpdated!();
        }
      } else {
        print('Failed to delete schedule. Status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting schedule: $e');
    }
  }

  void _scrollToSelectedDate() {
    DateTime sunday = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    // Set scroll position here if needed for calendar view.
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _tempSelectedDate = _selectedDate;
    });

    widget.onDateSelected(_selectedDate);
  }

  void _goToToday() {
    DateTime today = DateTime.now();
    _selectDate(today);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _showMonthlyCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
              setState(() {
                _tempSelectedDate = selectedDay;
                _selectDate(selectedDay);
              });
            }

            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          _selectDate(_tempSelectedDate);
                          Navigator.pop(context);
                        },
                        child: Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _tempSelectedDate,
                        selectedDayPredicate: (day) {
                          return isSameDay(_tempSelectedDate, day);
                        },
                        onDaySelected: _onDaySelected,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: false,
                        ),
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month'
                        },
                      ),
                    ),
                    Container(
                      height: 320,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.blue.withOpacity(0.85),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy년 MM월 dd일').format(_tempSelectedDate),
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_schedules[_tempSelectedDate]?.length ?? 0}개',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              key: ValueKey(_tempSelectedDate),
                              itemCount: _schedules[_tempSelectedDate]?.length ?? 0,
                              itemBuilder: (context, index) {
                                final schedule = _schedules[_tempSelectedDate]?[index];
                                final int scheduleId = int.parse(schedule?['scheduleId'] ?? '0');
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                  elevation: 2.0,
                                  child: ListTile(
                                    tileColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey.shade400, width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      schedule?['scheduleName'] ?? '',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      '${schedule?['allPrice']}원',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await _deleteScheduleFromServer(scheduleId);
                                        setState(() {
                                          _schedules[_tempSelectedDate]?.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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

  void _previousWeek() {
    DateTime previousWeek = _selectedDate.subtract(Duration(days: 7));
    _selectDate(previousWeek);
  }

  void _nextWeek() {
    DateTime nextWeek = _selectedDate.add(Duration(days: 7));
    _selectDate(nextWeek);
  }

  List<DateTime> _getWeekDates(DateTime selectedDate) {
    DateTime sunday = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  Widget _buildWeeklyCalendar(BuildContext context) {
    double containerWidth = _dateWidth;
    double containerHeight = 80.0;

    List<DateTime> weekDates = _getWeekDates(_selectedDate);

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! < 0) {
          _nextWeek();
        } else if (details.primaryVelocity! > 0) {
          _previousWeek();
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showMonthlyCalendar(context),
                child: Text(
                  DateFormat('yyyy/MM/dd').format(_selectedDate),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: _previousWeek,
                  ),
                  GestureDetector(
                    onTap: _goToToday,
                    child: Text(
                      DateFormat('MMM').format(_selectedDate),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: _nextWeek,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: containerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: weekDates.map((date) {
                bool isSelected = isSameDate(date, _selectedDate);
                bool hasEvent = _schedules.keys.any((eventDate) => isSameDate(eventDate, date));
                return GestureDetector(
                  onTap: () {
                    _selectDate(date);
                  },
                  child: Container(
                    width: containerWidth,
                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                          : null,
                      color: isSelected ? null : Colors.white,
                      border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          DateFormat.d().format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (hasEvent)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildWeeklyCalendar(context);
  }
}
