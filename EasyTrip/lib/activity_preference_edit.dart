import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityPreferenceEditPage extends StatefulWidget {
  final String username;
  final String accessToken;

  ActivityPreferenceEditPage({required this.username, required this.accessToken});

  @override
  _ActivityPreferenceEditPageState createState() => _ActivityPreferenceEditPageState();
}

class _ActivityPreferenceEditPageState extends State<ActivityPreferenceEditPage> {
  final List<String> _availableActivities = ['음식', '숙박', '문화체험', '관광지', '디저트'];
  final List<String> _availableFoods = ['한식', '중식', '일식', '양식'];
  final List<String> _availableAccommodations = ['호텔', '모텔', '게스트 하우스'];

  List<String> _selectedActivities = [];
  List<String> _selectedFoods = [];
  List<String> _selectedAccommodations = [];

  void _savePreferences() async {
    // 각 선호도 카테고리를 코드 형식으로 변환
    List<String> activityCodes = _selectedActivities.map((activity) {
      switch (activity) {
        case '음식': return 'A1';
        case '숙박': return 'B1';
        case '문화체험': return 'C1';
        case '관광지': return 'D1';
        case '디저트': return 'E1';
        default: return '';
      }
    }).toList();

    List<String> foodCodes = _selectedFoods.map((food) {
      switch (food) {
        case '한식': return 'A1';
        case '중식': return 'A2';
        case '일식': return 'A3';
        case '양식': return 'A4';
        default: return '';
      }
    }).toList();

    List<String> accommodationCodes = _selectedAccommodations.map((accommodation) {
      switch (accommodation) {
        case '호텔': return 'B1';
        case '모텔': return 'B2';
        case '게스트 하우스': return 'B3';
        default: return '';
      }
    }).toList();

    // 음식과 숙박 선호도에서 첫 번째 선택으로 대체
    if (foodCodes.isNotEmpty && activityCodes.contains('A1')) {
      activityCodes[activityCodes.indexOf('A1')] = foodCodes.first;
    }
    if (accommodationCodes.isNotEmpty && activityCodes.contains('B1')) {
      activityCodes[activityCodes.indexOf('B1')] = accommodationCodes.first;
    }

    // 선호도 코드 리스트를 하나의 문자열로 결합
    String preferenceCode = activityCodes.join();

    // 로그 출력
    print("Selected Activities: $_selectedActivities");
    print("Selected Foods: $_selectedFoods");
    print("Selected Accommodations: $_selectedAccommodations");
    print("Generated Preference Code: $preferenceCode");

    final url = Uri.parse('http://44.214.72.11:8080/eztrip/update-categories');
    final preferences = {
      'categories': preferenceCode, // 서버가 요구하는 형식에 맞춤
    };

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode(preferences),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '선호도가 저장되었습니다.');
      Navigator.pop(context);
    } else {
      print("Failed to save preferences: ${response.statusCode}");
      print("Response body: ${response.body}");
      Fluttertoast.showToast(msg: '선호도 저장에 실패했습니다.');
    }
  }

  Widget _buildPreferenceList(String title, List<String> options, List<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedOptions.remove(option);
                  } else {
                    selectedOptions.add(option);
                  }
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    isSelected
                        ? CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      child: Text(
                        '${selectedOptions.indexOf(option) + 1}',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    )
                        : SizedBox(width: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? Colors.blue : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        Divider(color: Colors.grey.shade300, thickness: 1),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          '선호도 수정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: _savePreferences,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreferenceList(
              '활동 선호도',
              _availableActivities,
              _selectedActivities,
            ),
            _buildPreferenceList(
              '음식 선호도',
              _availableFoods,
              _selectedFoods,
            ),
            _buildPreferenceList(
              '숙소 선호도',
              _availableAccommodations,
              _selectedAccommodations,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
