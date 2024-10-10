import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSchedulePage extends StatefulWidget {
  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _selectedPriceRange = '';
  bool _isStartDateSelected = true; // 선택된 날짜 필드를 나타내는 변수

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
    print('시작 날짜: $_startDate');
    print('종료 날짜: $_endDate');
    print('가격 범위: $_selectedPriceRange');
    Navigator.of(context).pop();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  Future<void> _pickCustomStartDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 다이얼로그 모서리를 둥글게 처리
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              hintColor: Colors.lightBlue, // 선택한 날짜의 색상
              colorScheme: ColorScheme.light(
                primary: Colors.blue, // 달력의 주요 색상
                onSurface: Colors.black, // 날짜 텍스트 색상
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue, // 버튼 텍스트 색상
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // 달력 모서리를 둥글게 처리
              ),
              width: MediaQuery.of(context).size.width, // 화면에 맞게 너비 조정
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
                          Navigator.of(context).pop(); // X 버튼을 누르면 다이얼로그 닫기
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
                        Navigator.of(context).pop(); // 선택 후 다이얼로그 닫기
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
            borderRadius: BorderRadius.circular(10), // 다이얼로그 모서리를 둥글게 처리
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              hintColor: Colors.lightBlue, // 선택한 날짜의 색상
              colorScheme: ColorScheme.light(
                primary: Colors.blue, // 달력의 주요 색상
                onSurface: Colors.black, // 날짜 텍스트 색상
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue, // 버튼 텍스트 색상
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // 달력 모서리를 둥글게 처리
              ),
              width: MediaQuery.of(context).size.width, // 화면에 맞게 너비 조정
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
                          Navigator.of(context).pop(); // X 버튼을 누르면 다이얼로그 닫기
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CalendarDatePicker(
                      initialDate: _endDate,
                      firstDate: _startDate, // 종료 날짜는 시작 날짜 이후여야 함
                      lastDate: DateTime(DateTime.now().year + 5),
                      onDateChanged: (DateTime newDate) {
                        setState(() {
                          _endDate = newDate;
                          _isStartDateSelected = false;
                        });
                        Navigator.of(context).pop(); // 선택 후 다이얼로그 닫기
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
        child: Container(
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
                  SizedBox(width: 48), // X 버튼과 균형 맞추기 위해 빈 공간 추가
                  Center(
                    child: Text(
                      '일정 추가',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: _cancel, // X 버튼 눌렀을 때 취소 동작
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
                  // 시작 날짜 필드
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickCustomStartDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isStartDateSelected ? Colors.lightBlue : Colors.transparent, // 선택된 경우 파란색 테두리
                          ),
                          color: _isStartDateSelected ? Colors.white : Colors.grey.shade100, // 선택되지 않은 경우 회색 배경
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
                  // 종료 날짜 필드
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickCustomEndDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: !_isStartDateSelected ? Colors.lightBlue : Colors.transparent, // 선택된 경우 파란색 테두리
                          ),
                          color: !_isStartDateSelected ? Colors.white : Colors.grey.shade100, // 선택되지 않은 경우 회색 배경
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
                color: Colors.grey.shade200, // 구분선 색상 설정
                thickness: 1.5, // 구분선 두께 설정
              ),
              SizedBox(height: 20), // 구분선과 텍스트 사이의 여백
              Text(
                '가격 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildPriceOptions(), // 라디오 버튼 2열로 수정된 가격 선택
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity, // 버튼의 너비를 화면 전체로 설정
                height: 50, // 버튼의 높이를 설정
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
      ),
    );
  }

  // 가격 범위를 2열 라디오 버튼으로 배치하고 왼쪽 정렬되도록 수정
  Widget _buildPriceOptions() {
    double horizontalSpacing = 16.0; // 가로 간격
    double verticalSpacing = 16.0; // 세로 간격
    double optionWidth = (MediaQuery.of(context).size.width - 48) / 2; // 가격 옵션의 크기를 기간 선택의 날짜들과 동일하게 설정
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
                  offset: Offset(0, 3), // 그림자의 위치 조정
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
