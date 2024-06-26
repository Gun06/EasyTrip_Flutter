import 'package:flutter/material.dart';

class WrittenReviewsPage extends StatelessWidget {
  final String searchQuery;
  final String sortOption;

  const WrittenReviewsPage({
    Key? key,
    required this.searchQuery,
    required this.sortOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> reviews = List.generate(10, (index) => '작성 리뷰 ${index + 1}');
    List<String> filteredReviews = reviews.where((review) => review.contains(searchQuery)).toList();

    if (filteredReviews.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('검색결과 없음', style: TextStyle(fontSize: 16, color: Colors.black)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: filteredReviews.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(filteredReviews[index]),
              subtitle: Text('작성자: user${index + 1}'),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.7),
                ),
                child: Text(
                  '상세보기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
