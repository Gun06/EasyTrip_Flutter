import 'package:flutter/material.dart';

class MemberInfoPage extends StatelessWidget {
  final String searchQuery;
  final String sortOption;

  const MemberInfoPage({
    Key? key,
    required this.searchQuery,
    required this.sortOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> members = List.generate(10, (index) => '회원 정보 ${index + 1}');
    List<String> filteredMembers = members.where((member) => member.contains(searchQuery)).toList();

    // Sort the filteredMembers based on sortOption
    if (sortOption == "이름 순 (한글)" || sortOption == "이름 순 (영어)") {
      filteredMembers.sort();
    } else if (sortOption == "날짜 순") {
      // Implement date sorting if you have date data associated
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: filteredMembers.isEmpty
          ? Center(
        child: Text(
          '검색결과 없음',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      )
          : ListView.builder(
        itemCount: filteredMembers.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4, // 그림자 효과 추가
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(filteredMembers[index]),
              subtitle: Text('이름: 홍길동'),
              trailing: ElevatedButton(
                onPressed: () {
                  // 회원 상세정보 페이지로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.7),
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
