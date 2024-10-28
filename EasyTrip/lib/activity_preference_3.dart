import 'package:flutter/material.dart';
import 'activity_preference_4.dart';

class PreferencePage3 extends StatefulWidget {
  final List<String> activityPreferences;

  PreferencePage3({required this.activityPreferences});

  @override
  _PreferencePage3State createState() => _PreferencePage3State();
}

class _PreferencePage3State extends State<PreferencePage3> {
  final List<int> selectedImages = [];
  final List<String> preferenceLabels = ['한식', '중식', '일식', '양식']; // 디저트 제거

  void _handleSelection(int index) {
    setState(() {
      if (selectedImages.contains(index)) {
        selectedImages.remove(index);
      } else {
        selectedImages.add(index);
      }
    });
  }

  void _removeSelection(int index) {
    setState(() {
      selectedImages.remove(index);
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
            SizedBox(height: 40),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.25, end: 0.50),
              duration: Duration(seconds: 1),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
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
                    '어떤 음식을 즐겨 드시나요?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '여러분의 입맛에 맞는 음식 유형을 추천해드립니다.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 40,
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildPreferenceOption(0, '한식', 'assets/ph_korea_food.jpeg', 3 / 4),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildPreferenceOption(1, '중식', 'assets/ph_china_food.jpeg', 3 / 4),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPreferenceOption(2, '일식', 'assets/ph_japan_food.webp', 3 / 4),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildPreferenceOption(3, '양식', 'assets/ph_italy_food.jpeg', 3 / 4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedImages.length >= 4
                    ? () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => PreferencePage4(
                        activityPreferences: widget.activityPreferences,
                        foodPreferences: selectedImages.map((index) => preferenceLabels[index]).toList(),
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedImages.length >= 4 ? Colors.blue : Colors.grey,
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
    for (int i = 0; i < selectedImages.length; i++) {
      widgets.add(
        Chip(
          label: Text(
            '#${preferenceLabels[selectedImages[i]]}',
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
          onDeleted: () => _removeSelection(selectedImages[i]),
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
        ),
      );
      if (i < selectedImages.length - 1) {
        widgets.add(SizedBox(width: 8));
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
        widgets.add(SizedBox(width: 8));
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

  Widget _buildPreferenceOption(int index, String text, String imagePath, double aspectRatio) {
    bool isSelected = selectedImages.contains(index);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: () => _handleSelection(index),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected ? Border.all(color: Colors.blue, width: 3.0) : null,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              ColorFiltered(
                colorFilter: isSelected
                    ? ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : ColorFilter.mode(Colors.transparent, BlendMode.saturation),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
