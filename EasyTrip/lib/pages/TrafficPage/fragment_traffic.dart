import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../activity_main.dart';
import 'activity_bike.dart';
import 'activity_car.dart';
import 'activity_walk.dart';

class TrafficFragment extends StatefulWidget {
  @override
  _TrafficFragmentState createState() => _TrafficFragmentState();
}

class _TrafficFragmentState extends State<TrafficFragment> {
  int selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  bool _isExpanded = false; // 패널이 펼쳐졌는지 여부
  double _containerHeight = 140; // 컨테이너 높이 초기값

  // 위치 관련 변수들
  List<LocationItem> _locations = []; // 위치 아이템 리스트 (출발지, 경유지, 도착지 포함)
  List<List<dynamic>> _searchResults = []; // 각 위치 아이템의 검색 결과 리스트

  @override
  void initState() {
    super.initState();
    // 초기에는 출발지와 도착지 필드를 추가합니다.
    _addLocationItem(isStart: true);
    _addLocationItem(isEnd: true);
  }

  // 위치 아이템 추가 함수
  void _addLocationItem({bool isStart = false, bool isEnd = false}) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    focusNode.addListener(() => _onFocusChange(focusNode));

    setState(() {
      _locations.insert(
        isEnd ? _locations.length : (_locations.isNotEmpty ? _locations.length - 1 : 0),
        LocationItem(
          controller: controller,
          focusNode: focusNode,
          isStart: isStart,
          isEnd: isEnd,
        ),
      );
      _searchResults.add([]);
    });
  }

  // 위치 아이템 제거 함수
  void _removeLocationItem(int index) {
    setState(() {
      _locations[index].focusNode.dispose();
      _locations.removeAt(index);
      _searchResults.removeAt(index);

      // 위치에 따른 아이콘 업데이트
      for (int i = 0; i < _locations.length; i++) {
        _locations[i].isStart = i == 0;
        _locations[i].isEnd = i == _locations.length - 1;
      }
    });
  }

  // 포커스 변경 시 호출되는 함수
  void _onFocusChange(FocusNode focusNode) {
    setState(() {
      // 모든 검색 결과를 초기화합니다.
      _searchResults = List.generate(_locations.length, (_) => []);
    });
  }

  // 위치 검색 함수
  void _searchLocation(String query, int index) async {
    try {
      final String result = await MethodChannel('com.example.easytrip/search')
          .invokeMethod('search', query);
      final data = jsonDecode(result);
      setState(() {
        _searchResults[index] = data['documents'];
      });
    } on PlatformException catch (e) {
      print('Failed to search: ${e.message}');
    }
  }

  // 장소 선택 시 호출되는 함수
  void _onPlaceTap(dynamic place, int index) {
    _locations[index].controller.text = place['place_name'];
    setState(() {
      _locations[index].point = MapPoint(
        latitude: double.parse(place['y']),
        longitude: double.parse(place['x']),
      );
      _searchResults[index].clear();
    });
  }

  // 경로 표시 함수
  void _showRoute() {
    if (_locations.isEmpty || _locations.length < 2) {
      print("출발지와 도착지를 설정해주세요.");
      return;
    }

    final startPoint = _locations.first.point;
    final endPoint = _locations.last.point;

    if (startPoint == null || endPoint == null) {
      print("출발지와 도착지를 선택해주세요.");
      return;
    }

    final waypoints = _locations.sublist(1, _locations.length - 1).where((loc) => loc.point != null).map((loc) {
      return {
        'latitude': loc.point!.latitude,
        'longitude': loc.point!.longitude,
      };
    }).toList();

    // 교통수단에 따른 메소드 설정
    String methodToCall;
    switch (selectedIndex) {
      case 0:
        methodToCall = 'getCarRoute';
        break;
      case 1:
        methodToCall = 'getWalkingRoute';
        break;
      case 2:
        methodToCall = 'getBicycleRoute';
        break;
      default:
        methodToCall = 'drawRouteLine';
    }

    // 지도에 경로 표시
    MethodChannel('com.example.easytrip/map').invokeMethod('removeLabel');
    MethodChannel('com.example.easytrip/map').invokeMethod(methodToCall, {
      'startLatitude': startPoint.latitude,
      'startLongitude': startPoint.longitude,
      'endLatitude': endPoint.latitude,
      'endLongitude': endPoint.longitude,
      'waypoints': waypoints,
    }).then((_) {
      // 라벨 추가
      MethodChannel('com.example.easytrip/map').invokeMethod('addLabel', {
        'latitude': startPoint.latitude,
        'longitude': startPoint.longitude,
        'isStartPoint': true,
      });
      MethodChannel('com.example.easytrip/map').invokeMethod('addLabel', {
        'latitude': endPoint.latitude,
        'longitude': endPoint.longitude,
        'isStartPoint': false,
      });
      for (var waypoint in waypoints) {
        MethodChannel('com.example.easytrip/map').invokeMethod('addLabel', {
          'latitude': waypoint['latitude'],
          'longitude': waypoint['longitude'],
          'isWaypoint': true,
        });
      }
    }).catchError((error) {
      print("Error drawing route line: $error");
    });
  }

  // 드래그 앤 드롭 시 호출되는 함수
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _locations.removeAt(oldIndex);
      _locations.insert(newIndex, item);

      final result = _searchResults.removeAt(oldIndex);
      _searchResults.insert(newIndex, result);

      // 위치에 따른 아이콘 업데이트
      for (int i = 0; i < _locations.length; i++) {
        _locations[i].isStart = i == 0;
        _locations[i].isEnd = i == _locations.length - 1;
      }
    });
  }

  // 교통수단 선택 함수
  void _onTransportButtonTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  // 패널 확장/축소 토글 함수
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _containerHeight = _isExpanded ? 400 : 140;
    });
  }

  // 위젯 빌드 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Color(0xFF4285F4),
            padding: EdgeInsets.only(top: 50, left: 16, right: 5, bottom: 5),
            child: Column(
              children: [
                // 교통수단 선택 및 경로 표시 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTransportButton(Icons.directions_car, 0),
                          _buildTransportButton(Icons.directions_walk, 1),
                          _buildTransportButton(Icons.directions_bike, 2),
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

                // 위치 리스트 영역
                Container(
                  height: _containerHeight,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          onReorder: _onReorder,
                          header: SizedBox(height: 5), // 출발지 입력 필드 위에 공간 추가
                          children: [
                            for (int index = 0; index < _locations.length; index++)
                              _buildLocationItem(index),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 펼쳐보기 아이콘
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                  onPressed: _toggleExpanded,
                ),
              ],
            ),
          ),

          // 페이지 뷰 영역
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              physics: NeverScrollableScrollPhysics(),
              children: [
                CarPage(
                  refreshData: () async {},
                  startPoint: _locations.first.point,
                  endPoint: _locations.last.point,
                ),
                WalkPage(
                  refreshData: () async {},
                  startPoint: _locations.first.point,
                  endPoint: _locations.last.point,
                ),
                BikePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 위치 아이템 빌드 함수
  Widget _buildLocationItem(int index) {
    final location = _locations[index];
    return Column(
      key: ValueKey(location),
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: location.controller,
                    focusNode: location.focusNode,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: location.isStart
                          ? '출발지'
                          : location.isEnd
                          ? '도착지'
                          : '경유지',
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    onChanged: (query) => _searchLocation(query, index),
                  ),
                  // 경유지일 때만 - 버튼을 필드 안에 표시
                  if (!location.isStart && !location.isEnd)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(Icons.remove, color: Colors.white),
                        onPressed: () => _removeLocationItem(index),
                        padding: EdgeInsets.only(right: 12),
                        iconSize: 24,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // 아이콘 변경 로직: 모든 아이콘을 IconButton으로 통일
            IconButton(
              icon: location.isEnd
                  ? Icon(Icons.add, color: Colors.white)
                  : Icon(Icons.swap_vert, color: Colors.white),
              onPressed: location.isEnd ? () => _addLocationItem() : () {},
              padding: EdgeInsets.only(right: 12),
              iconSize: 24,
            ),
          ],
        ),
        if (_searchResults[index].isNotEmpty) _buildSearchResults(index),
        SizedBox(height: 8),
      ],
    );
  }

  // 검색 결과 빌드 함수
  Widget _buildSearchResults(int index) {
    List<dynamic> results = _searchResults[index];
    if (results.isEmpty) return SizedBox.shrink();

    return Container(
      color: Colors.white,
      height: 180,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 5),
        itemCount: results.length,
        itemBuilder: (context, resultIndex) {
          final place = results[resultIndex];
          return ListTile(
            title: Text(place['place_name']),
            subtitle: Text(place['address_name']),
            onTap: () => _onPlaceTap(place, index),
          );
        },
      ),
    );
  }

  // 교통수단 버튼 빌드 함수
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

// 위치 아이템 클래스
class LocationItem {
  final TextEditingController controller;
  final FocusNode focusNode;
  bool isStart;
  bool isEnd;
  MapPoint? point;

  LocationItem({
    required this.controller,
    required this.focusNode,
    this.isStart = false,
    this.isEnd = false,
    this.point,
  });
}

// 지도 좌표 클래스
class MapPoint {
  final double latitude;
  final double longitude;

  MapPoint({required this.latitude, required this.longitude});
}
