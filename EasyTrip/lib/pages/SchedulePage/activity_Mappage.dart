import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  final List<Map<String, String>> routeDetails;

  MapPage({required this.routeDetails});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const MethodChannel mapChannel = MethodChannel('com.example.easytrip/map');
  final String kakaoLocalApiKey = '0a3f9a07d485e8599a680ad551136301';
  final String kakaoMobilityApiKey = '06458f1a2d01e02bb731d2a37cfa6c85';

  List<MapPoint> routePoints = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    mapChannel.invokeMethod('removeMapView');
    super.dispose();
  }

  Future<void> _initializeMap() async {
    print("Initializing map...");
    await mapChannel.invokeMethod('initializeMap'); // 지도 초기화
    print("Map initialized.");
  }

  Future<void> _processRouteDetails() async {
    if (_isProcessing) {
      print("Processing is already in progress.");
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    print("Processing route details...");
    List<MapPoint> waypoints = [];
    MapPoint? start;
    MapPoint? end;

    // 입력된 경로 정보가 있는지 확인
    if (widget.routeDetails.length > 2) {
      // 중간 항목에서 첫 번째를 출발지로, 마지막을 도착지로 설정
      final firstWaypointName = widget.routeDetails[1]['placeName'] ?? 'Unknown First Waypoint';
      start = await _getCoordinates(firstWaypointName);
      if (start != null) {
        print("Start point set: Latitude = ${start.latitude}, Longitude = ${start.longitude}");
      }

      final lastWaypointName = widget.routeDetails[widget.routeDetails.length - 2]['placeName'] ?? 'Unknown Last Waypoint';
      end = await _getCoordinates(lastWaypointName);
      if (end != null) {
        print("End point set: Latitude = ${end.latitude}, Longitude = ${end.longitude}");
      }

      // 나머지 중간 경유지 처리
      for (int i = 2; i < widget.routeDetails.length - 2; i++) {
        final placeName = widget.routeDetails[i]['placeName'] ?? 'Unknown Place';

        print("Processing waypoint name #${i}: $placeName");

        final MapPoint? point = await _getCoordinates(placeName);

        if (point != null) {
          print("Converted to coordinates: Latitude = ${point.latitude}, Longitude = ${point.longitude}");
          waypoints.add(point);
        } else {
          print("Failed to convert waypoint name to coordinates: $placeName");
        }
      }
    }

    // 출발지와 도착지가 있어야만 경로 처리 진행
    if (start != null && end != null) {
      try {
        // 경로 요청
        await mapChannel.invokeMethod('getCarRoute', {
          'startLatitude': start.latitude,
          'startLongitude': start.longitude,
          'endLatitude': end.latitude,
          'endLongitude': end.longitude,
          'waypoints': waypoints.map((point) => {
            'latitude': point.latitude,
            'longitude': point.longitude,
          }).toList(),
        });

        // 출발지 라벨 추가
        await mapChannel.invokeMethod('addLabel', {
          'latitude': start.latitude,
          'longitude': start.longitude,
          'isStartPoint': true,
        });

        // 도착지 라벨 추가
        await mapChannel.invokeMethod('addLabel', {
          'latitude': end.latitude,
          'longitude': end.longitude,
          'isStartPoint': false,
        });

        // 경유지 라벨 추가
        for (var waypoint in waypoints) {
          await mapChannel.invokeMethod('addLabel', {
            'latitude': waypoint.latitude,
            'longitude': waypoint.longitude,
            'isWaypoint': true,
          });
        }
      } catch (e) {
        print("Error during route processing: $e");
      }
    } else {
      print("Start or End point is missing.");
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<MapPoint?> _getCoordinates(String placeName) async {
    final url = Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=$placeName');
    print("Requesting coordinates for place name: $placeName");

    final response = await http.get(url, headers: {'Authorization': 'KakaoAK $kakaoLocalApiKey'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['documents'].isNotEmpty) {
        final latitude = double.parse(data['documents'][0]['y']);
        final longitude = double.parse(data['documents'][0]['x']);
        print("Coordinates found: Latitude = $latitude, Longitude = $longitude");
        return MapPoint(latitude: latitude, longitude: longitude);
      } else {
        print("Place name not found in Kakao Map API: $placeName");
      }
    } else {
      print("Failed to retrieve coordinates for $placeName: ${response.statusCode}");
    }
    return null;
  }

  Future<void> _addLabelToMap(MapPoint point, {bool isStart = false, bool isEnd = false}) async {
    print("Adding label: Latitude = ${point.latitude}, Longitude = ${point.longitude}, "
        "Type = ${isStart ? 'Start' : (isEnd ? 'End' : 'Waypoint')}");

    await mapChannel.invokeMethod('addLabel', {
      'latitude': point.latitude,
      'longitude': point.longitude,
      'isStartPoint': isStart, // 출발지 여부
      'isWaypoint': !(isStart || isEnd), // 경유지 여부
    });
  }

  Future<void> _drawRoute(MapPoint start, MapPoint end, List<MapPoint> waypoints) async {
    String waypointsString = waypoints.isNotEmpty
        ? waypoints.map((point) => "${point.longitude},${point.latitude}").join("|")
        : "";

    print("Drawing route: Start = (${start.latitude}, ${start.longitude}), "
        "End = (${end.latitude}, ${end.longitude}), "
        "Waypoints = $waypointsString");

    final String url = waypointsString.isNotEmpty
        ? "https://apis-navi.kakaomobility.com/v1/waypoints/directions?origin=${start.longitude},${start.latitude}&waypoints=$waypointsString&destination=${end.longitude},${end.latitude}&priority=RECOMMENDED&road_details=false"
        : "https://apis-navi.kakaomobility.com/v1/directions?origin=${start.longitude},${start.latitude}&destination=${end.longitude},${end.latitude}&priority=RECOMMENDED&road_details=false";

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'KakaoAK $kakaoMobilityApiKey',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<MapPoint> routePoints = [];

      for (var section in jsonResponse['routes'][0]['sections']) {
        for (var road in section['roads']) {
          for (int i = 0; i < road['vertexes'].length; i += 2) {
            double lng = road['vertexes'][i];
            double lat = road['vertexes'][i + 1];
            routePoints.add(MapPoint(latitude: lat, longitude: lng));
          }
        }
      }

      if (routePoints.isNotEmpty) {
        print("Route points count: ${routePoints.length}");
        await mapChannel.invokeMethod('drawRouteLine', {
          'points': routePoints.map((point) => {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
        });
      }
    } else {
      print("Failed to retrieve route: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeDetails.isNotEmpty
            ? widget.routeDetails.first['placeName'] ?? '경로 지도'
            : '경로 지도'),
        centerTitle: true,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          PlatformViewLink(
            viewType: 'KakaoMapView',
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (params) {
              mapChannel.invokeMethod('removeMapView');
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
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _processRouteDetails,
              child: Icon(Icons.map),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class MapPoint {
  final double latitude;
  final double longitude;

  MapPoint({required this.latitude, required this.longitude});
}
