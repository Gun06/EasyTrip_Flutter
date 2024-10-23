import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helpers/database_helper.dart';
import 'activity_DdayBottomSheet.dart';

class AddSchedulePage extends StatefulWidget {
  final VoidCallback? onScheduleAdded;

  AddSchedulePage({this.onScheduleAdded});

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedPriceRange = '';
  String? _selectedLocation;
  List<Map<String, dynamic>> _schedules = []; // 일정 목록
  bool _isDropdownOpen = false; // 드롭다운 열림/닫힘 상태
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final List<String> _priceRanges = [
    '5만원 이하',
    '5만원~10만원',
    '10만원~20만원',
    '20만원~30만원',
    '30만원 이상',
  ];

  final List<String> _locations = [
    '공덕역',
    '광흥창역',
    '대흥역',
    '디지털미디어시티역',
    '마포구청역',
    '마포역',
    '망원역',
    '상수역',
    '서강대역',
    '신촌역',
    '아현역',
    '애오개역',
    '월드컵경기장역',
    '이대역',
    '합정역',
    '홍대입구역'
  ]..sort();

  void _submitForm() async {
    _showLoadingDialog(context);
    final scheduleId = await _dbHelper.insertSchedule(
        1,
        DateFormat('yyyy-MM-dd').format(_selectedDate),
        _selectedPriceRange,
        'AI 추천 일정'
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    if (mounted) {
      setState(() {
        _schedules.add({
          'selectedDate': _selectedDate,
          'priceRange': _selectedPriceRange,
          'location': _selectedLocation,
        });
      });

      if (widget.onScheduleAdded != null) {
        widget.onScheduleAdded!();
      }

      Navigator.of(context).pop();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DdayBottomSheet(
        startDate: _selectedDate,
        scheduleId: scheduleId,
        onClose: () => Navigator.of(context).pop(),
        onUpdate: () {
          if (mounted) {
            setState(() {
              if (widget.onScheduleAdded != null) {
                widget.onScheduleAdded!();
              }
            });
          }
        },
      ),
    );
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _selectPriceRange(String? priceRange) {
    setState(() {
      _selectedPriceRange = priceRange ?? '';
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
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

  Future<void> _pickCustomDate(BuildContext context) async {
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
                        '날짜 선택',
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
                      initialDate: _selectedDate,
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5),
                      onDateChanged: (DateTime newDate) {
                        setState(() {
                          _selectedDate = newDate;
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
                    '날짜 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickCustomDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.lightBlue,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('날짜', style: TextStyle(color: Colors.grey)),
                          Text(
                            DateFormat('yyyy/M/d').format(_selectedDate),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '장소 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: _toggleDropdown,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.lightBlue,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedLocation ?? '장소를 선택하세요',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  if (_isDropdownOpen)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.lightBlue),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: ListView.builder(
                        itemCount: _locations.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_locations[index]),
                            onTap: () {
                              setState(() {
                                _selectedLocation = _locations[index];
                                _isDropdownOpen = false;
                              });
                            },
                          );
                        },
                      ),
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
                      onPressed: _selectedPriceRange.isNotEmpty && _selectedLocation != null ? _submitForm : null,
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
