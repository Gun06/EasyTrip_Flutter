import 'package:flutter/material.dart';
import 'activity_preference_3.dart';

class PreferencePage2 extends StatefulWidget {
  @override
  _PreferencePage2State createState() => _PreferencePage2State();
}

class _PreferencePage2State extends State<PreferencePage2> {
  final List<int> selectedImages = [];
  final List<String> preferenceLabels = ['음식', '숙박', '문화체험', '관광지', '디저트']; // 디저트 추가

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
              tween: Tween<double>(begin: 0.50, end: 0.75),
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
                    '여행 시 가장 고려하는 요소는?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '취향을 분석해서 좋아할 여행코스를 추천해드릴게요!',
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
                          child: _buildPreferenceOption(0, '음식', 'assets/ph_food.jpg', 3 / 4),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildPreferenceOption(1, '숙박', 'assets/ph_lodgment.jpg', 3 / 4),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildPreferenceOption(2, '문화체험', 'assets/ph_play.jpg', 3 / 4),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPreferenceOption(3, '관광지', 'assets/ph_tourist.jpg', 3 / 4),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildPreferenceOption(4, '디저트', 'assets/ph_dessert.jpeg', 3 / 4),
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
                      pageBuilder: (context, animation, secondaryAnimation) => PreferencePage3(
                        activityPreferences: selectedImages
                            .map((index) => preferenceLabels[index])
                            .toList(),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
