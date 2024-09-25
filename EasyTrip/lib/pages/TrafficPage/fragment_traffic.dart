import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int selectedIndex = 1;
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

  void _searchStartLocation(String query) async {
    try {
      final String result = await MethodChannel('com.example.easytrip/search')
          .invokeMethod('search', query);
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
      final String result = await MethodChannel('com.example.easytrip/search')
          .invokeMethod('search', query);
      final data = jsonDecode(result);
      setState(() {
        _endSearchResults = data['documents'];
      });
    } on PlatformException catch (e) {
      print('Failed to search: ${e.message}');
    }
  }

  void _onStartPlaceTap(dynamic place) {
    _startController.text = place['place_name'];
    setState(() {
      _startPoint = MapPoint(
        latitude: double.parse(place['y']),
        longitude: double.parse(place['x']),
      );
      _startSearchResults.clear();
    });

    print('출발지 선택: ${_startPoint!.latitude}, ${_startPoint!.longitude}');
  }

  void _onEndPlaceTap(dynamic place) {
    _endController.text = place['place_name'];
    setState(() {
      _endPoint = MapPoint(
        latitude: double.parse(place['y']),
        longitude: double.parse(place['x']),
      );
      _endSearchResults.clear();
    });

    print('도착지 선택: ${_endPoint!.latitude}, ${_endPoint!.longitude}');
  }

  void _swapLocations() {
    setState(() {
      String tempText = _startController.text;
      _startController.text = _endController.text;
      _endController.text = tempText;

      MapPoint? tempPoint = _startPoint;
      _startPoint = _endPoint;
      _endPoint = tempPoint;

      print("Swapped: 출발지 -> ${_startPoint?.latitude}, ${_startPoint?.longitude}, 도착지 -> ${_endPoint?.latitude}, ${_endPoint?.longitude}");

      MethodChannel('com.example.easytrip/map').invokeMethod('removeLabel');
      _showRoute();
    });
  }

  // drawRouteLine 호출 부분 수정
  void _showRoute() {
    if (_startPoint != null && _endPoint != null) {
      double startLat = _startPoint!.latitude;
      double startLng = _startPoint!.longitude;
      double endLat = _endPoint!.latitude;
      double endLng = _endPoint!.longitude;

      String methodToCall;
      switch (selectedIndex) {
        case 0:
        // 차량 경로 탐색
          methodToCall = 'getCarRoute';
          break;
        case 1:
        // 버스 경로 탐색 (별도의 로직 필요할 수 있음)
          methodToCall = 'getBusRoute';  // 구현에 따라 수정
          break;
        case 2:
        // 도보 경로 탐색
          methodToCall = 'getWalkingRoute';
          break;
        case 3:
        // 자전거 경로 탐색
          methodToCall = 'getBicycleRoute';
          break;
        default:
          methodToCall = 'drawRouteLine'; // 기본적으로 drawRouteLine 사용
      }

      // Start point 설정
      MethodChannel('com.example.easytrip/map').invokeMethod('moveToLocation', {
        'latitude': startLat,
        'longitude': startLng,
        'isStartPoint': true,
      }).then((_) {
        // Start point 라벨 추가
        MethodChannel('com.example.easytrip/map').invokeMethod('addLabel', {
          'latitude': startLat,
          'longitude': startLng,
          'isStartPoint': true,
        }).then((_) {
          // End point 설정 및 라벨 추가
          MethodChannel('com.example.easytrip/map').invokeMethod('moveToLocation', {
            'latitude': endLat,
            'longitude': endLng,
            'isStartPoint': false,
          }).then((_) {
            MethodChannel('com.example.easytrip/map').invokeMethod('addLabel', {
              'latitude': endLat,
              'longitude': endLng,
              'isStartPoint': false,
            }).then((_) {
              // 각 교통수단에 맞는 경로 탐색 메서드 호출
              MethodChannel('com.example.easytrip/map').invokeMethod(methodToCall, {
                'startLatitude': startLat,
                'startLongitude': startLng,
                'endLatitude': endLat,
                'endLongitude': endLng,
              }).then((_) {
                setState(() {});
              }).catchError((error) {
                print("Error drawing route line: $error");
              });
            });
          });
        });
      });
    } else {
      print("Start or end location is not selected.");
    }
  }


  void _onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _onTransportButtonTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Color(0xFF4285F4),
            padding: EdgeInsets.only(top: 50, left: 16, right: 5, bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    IconButton(
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: _showRoute,
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
                      onPressed: _swapLocations,
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
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: NeverScrollableScrollPhysics(),
              children: [
                CarPage(
                  refreshData: () async {},
                  startPoint: _startPoint,
                  endPoint: _endPoint,
                ),
                BusPage(),
                WalkPage(
                  refreshData: () async {},
                  startPoint: _startPoint,
                  endPoint: _endPoint,
                ),
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
        borderRadius: BorderRadius.circular(20.0),
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