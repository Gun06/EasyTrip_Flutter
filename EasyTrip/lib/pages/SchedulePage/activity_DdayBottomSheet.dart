import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DdayBottomSheet extends StatefulWidget {
  final DateTime startDate;
  final VoidCallback onClose;

  DdayBottomSheet({required this.startDate, required this.onClose});

  @override
  _DdayBottomSheetState createState() => _DdayBottomSheetState();
}

class _DdayBottomSheetState extends State<DdayBottomSheet> {
  List<Map<String, String>> recommendations = [
    {'title': '북한산', 'location': '서울, 대한민국', 'price': '₩4,000', 'imageUrl': 'https://via.placeholder.com/150'},
    {'title': '정동진 해변', 'location': '강릉, 대한민국', 'price': '₩4,000', 'imageUrl': 'https://via.placeholder.com/150'},
    {'title': '한라산', 'location': '제주도, 대한민국', 'price': '₩4,000', 'imageUrl': 'https://via.placeholder.com/150'},
    {'title': '한라산', 'location': '제주도, 대한민국', 'price': '₩4,000', 'imageUrl': 'https://via.placeholder.com/150'},
    {'title': '한라산', 'location': '제주도, 대한민국', 'price': '₩4,000', 'imageUrl': 'https://via.placeholder.com/150'},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '일정추가',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('사용자의 선호도에 의거하여 추천한 결과입니다.'),
                SizedBox(height: 16),
                _buildDateDisplay(), // 선택된 날짜만 표시하는 함수
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '일정 이름을 입력하세요',
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text("AI Recommend Success"),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Colors.grey),
                _buildRecommendationSection(context),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45, // 버튼의 높이 설정
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.9),
                    ),
                    child: Text(
                      'Complete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 선택한 날짜를 표시하는 함수
  Widget _buildDateDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.black),
          SizedBox(width: 8),
          Text(
            DateFormat('yyyy/MM/dd').format(widget.startDate), // 시작 날짜만 표시
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        _buildReorderableList(),
      ],
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = recommendations.removeAt(oldIndex);
          recommendations.insert(newIndex, item);
        });
      },
      children: List.generate(recommendations.length, (index) {
        final recommendation = recommendations[index];
        return Material(
          key: ValueKey(recommendation),
          color: Colors.white, // 기본 배경색
          child: ListTile(
            title: Text(recommendation['title']!),
            subtitle: Text(
              recommendation['price']!,
              style: TextStyle(color: Colors.grey), // 원하는 색상으로 변경
            ),
            trailing: Icon(Icons.drag_handle),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                recommendation['imageUrl']!,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            // 드래그 중일 때의 배경색 변경
            tileColor: Colors.white,
            selectedTileColor: Colors.blue.shade100, // 드래그 시 배경색
            selected: false, // 필요 시 드래그 선택 상태를 조정
          ),
        );
      }),
    );
  }
}
