import 'package:flutter/material.dart';
import 'activity_admin_blocked_account_detail.dart';

class BlockedAccountsPage extends StatelessWidget {
  final String searchQuery;
  final String sortOption;

  const BlockedAccountsPage({
    Key? key,
    required this.searchQuery,
    required this.sortOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> accounts = List.generate(10, (index) => '차단 계정 ${index + 1}');
    List<String> filteredAccounts = accounts.where((account) => account.contains(searchQuery)).toList();

    if (filteredAccounts.isEmpty) {
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
        itemCount: filteredAccounts.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(filteredAccounts[index]),
              subtitle: Text('차단 사유: 불법 활동'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BlockedAccountDetailPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.7),
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
