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
    List<MapPoint> waypoints = [];
    MapPoint? start;
    MapPoint? end;

    for (int i = 0; i < widget.routeDetails.length; i++) {
      final address = widget.routeDetails[i]['address'] ?? '';
      final MapPoint? point = await _getCoordinates(address);

      if (point != null) {
        if (i == 0) {
          start = point;
        } else if (i == widget.routeDetails.length - 1) {
          end = point;
        } else {
          waypoints.add(point);
        }
        await _addLabelToMap(point, isStart: i == 0, isEnd: i == widget.routeDetails.length - 1);
      }
    }

    if (start != null && end != null) {
      await _drawRouteWithWaypoints(start, end, waypoints);
    }
  }

  Future<MapPoint?> _getCoordinates(String address) async {
    final url = Uri.parse('https://dapi.kakao.com/v2/local/search/address.json?query=$address');
    print("Requesting coordinates for address: $address");

    final response = await http.get(url, headers: {'Authorization': 'KakaoAK $kakaoLocalApiKey'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['documents'].isNotEmpty) {
        final latitude = double.parse(data['documents'][0]['y']);
        final longitude = double.parse(data['documents'][0]['x']);
        print("Coordinates found: Latitude = $latitude, Longitude = $longitude");

        return MapPoint(latitude: latitude, longitude: longitude);
      } else {
        print("Address not found in Kakao Map API.");
      }
    } else {
      print("Failed to retrieve coordinates: ${response.statusCode}");
      print("Error response body: ${response.body}");
    }
    return null;
  }

  Future<void> _addLabelToMap(MapPoint point, {bool isStart = false, bool isEnd = false}) async {
    await mapChannel.invokeMethod('addLabel', {
      'latitude': point.latitude,
      'longitude': point.longitude,
      'isStartPoint': isStart,
      'isWaypoint': !(isStart || isEnd),
    });
  }

  Future<void> _drawRouteWithWaypoints(MapPoint start, MapPoint end, List<MapPoint> waypoints) async {
    await mapChannel.invokeMethod('drawRouteWithWaypoints', {
      'startLatitude': start.latitude,
      'startLongitude': start.longitude,
      'endLatitude': end.latitude,
      'endLongitude': end.longitude,
      'waypoints': waypoints
          .map((waypoint) => {'latitude': waypoint.latitude, 'longitude': waypoint.longitude})
          .toList(),
    });
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
      body: PlatformViewLink(
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
    );
  }
}

class MapPoint {
  final double latitude;
  final double longitude;

  MapPoint({required this.latitude, required this.longitude});
}
