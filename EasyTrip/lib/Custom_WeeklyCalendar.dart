import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';

class CustomWeeklyCalendar extends StatefulWidget {
  @override
  _CustomWeeklyCalendarState createState() => _CustomWeeklyCalendarState();
}

class _CustomWeeklyCalendarState extends State<CustomWeeklyCalendar> {
  DateTime _selectedDate = DateTime.now();
  late ScrollController _scrollController;
  final double _dateWidth = 45.0;

  Map<DateTime, List<String>> _events = {
    DateTime(2024, 6, 24): ['Event 1'],
    DateTime(2024, 6, 25): ['Event 2'],
    DateTime(2024, 6, 26): ['Event 3'],
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  double _calculateInitialScrollOffset(BuildContext context, DateTime date) {
    DateTime baseDate = DateTime(2024, 1, 1); // 기준 날짜
    int targetIndex = date.difference(baseDate).inDays;
    double offset = targetIndex * _dateWidth;

    double additionalOffset = 740.0;
    double centeredOffset = offset - (MediaQuery.of(context).size.width / 2 - _dateWidth / 3.5) + additionalOffset;

    // 디버깅 로그 출력
    /*print('Selected Date: $date');
    print('Target Index: $targetIndex');
    print('Offset: $offset');
    print('Centered Offset: $centeredOffset');*/

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
    WidgetsBinding.instance?.addPostFrameCallback((_) {
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
      builder: (context) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.6,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              Navigator.pop(context);
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                _scrollToSelectedDate();
              });
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
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          ),
        );
      },
    );
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
                  DateTime date = DateTime(2024, 1, 1).add(Duration(days: index));
                  bool isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
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
                        border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayLetter(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            DateFormat('d').format(date),
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
                },
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Row(
                    children: [
                      _buildBlurredEdge(Alignment.centerLeft, Alignment.centerRight),
                      Expanded(child: Container()),
                      _buildBlurredEdge(Alignment.centerRight, Alignment.centerLeft),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedItem(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: 180.0, // 적절한 높이로 설정
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildWeeklyCalendar(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildRecommendedItem(context), // 주간 달력을 상단에 배치
          Expanded(child: Container()), // 나머지 공간을 채우기 위한 빈 컨테이너
        ],
      ),
    );
  }

  Widget _buildBlurredEdge(AlignmentGeometry begin, AlignmentGeometry end) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.0), Colors.white],
              begin: begin,
              end: end,
            ),
          ),
        ),
      ),
    );
  }
}
