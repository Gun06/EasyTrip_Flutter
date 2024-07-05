import 'package:flutter/material.dart';
import '../activity_sign_up.dart';

class PreferencePage4 extends StatefulWidget {
  final List<String> activityPreferences;
  final List<String> foodPreferences;

  PreferencePage4({required this.activityPreferences, required this.foodPreferences});

  @override
  _PreferencePage4State createState() => _PreferencePage4State();
}

class _PreferencePage4State extends State<PreferencePage4> {
  final List<int> selectedOptions = [];
  final List<String> preferenceLabels = ['호텔', '모텔', '게스트 하우스'];

  void _handleSelection(int index) {
    setState(() {
      if (selectedOptions.contains(index)) {
        selectedOptions.remove(index);
      } else {
        selectedOptions.add(index);
      }
    });
  }

  void _removeSelection(int index) {
    setState(() {
      selectedOptions.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40), // 프로그레스바를 아래로 약간 내리기 위해 크기를 조정
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.75, end: 1.0),
              duration: Duration(seconds: 1),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            // 뒤로가기 버튼과 로그인 페이지로 나가는 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    '숙박은 어디서?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '원하시는 숙박시설을 순서대로 선택해주세요.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 40, // 텍스트가 들어갈 공간 확보
                    child: Center(child: _buildSelectedText()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPreferenceOption(0, '호텔'),
                    SizedBox(height: 8),
                    _buildPreferenceOption(1, '모텔'),
                    SizedBox(height: 8),
                    _buildPreferenceOption(2, '게스트 하우스'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedOptions.length >= 3
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpActivity(
                        activityPreferences: widget.activityPreferences,
                        foodPreferences: widget.foodPreferences,
                        accommodationPreferences: selectedOptions.map((index) => preferenceLabels[index]).toList(),
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedOptions.length >= 3 ? Colors.blue : Colors.grey,
                  padding: EdgeInsets.all(12),
                ),
                child: Center(
                  child: Text(
                    '선호 순서대로 선택해주세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedText() {
    List<Widget> widgets = [];
    for (int i = 0; i < selectedOptions.length; i++) {
      widgets.add(
        Chip(
          label: Text(
            '#${preferenceLabels[selectedOptions[i]]}',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          deleteIcon: Icon(
            Icons.close,
            color: Colors.grey,
            size: 18,
          ),
          onDeleted: () => _removeSelection(selectedOptions[i]),
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
        ),
      );
      if (i < selectedOptions.length - 1) {
        widgets.add(
          SizedBox(width: 8), // 간격 추가
        );
        widgets.add(
          Align(
            alignment: Alignment.center,
            child: Text(
              '>',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        );
        widgets.add(
          SizedBox(width: 8), // 간격 추가
        );
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    );
  }

  Widget _buildPreferenceOption(int index, String text) {
    bool isSelected = selectedOptions.contains(index);
    return GestureDetector(
      onTap: () => _handleSelection(index),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2.0,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
