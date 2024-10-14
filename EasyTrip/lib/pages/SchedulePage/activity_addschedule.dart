import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'activity_DdayBottomSheet.dart';

class AddSchedulePage extends StatefulWidget {
  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _selectedPriceRange = '';
  bool _isStartDateSelected = true;
  List<Map<String, dynamic>> _schedules = [];

  final List<String> _priceRanges = [
    '5만원 이하',
    '5만원~10만원',
    '10만원~20만원',
    '20만원~30만원',
    '30만원 이상',
  ];

  void _submitForm() {
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시작 날짜는 종료 날짜보다 이전이어야 합니다.')),
      );
      return;
    }

    _showLoadingDialog(context);

    // 로딩 후 추가된 일정 및 BottomSheet 표시
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 로딩 화면 닫기

      setState(() {
        _schedules.add({
          'startDate': _startDate,
          'endDate': _endDate,
          'priceRange': _selectedPriceRange,
        });
      });

      Navigator.of(context).pop(); // 일정 추가 페이지 닫기

      // 분리된 BottomSheet 호출
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DdayBottomSheet(
          startDate: _startDate,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    });
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 100,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("AI 추천 요청 중...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCustomStartDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              hintColor: Colors.lightBlue,
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.of(context).size.width,
              height: 400,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '시작 날짜 선택',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CalendarDatePicker(
                      initialDate: _startDate,
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5),
                      onDateChanged: (DateTime newDate) {
                        setState(() {
                          _startDate = newDate;
                          _isStartDateSelected = true;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCustomEndDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              hintColor: Colors.lightBlue,
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.of(context).size.width,
              height: 400,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '종료 날짜 선택',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CalendarDatePicker(
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime(DateTime.now().year + 5),
                      onDateChanged: (DateTime newDate) {
                        setState(() {
                          _endDate = newDate;
                          _isStartDateSelected = false;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectPriceRange(String? priceRange) {
    setState(() {
      _selectedPriceRange = priceRange ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 48),
                      Center(
                        child: Text(
                          '일정 추가',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _cancel,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    '기간 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickCustomStartDate(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isStartDateSelected ? Colors.lightBlue : Colors.transparent,
                              ),
                              color: _isStartDateSelected ? Colors.white : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start date', style: TextStyle(color: Colors.grey)),
                                Text(
                                  DateFormat('yyyy/M/d').format(_startDate),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickCustomEndDate(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: !_isStartDateSelected ? Colors.lightBlue : Colors.transparent,
                              ),
                              color: !_isStartDateSelected ? Colors.white : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End date', style: TextStyle(color: Colors.grey)),
                                Text(
                                  DateFormat('yyyy/M/d').format(_endDate),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(
                    color: Colors.grey.shade200,
                    thickness: 1.5,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '가격 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildPriceOptions(),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedPriceRange.isNotEmpty ? _submitForm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade500,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('AI 추천 요청', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOptions() {
    double horizontalSpacing = 16.0;
    double verticalSpacing = 16.0;
    double optionWidth = (MediaQuery.of(context).size.width - 48) / 2;
    TextStyle optionTextStyle = TextStyle(fontSize: 14);

    return Wrap(
      spacing: horizontalSpacing,
      runSpacing: verticalSpacing,
      children: _priceRanges.map((range) {
        final isSelected = _selectedPriceRange == range;
        return GestureDetector(
          onTap: () {
            _selectPriceRange(range);
          },
          child: Container(
            width: optionWidth,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  range,
                  style: optionTextStyle.copyWith(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
