import 'package:flutter/material.dart';

class BusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('오늘 오후 2:44 출발', style: TextStyle(color: Colors.black)),
              Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('추천순', style: TextStyle(color: Colors.grey)),
              Icon(Icons.refresh, color: Colors.grey),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                RouteCard(
                  duration: '50분',
                  departure: '오후 2:45',
                  arrival: '오후 3:36',
                  details: [
                    '북부시장입구',
                    '강북11 도착 또는 출발',
                    '강북09',
                    '수유역',
                    '서울역',
                    '남영역',
                  ],
                  fare: '1,600원',
                  walk: '도보 10분',
                  wait: '대기 5분 예상',
                ),
                RouteCard(
                  duration: '48분',
                  departure: '오후 2:47',
                  arrival: '오후 3:35',
                  details: [
                    '북부시장입구',
                    '강북12 도착 또는 출발',
                    '강북10',
                    '수유역',
                    '서울역',
                    '남영역',
                  ],
                  fare: '1,500원',
                  walk: '도보 12분',
                  wait: '대기 4분 예상',
                ),
                // 추가 경로 정보 카드
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final String duration;
  final String departure;
  final String arrival;
  final List<String> details;
  final String fare;
  final String walk;
  final String wait;

  RouteCard({
    required this.duration,
    required this.departure,
    required this.arrival,
    required this.details,
    required this.fare,
    required this.walk,
    required this.wait,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$duration  $departure ~ $arrival', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('도보: $walk', style: TextStyle(color: Colors.grey)),
                Text('대기: $wait', style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details.map((detail) => Text(detail)).toList(),
            ),
            SizedBox(height: 8),
            Text('카드: $fare', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
