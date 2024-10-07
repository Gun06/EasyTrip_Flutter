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
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _endFocusNode = FocusNode();

  // 동적으로 높이를 변경하기 위한 초기값 설정
  double _scrollHeight = 120; // 기본 높이 설정
  bool _isHeightIncreased = false; // 높이가 한번만 200으로 증가되도록 제어하는 변수

  // 경유지 관련 추가 변수들
  final List<TextEditingController> _waypointControllers = [];
  final List<FocusNode> _waypointFocusNodes = [];
  List<MapPoint?> _waypoints = [];
  List<List<dynamic>> _waypointSearchResults = [];

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

  void _searchWaypointLocation(String query, int index) async {
    try {
      final String result = await MethodChannel('com.example.easytrip/search')
          .invokeMethod('search', query);
      final data = jsonDecode(result);
      setState(() {
        _waypointSearchResults[index] = data['documents'];
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

  void _onWaypointPlaceTap(dynamic place, int index) {
    _waypointControllers[index].text = place['place_name'];
    setState(() {
      _waypoints[index] = MapPoint(
        latitude: double.parse(place['y']),
        longitude: double.parse(place['x']),
      );
      _waypointSearchResults[index].clear();
    });
  }

  void addWaypoints(List<Map<String, double>> waypoints) {
    MethodChannel('com.example.easytrip/map').invokeMethod('addWaypoints', waypoints);
  }

  void drawRouteWithWaypoints(double startLat, double startLng, double endLat, double endLng, List<Map<String, double>> waypoints) {
    // 경유지 포함하여 POST 방식으로 경로 요청
    MethodChannel('com.example.easytrip/map').invokeMethod('drawRouteWithWaypoints', {
      'startLatitude': startLat,
      'startLongitude': startLng,
      'endLatitude': endLat,
      'endLongitude': endLng,
      'waypoints': waypoints,  // POST 방식으로 경유지 전달
    }).then((_) {
      // 경로 그리기 완료 후 상태 업데이트
      print("경로 계산 및 그리기 완료: 출발지($startLat, $startLng), 도착지($endLat, $endLng), 경유지($waypoints)");
      setState(() {});
    }).catchError((error) {
      print("경로 그리기 중 오류 발생: $error");
    });
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

  void _addWaypoint() {
    setState(() {
      _waypointControllers.add(TextEditingController());
      _waypointFocusNodes.add(FocusNode());
      _waypoints.add(null);
      _waypointSearchResults.add([]);

      // 경유지가 추가될 때 높이가 200으로 한 번만 증가
      if (!_isHeightIncreased) {
        _scrollHeight = 200;
        _isHeightIncreased = true;
      }
    });
  }

  void _removeWaypoint(int index) {
    setState(() {
      _waypointControllers.removeAt(index);
      _waypointFocusNodes.removeAt(index);
      _waypoints.removeAt(index);
      _waypointSearchResults.removeAt(index);

      // 경유지가 모두 삭제되면 높이를 다시 120으로 설정
      if (_waypointControllers.isEmpty) {
        _scrollHeight = 120;
        _isHeightIncreased = false;
      }
    });
  }

  // drawRouteLine 호출 부분 수정
  void _showRoute() {
    if (_startPoint != null && _endPoint != null) {
      double startLat = _startPoint!.latitude;
      double startLng = _startPoint!.longitude;
      double endLat = _endPoint!.latitude;
      double endLng = _endPoint!.longitude;

      // 경유지 리스트를 구성
      List<Map<String, dynamic>> waypointCoords = [];
      for (var waypoint in _waypoints) {
        if (waypoint != null) {
          waypointCoords.add({
            'latitude': waypoint.latitude,
            'longitude': waypoint.longitude,
          });
        }
      }

      // 선택된 교통수단에 맞는 메소드 설정
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

      // Start point 설정
      MethodChannel('com.example.easytrip/map').invokeMethod('moveToLocation', {
        'latitude': startLat,
        'longitude': startLng,
        'isStartPoint': true,
      }).then((_) {
        // 출발지 라벨 추가
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
            // 도착지 라벨 추가
            MethodChannel('com.example.easytrip/map').invokeMethod('addLabel', {
              'latitude': endLat,
              'longitude': endLng,
              'isStartPoint': false,
            }).then((_) {
              // 경유지 라벨 추가
              for (int i = 0; i < waypointCoords.length; i++) {
                final waypoint = waypointCoords[i];
                MethodChannel('com.example.easytrip/map').invokeMethod('addLabel', {
                  'latitude': waypoint['latitude'],
                  'longitude': waypoint['longitude'],
                  'isWaypoint': true,  // 경유지임을 표시
                });
              }

              // 경유지 포함한 경로 계산
              MethodChannel('com.example.easytrip/map').invokeMethod(methodToCall, {
                'startLatitude': startLat,
                'startLongitude': startLng,
                'endLatitude': endLat,
                'endLongitude': endLng,
                'waypoints': waypointCoords,
              }).then((_) {
                // 경로 그리기 완료 후 상태 업데이트
                print("Start: $startLat, $startLng, End: $endLat, $endLng, Waypoints: $waypointCoords");
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

                // 스크롤이 가능한 출발지, 경유지, 도착지 리스트 영역
                Container(
                  height: _scrollHeight,  // 동적으로 변경된 높이를 적용
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 출발지 필드
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
                        // 경유지 필드 섹션
                        if (_startSearchResults.isNotEmpty)
                          _buildSearchResults(_startSearchResults, _onStartPlaceTap),
                        _buildWaypointsSection(),  // 경유지 섹션
                        SizedBox(height: 8),
                        // 도착지 필드
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
                              icon: Icon(Icons.add, color: Colors.white),
                              onPressed: _addWaypoint,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (_startSearchResults.isNotEmpty)
                  _buildSearchResults(_startSearchResults, _onStartPlaceTap),
                if (_endSearchResults.isNotEmpty)
                  _buildSearchResults(_endSearchResults, _onEndPlaceTap),
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

  // 경유지 섹션 빌드
  Widget _buildWaypointsSection() {
    return Column(
      children: [
        for (int i = 0; i < _waypointControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8.0), // 필드 간 간격 조정
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          TextField(
                            controller: _waypointControllers[i],
                            focusNode: _waypointFocusNodes[i],
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '경유지',
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
                            onChanged: (query) => _searchWaypointLocation(query, i), // 경유지 검색 호출
                          ),
                          Positioned(
                            right: 8,
                            top: 6,
                            child: IconButton(
                              icon: Icon(Icons.remove, color: Colors.white),
                              onPressed: () => _removeWaypoint(i),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12), // 스왑 버튼과 필드 사이 간격 조절
                    Icon(Icons.swap_vert, color: Colors.white), // 드래그 앤 드롭 버튼
                    SizedBox(width: 12), // 스왑 버튼과 필드 사이 간격 조절
                  ],
                ),
                // 경유지 검색 결과 표시
                if (_waypointSearchResults[i].isNotEmpty) _buildWaypointSearchResults(i),
              ],
            ),
          ),
      ],
    );
  }

  // 검색 결과 빌드
  Widget _buildSearchResults(List<dynamic> searchResults, Function(dynamic) onTap) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        color: Colors.white,
        height: 180,
        width: 343,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 5),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final place = searchResults[index];
            return ListTile(
              title: Text(place['place_name']),
              subtitle: Text(place['address_name']),
              onTap: () => onTap(place),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWaypointSearchResults(int index) {
    // 경유지별로 고유한 검색 결과 리스트를 가져옴
    List<dynamic> searchResults = _waypointSearchResults[index];

    if (searchResults.isEmpty) return SizedBox.shrink();  // 검색 결과가 없으면 아무것도 보여주지 않음

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        color: Colors.white,
        height: 180,
        width: 343,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 5),
          itemCount: searchResults.length,
          itemBuilder: (context, resultIndex) {
            final place = searchResults[resultIndex];
            return ListTile(
              title: Text(place['place_name']),
              subtitle: Text(place['address_name']),
              onTap: () => _onWaypointPlaceTap(place, index), // 경유지 필드 인덱스에 맞는 선택 처리
            );
          },
        ),
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
}