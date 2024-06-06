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
  late PageController _pageController;
  final double _dateWidth = 50.0;

  Map<DateTime, List<String>> _events = {
    DateTime(2024, 6, 5): ['Event 1'],
    DateTime(2024, 6, 6): ['Event 2'],
    DateTime(2024, 6, 7): ['Event 3'],
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController(initialPage: 1000);
  }

  double _calculateInitialScrollOffset(BuildContext context, DateTime date) {
    int targetIndex = date.difference(DateTime(2024, 1, 1)).inDays;
    return targetIndex * _dateWidth - (MediaQuery.of(context).size.width / 2 - _dateWidth / 2);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      double targetOffset = _calculateInitialScrollOffset(context, date);
      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goToToday() {
    DateTime today = DateTime.now();
    setState(() {
      _selectedDate = today;
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      double targetOffset = _calculateInitialScrollOffset(context, today);
      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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
                double targetOffset = _calculateInitialScrollOffset(context, selectedDay);
                _scrollController.animateTo(
                  targetOffset,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
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

  void _previousWeek() {
    DateTime newDate = _selectedDate.subtract(Duration(days: 7));
    setState(() {
      _selectedDate = newDate;
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      double targetOffset = _calculateInitialScrollOffset(context, newDate);
      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _nextWeek() {
    DateTime newDate = _selectedDate.add(Duration(days: 7));
    setState(() {
      _selectedDate = newDate;
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      double targetOffset = _calculateInitialScrollOffset(context, newDate);
      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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
      width: double.infinity,
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
              _buildWeeklyCalendar(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      double targetOffset = _calculateInitialScrollOffset(context, _selectedDate);
      _scrollController.jumpTo(targetOffset);
    });

    return Scaffold(
      body: Center(
        child: _buildRecommendedItem(context),
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
