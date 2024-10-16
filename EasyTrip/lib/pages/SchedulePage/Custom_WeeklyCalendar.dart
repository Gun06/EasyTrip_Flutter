import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';

class CustomWeeklyCalendar extends StatefulWidget {
  @override
  _CustomWeeklyCalendarState createState() => _CustomWeeklyCalendarState();
}

class _CustomWeeklyCalendarState extends State<CustomWeeklyCalendar> {
  DateTime _selectedDate = DateTime.now(); // 주간 달력에서 표시할 선택된 날짜
  DateTime _tempSelectedDate = DateTime.now(); // 월간 달력에서 임시로 선택한 날짜
  late ScrollController _scrollController; // ScrollController 선언
  final double _dateWidth = 45.0; // 날짜 아이템의 너비를 정의하는 상수

  Map<DateTime, List<Map<String, String>>> _events = {
    DateTime(2024, 7, 2): [
      {'time': '10:00', 'title': '프로그래밍 공부하기', 'color': 'red'},
      {'time': '12:00', 'title': '점심식사', 'color': 'orange'},
      {'time': '13:00', 'title': 'GitHub 이슈관리 및 커뮤니티 활동', 'color': 'purple'},
    ],
    DateTime(2024, 7, 3): [
      {'time': '09:00', 'title': '아침운동', 'color': 'green'},
      {'time': '11:00', 'title': '회의 참석', 'color': 'blue'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // ScrollController 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  double _calculateInitialScrollOffset(BuildContext context, DateTime date) {
    DateTime baseDate = DateTime(2024, 1, 1); // 기준 날짜
    int targetIndex = date.difference(baseDate).inDays;
    double offset = targetIndex * _dateWidth;

    double additionalOffset = 740.0;
    double centeredOffset = offset -
        (MediaQuery.of(context).size.width / 2 - _dateWidth / 3.5) +
        additionalOffset;

    return centeredOffset;
  }

  void _scrollToSelectedDate() {
    double targetOffset = _calculateInitialScrollOffset(context, _selectedDate);
    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300), // 애니메이션 시간 조절 가능
      curve: Curves.easeInOut, // 애니메이션 곡선
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _goToToday() {
    DateTime today = DateTime.now();
    _selectDate(today);
  }

  void _showMonthlyCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 스크롤 가능하도록 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            // 날짜 선택 시 처리 로직
            void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
              setState(() {
                _tempSelectedDate = selectedDay; // 임시 선택된 날짜 업데이트
              });
            }

            return FractionallySizedBox(
              heightFactor: 0.9, // 모달 높이 조절
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          // 완료 버튼 클릭 시 선택된 날짜 주간 달력에 반영
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
                        onDaySelected: (selectedDay, focusedDay) {
                          _onDaySelected(selectedDay, focusedDay);
                        },
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
                    // 선택된 날짜의 이벤트를 표시하는 영역
                    Container(
                      height: 320, // 적절한 높이로 설정
                      color: Colors.white, // 배경색 설정
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.blue.withOpacity(0.85), // 배경색 설정
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy년 MM월 dd일')
                                      .format(_tempSelectedDate),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_events[_tempSelectedDate]?.length ?? 0}개',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              key: ValueKey(_tempSelectedDate),
                              itemCount:
                              _events[_tempSelectedDate]?.length ?? 0,
                              itemBuilder: (context, index) {
                                final event =
                                _events[_tempSelectedDate]?[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 10.0),
                                  elevation: 4.0, // 이 부분에서 elevation을 설정합니다.
                                  child: ListTile(
                                    tileColor: Colors.white,
                                    // 배경색 설정
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.blue, width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    leading: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          event?['time'] ?? '',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      event?['title'] ?? '',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    trailing: Icon(
                                      Icons.circle,
                                      color: _getEventColor(
                                          event?['color'] ?? 'grey'),
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

  Color _getEventColor(String color) {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _scrollByWeek(int weeks) {
    double currentOffset = _scrollController.offset;
    double weekOffset = weeks * _dateWidth * 7;
    double targetOffset = currentOffset + weekOffset;

    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousWeek() {
    _scrollByWeek(-1);
  }

  void _nextWeek() {
    _scrollByWeek(1);
  }

  String _getDayLetter(DateTime date) {
    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return weekDays[date.weekday % 7];
  }

  Widget _buildWeeklyCalendar(BuildContext context) {
    double containerWidth = _dateWidth;
    double containerHeight = 80.0;

    return Column(
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
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: 365,
                itemBuilder: (context, index) {
                  DateTime date =
                  DateTime(2024, 1, 1).add(Duration(days: index));
                  bool isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                      DateFormat('yyyy-MM-dd').format(_selectedDate);
                  bool hasEvent = _events[date]?.isNotEmpty ?? false;
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
                        border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayLetter(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildWeeklyCalendar(context),
    );
  }
}

void main() => runApp(MaterialApp(
  home: CustomWeeklyCalendar(),
));