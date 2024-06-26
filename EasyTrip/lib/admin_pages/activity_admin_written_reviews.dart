import 'package:flutter/material.dart';

class WrittenReviewsPage extends StatelessWidget {
  const WrittenReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text('리뷰 제목 ${index + 1}'),
            subtitle: Text('작성자: user${index + 1}'),
            trailing: ElevatedButton(
              onPressed: () {
                // 리뷰 상세보기 페이지로 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.3),
              ),
              child: Text('상세보기'),
            ),
          ),
        );
      },
    );
  }
}
