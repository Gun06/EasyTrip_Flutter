import 'package:flutter/material.dart';

class ReportedReviewsPage extends StatelessWidget {
  const ReportedReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text('리뷰 제목 ${index + 1}'),
            subtitle: Text('신고 사유: 부적절한 내용'),
            trailing: ElevatedButton(
              onPressed: () {
                // 리뷰 상세보기 페이지로 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.3),
              ),
              child: Text('상세보기'),
            ),
          ),
        );
      },
    );
  }
}
