import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../activity_main.dart';
import 'activity_bike.dart';
import 'activity_bus.dart';
import 'activity_car.dart';
import 'activity_walk.dart';

class TrafficFragment extends StatefulWidget {
  @override
  _TrafficFragmentState createState() => _TrafficFragmentState();
}

class _TrafficFragmentState extends State<TrafficFragment> {
  int selectedIndex = 1; // 초기값으로 자동차 선택
  final PageController _pageController = PageController(initialPage: 1);
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _endFocusNode = FocusNode();

  List<dynamic> _startSearchResults = [];
  List<dynamic> _endSearchResults = [];
  MapPoint? _startPoint;
  MapPoint? _endPoint;

  @override
  void initState() {
    super.initState();
    _startFocusNode.addListener(_onStartFocusChange);
    _endFocusNode.addListener(_onEndFocusChange);
  }

  @override
  void dispose() {
    _startFocusNode.removeListener(_onStartFocusChange);
    _endFocusNode.removeListener(_onEndFocusChange);
    _startFocusNode.dispose();
    _endFocusNode.dispose();
    super.dispose();
  }

  void _onStartFocusChange() {
    if (_startFocusNode.hasFocus) {
      setState(() {
        _endSearchResults.clear();
      });
    }
  }

  void _onEndFocusChange() {
    if (_endFocusNode.hasFocus) {
      setState(() {
        _startSearchResults.clear();
      });
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2)); // 예제용 지연 시간
    print('새로고침 완료');
  }

  void _searchStartLocation(String query) async {
    try {
      final String result = await MethodChannel('com.example.easytrip/search').invokeMethod('search', query);
      final data = jsonDecode(result);
      setState(() {
        _startSearchResults = data['documents'];
      });
    } on PlatformException catch (e) {
      print('Failed to search: ${e.message}');
    }
  }

  void _searchEndLocation(String query) async {
    try {
      final String result = await MethodChannel('com.example.easytrip/search').invokeMethod('search', query);
      final data = jsonDecode(result);
      setState(() {
        _endSearchResults = data['documents'];
      });
    } on PlatformException catch (e) {
      print('Failed to search: ${e.message}');
    }
  }

  void _showRoute() {
    if (_startController.text.isNotEmpty && _endController.text.isNotEmpty) {
      final startPlace = _startSearchResults.firstWhere((place) => place['place_name'] == _startController.text, orElse: () => null);
      final endPlace = _endSearchResults.firstWhere((place) => place['place_name'] == _endController.text, orElse: () => null);

      if (startPlace != null && endPlace != null) {
        double startLat = double.parse(startPlace['y']);
        double startLng = double.parse(startPlace['x']);
        double endLat = double.parse(endPlace['y']);
        double endLng = double.parse(endPlace['x']);

        setState(() {
          _startPoint = MapPoint(latitude: startLat, longitude: startLng);
          _endPoint = MapPoint(latitude: endLat, longitude: endLng);
        });

        MethodChannel('com.example.easytrip/map').invokeMethod('removeMapView').then((_) {
          MethodChannel('com.example.easytrip/map').invokeMethod('moveToLocation', {
            'latitude': startLat,
            'longitude': startLng,
          }).then((_) {
            MethodChannel('com.example.easytrip/map').invokeMethod('addMarker', {
              'latitude': startLat,
              'longitude': startLng,
            });
          }).then((_) {
            MethodChannel('com.example.easytrip/map').invokeMethod('moveToLocation', {
              'latitude': endLat,
              'longitude': endLng,
            }).then((_) {
              MethodChannel('com.example.easytrip/map').invokeMethod('addMarker', {
                'latitude': endLat,
                'longitude': endLng,
              });
            });
          });
        });
      } else {
        print('Failed to find coordinates for the given places.');
      }
    }
  }

  void _onStartPlaceTap(dynamic place) {
    _startController.text = place['place_name'];
    setState(() {
      _startSearchResults.clear();
    });
  }

  void _onEndPlaceTap(dynamic place) {
    _endController.text = place['place_name'];
    setState(() {
      _endSearchResults.clear();
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _onTransportButtonTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 파란색 배경의 상단 부분
          Container(
            color: Color(0xFF4285F4), // 파란 배경 색상
            padding: EdgeInsets.only(top: 50, left: 16, right: 5, bottom: 20), // 상단 여백 추가
            child: Column(
              children: [
                // 교통 수단 선택 버튼과 닫기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 교통 수단 선택 버튼 박스
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTransportButton(Icons.directions_car, 0),
                          _buildTransportButton(Icons.directions_bus, 1),
                          _buildTransportButton(Icons.directions_walk, 2),
                          _buildTransportButton(Icons.directions_bike, 3),
                        ],
                      ),
                    ),
                    // 검색 버튼
                    IconButton(
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: _showRoute, // 검색 버튼이 경로 보기 기능 수행
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // 출발지와 도착지 입력 필드
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startController,
                        focusNode: _startFocusNode,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '출발지',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: _searchStartLocation,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_vert, color: Colors.white),
                      onPressed: () {
                        // 스왑 버튼 기능 추가
                      },
                    ),
                  ],
                ),
                if (_startSearchResults.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      color: Colors.white,
                      height: 180,
                      width: 343,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 5),
                        itemCount: _startSearchResults.length,
                        itemBuilder: (context, index) {
                          final place = _startSearchResults[index];
                          return ListTile(
                            title: Text(place['place_name']),
                            subtitle: Text(place['address_name']),
                            onTap: () => _onStartPlaceTap(place),
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _endController,
                        focusNode: _endFocusNode,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '도착지',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: _searchEndLocation,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        // 더보기 버튼 기능 추가
                      },
                    ),
                  ],
                ),
                if (_endSearchResults.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      color: Colors.white,
                      height: 180,
                      width: 343,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 5),
                        itemCount: _endSearchResults.length,
                        itemBuilder: (context, index) {
                          final place = _endSearchResults[index];
                          return ListTile(
                            title: Text(place['place_name']),
                            subtitle: Text(place['address_name']),
                            onTap: () => _onEndPlaceTap(place),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 지도와 출발 시간 선택 및 경로 정보
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: NeverScrollableScrollPhysics(), // 스와이프 비활성화
              children: [
                CarPage(
                  refreshData: _refreshData,
                  startPoint: _startPoint,
                  endPoint: _endPoint,
                ),
                BusPage(),
                WalkPage(),
                BikePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportButton(IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        color: selectedIndex == index ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20.0), // 알약 형태
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _onTransportButtonTapped(index),
        child: Icon(
          icon,
          color: selectedIndex == index ? Colors.blue : Colors.white,
        ),
      ),
    );
  }
}

class MapPoint {
  final double latitude;
  final double longitude;

  MapPoint({required this.latitude, required this.longitude});

  MapPoint.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'];

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}
