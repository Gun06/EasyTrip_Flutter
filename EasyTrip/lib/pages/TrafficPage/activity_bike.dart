import 'package:flutter/material.dart';

class BikePage extends StatelessWidget {
  final Future<void> Function() refreshData;

  BikePage({required this.refreshData});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView(
        children: [
          Center(
            child: Text('자전거 페이지', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
