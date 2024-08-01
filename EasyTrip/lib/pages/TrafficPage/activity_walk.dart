import 'package:flutter/material.dart';

import 'fragment_traffic.dart';

class WalkPage extends StatefulWidget {
  static List<MapPoint> _polylinePoints = [];

  static void setPolylinePoints(List<MapPoint> points) {
    _polylinePoints = points;
  }

  final Future<void> Function() refreshData;

  WalkPage({required this.refreshData});

  @override
  _WalkPageState createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.refreshData,
      child: ListView(
        children: [
          Center(
            child: Text('도보 페이지', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
