import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../activity_main.dart';

class TrafficFragment extends StatefulWidget {
  @override
  _TrafficFragmentState createState() => _TrafficFragmentState();
}

class _TrafficFragmentState extends State<TrafficFragment> {
  int selectedIndex = 1; // 초기값으로 버스 선택
  final PageController _pageController = PageController(initialPage: 1);
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _endFocusNode = FocusNode();
  static const searchChannel = MethodChannel('com.example.easytrip/search');
  static const mapChannel = MethodChannel('com.example.easytrip/map');

  List<dynamic> _startSearchResults = [];
  List<dynamic> _endSearchResults = [];

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
      final String result = await searchChannel.invokeMethod('search', query);
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
      final String result = await searchChannel.invokeMethod('search', query);
      final data = jsonDecode(result);
      setState(() {
        _endSearchResults = data['documents'];
      });
    } on PlatformException catch (e) {
      print('Failed to search: ${e.message}');
    }
  }

  void _showRoute() async {
    if (_startController.text.isNotEmpty && _endController.text.isNotEmpty) {
      // 출발지와 도착지의 좌표를 지오코딩하여 얻습니다.
      final startPlace = _startSearchResults.firstWhere((place) => place['place_name'] == _startController.text, orElse: () => null);
      final endPlace = _endSearchResults.firstWhere((place) => place['place_name'] == _endController.text, orElse: () => null);

      if (startPlace != null && endPlace != null) {
        double startLat = double.parse(startPlace['y']);
        double startLng = double.parse(startPlace['x']);
        double endLat = double.parse(endPlace['y']);
        double endLng = double.parse(endPlace['x']);

        try {
          print('Requesting route from ($startLat, $startLng) to ($endLat, $endLng)');
          final String result = await mapChannel.invokeMethod('getRoute', {
            'startLatitude': startLat,
            'startLongitude': startLng,
            'endLatitude': endLat,
            'endLongitude': endLng,
          });

          final data = jsonDecode(result);
          final routes = data['routes'];
          if (routes.isNotEmpty) {
            final route = routes[0];
            final sections = route['sections'];
            List<MapPoint> polylinePoints = [];
            for (var section in sections) {
              final roads = section['roads'];
              for (var road in roads) {
                final vertexes = road['vertexes'];
                for (var i = 0; i < vertexes.length; i += 2) {
                  double latitude = vertexes[i + 1];
                  double longitude = vertexes[i];
                  polylinePoints.add(MapPoint(latitude: latitude, longitude: longitude));
                }
              }
            }
            WalkPage.setPolylinePoints(polylinePoints);
          }
        } on PlatformException catch (e) {
          print('Failed to get route: ${e.message}');
        }
      } else {
        print('Failed to find coordinates for the given places.');
      }
    }
  }

  void _onStartPlaceTap(Map<String, dynamic> place) {
    _startController.text = place['place_name'];
    setState(() {
      _startSearchResults.clear();
    });
  }

  void _onEndPlaceTap(Map<String, dynamic> place) {
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
          // 출발 시간 선택 및 경로 정보
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                MapPage(),
                BusPage(
                  startController: _startController,
                  endController: _endController,
                  startFocusNode: _startFocusNode,
                  endFocusNode: _endFocusNode,
                  startSearchResults: _startSearchResults,
                  endSearchResults: _endSearchResults,
                  searchStartLocation: _searchStartLocation,
                  searchEndLocation: _searchEndLocation,
                  onStartPlaceTap: _onStartPlaceTap,
                  onEndPlaceTap: _onEndPlaceTap,
                  refreshData: _refreshData,
                ),
                MapPage(),
                MapPage(),
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
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Platform.isAndroid
            ? PlatformViewLink(
          viewType: 'KakaoMapView',
          surfaceFactory: (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'KakaoMapView',
              layoutDirection: TextDirection.ltr,
              creationParams: {},
              creationParamsCodec: const StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        )
            : Center(child: Text('KakaoMap is not supported on this platform')),
      ],
    );
  }
}

class BusPage extends StatelessWidget {
  final TextEditingController startController;
  final TextEditingController endController;
  final FocusNode startFocusNode;
  final FocusNode endFocusNode;
  final List<dynamic> startSearchResults;
  final List<dynamic> endSearchResults;
  final Function(String) searchStartLocation;
  final Function(String) searchEndLocation;
  final Function(Map<String, dynamic>) onStartPlaceTap;
  final Function(Map<String, dynamic>) onEndPlaceTap;
  final Future<void> Function() refreshData;

  BusPage({
    required this.startController,
    required this.endController,
    required this.startFocusNode,
    required this.endFocusNode,
    required this.startSearchResults,
    required this.endSearchResults,
    required this.searchStartLocation,
    required this.searchEndLocation,
    required this.onStartPlaceTap,
    required this.onEndPlaceTap,
    required this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
      color: Colors.white,
      backgroundColor: Color(0xFF4285F4),
      child: Padding(
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
      ),
    );
  }
}

class WalkPage extends StatefulWidget {
  static List<MapPoint> _polylinePoints = [];

  static void setPolylinePoints(List<MapPoint> points) {
    _polylinePoints = points;
  }

  @override
  _WalkPageState createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Platform.isAndroid
            ? PlatformViewLink(
          viewType: 'KakaoMapView',
          surfaceFactory: (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'KakaoMapView',
              layoutDirection: TextDirection.ltr,
              creationParams: {
                'polyline': WalkPage._polylinePoints.map((point) => [point.latitude, point.longitude]).toList(),
              },
              creationParamsCodec: const StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        )
            : Center(child: Text('KakaoMap is not supported on this platform')),
      ],
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

void main() {
  runApp(MaterialApp(
    home: TrafficFragment(),
  ));
}
