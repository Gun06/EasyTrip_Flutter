import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../helpers/database_helper.dart';

class CustomWeeklyCalendar extends StatefulWidget {
  @override
  _CustomWeeklyCalendarState createState() => _CustomWeeklyCalendarState();
}

class _CustomWeeklyCalendarState extends State<CustomWeeklyCalendar> {
  DateTime _selectedDate = DateTime.now(); // 주간 달력에서 표시할 선택된 날짜
  DateTime _tempSelectedDate = DateTime.now(); // 월간 달력에서 임시로 선택한 날짜
  late ScrollController _scrollController; // ScrollController 선언
  final double _dateWidth = 45.0; // 날짜 아이템의 너비를 정의하는 상수

  final DatabaseHelper _dbHelper = DatabaseHelper.instance; // DatabaseHelper 인스턴스 생성

  // 총 금액 항목 추가
  Map<DateTime, List<Map<String, String>>> _events = {}; // Map 타입을 String으로 유지

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // ScrollController 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
    _loadEventsFromDatabase(); // 데이터베이스에서 이벤트 불러오기
  }

  // 데이터베이스에서 이벤트 불러오기
  Future<void> _loadEventsFromDatabase() async {
    final int userId = 1; // 사용자의 ID를 설정해야 합니다.
    final List<Map<String, dynamic>> schedules = await _dbHelper.getScheduleWithRecommendations(userId);

    Map<DateTime, List<Map<String, String>>> events = {};

    for (var schedule in schedules) {
      DateTime date = DateTime.parse(schedule['date']);
      List<Map<String, dynamic>> recommendations = schedule['recommendations'];

      // dynamic 타입을 String으로 변환
      events[date] = recommendations.map((recommendation) {
        return {
          'title': (recommendation['placeName'] ?? '') as String,
          'total': (recommendation['price'] ?? '') as String,
        };
      }).toList();
    }

    setState(() {
      _events = events; // 불러온 이벤트를 _events에 저장
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
    // 선택된 날짜를 기준으로 해당 주의 일요일을 찾음
    DateTime sunday = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day); // 선택한 날짜 업데이트
      _tempSelectedDate = _selectedDate; // 임시 날짜와 동기화
    });
  }

  void _goToToday() {
    DateTime today = DateTime.now();
    _selectDate(today);  // 오늘 날짜로 선택
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();  // 오늘 날짜를 화면 가운데로 스크롤
    });
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
            // 날짜 선택 시 즉시 이벤트를 업데이트
            void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
              setState(() {
                _tempSelectedDate = selectedDay; // 임시 선택된 날짜 업데이트
                _selectDate(selectedDay); // 선택된 날짜 즉시 반영
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
                          _onDaySelected(selectedDay, focusedDay); // 날짜 선택 시 즉시 반영
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
                              itemCount: _events[_tempSelectedDate]?.length ?? 0,
                              itemBuilder: (context, index) {
                                final event = _events[_tempSelectedDate]?[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                  elevation: 2.0, // 이 부분에서 elevation을 설정합니다.
                                  child: ListTile(
                                    tileColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.grey.shade400, width: 1), // 테두리 설정
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // 이벤트 색상, 제목, 총 금액 표시
                                    leading: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _getEventColor(event?['color'] ?? 'grey'), // 이벤트 색상
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    title: Text(
                                      event?['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Text(
                                      event?['total'] ?? '', // 총 금액 표시
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
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
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
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
    DateTime previousWeek = _selectedDate.subtract(Duration(days: 7));
    _selectDate(previousWeek); // 이전 주로 이동
  }

  void _nextWeek() {
    DateTime nextWeek = _selectedDate.add(Duration(days: 7));
    _selectDate(nextWeek); // 다음 주로 이동
  }

  String _getDayLetter(DateTime date) {
    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return weekDays[date.weekday % 7];
  }

  List<DateTime> _getWeekDates(DateTime selectedDate) {
    // 선택된 날짜 기준 해당 주의 일요일부터 토요일까지 날짜 리스트 생성
    DateTime sunday = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  Widget _buildWeeklyCalendar(BuildContext context) {
    double containerWidth = _dateWidth;
    double containerHeight = 80.0;

    // 현재 주의 일요일부터 토요일까지의 날짜 계산
    List<DateTime> weekDates = _getWeekDates(_selectedDate);

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! < 0) {
          // 오른쪽으로 스와이프 -> 다음 주
          _nextWeek();
        } else if (details.primaryVelocity! > 0) {
          // 왼쪽으로 스와이프 -> 이전 주
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
                bool hasEvent = _events.keys.any((eventDate) => isSameDate(eventDate, date));
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
              }).toList(),
            ),
          ),
        ],
      ),
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
