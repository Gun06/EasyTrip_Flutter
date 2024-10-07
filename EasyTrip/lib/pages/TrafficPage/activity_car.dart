import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'fragment_traffic.dart'; // Import the shared MapPoint class

class CarPage extends StatefulWidget {
  final Future<void> Function() refreshData;
  final MapPoint? startPoint;
  final MapPoint? endPoint;
  final List<MapPoint> waypoints; // 경유지를 받는 파라미터 추가

  CarPage({
    required this.refreshData,
    required this.startPoint,
    required this.endPoint,
    this.waypoints = const [], // 기본값으로 빈 리스트를 설정
  });

  @override
  _CarPageState createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  @override
  void dispose() {
    MethodChannel('com.example.easytrip/map').invokeMethod('removeMapView');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.startPoint != null && widget.endPoint != null) {
      _drawRoute(widget.startPoint!, widget.endPoint!, widget.waypoints);
    }
  }

  Future<void> _drawRoute(MapPoint start, MapPoint end, List<MapPoint> waypoints) async {
    final String apiKey = "06458f1a2d01e02bb731d2a37cfa6c85";

    // 경유지 문자열 생성
    String waypointsString = waypoints.isNotEmpty
        ? waypoints.map((point) => "${point.longitude},${point.latitude}").join("|")
        : "";

    // URL 구성 (경유지가 있으면 포함)
    final String url = waypointsString.isNotEmpty
        ? "https://apis-navi.kakaomobility.com/v1/waypoints/directions?origin=${start.longitude},${start.latitude}&waypoints=$waypointsString&destination=${end.longitude},${end.latitude}&priority=RECOMMENDED&road_details=false"
        : "https://apis-navi.kakaomobility.com/v1/directions?origin=${start.longitude},${start.latitude}&destination=${end.longitude},${end.latitude}&priority=RECOMMENDED&road_details=false";

    final response = await HttpClient().getUrl(Uri.parse(url))
        .then((request) {
      request.headers.set("Authorization", "KakaoAK $apiKey");
      return request.close();
    });

    final String responseBody = await response.transform(utf8.decoder).join();
    final jsonResponse = jsonDecode(responseBody);

    List<MapPoint> routePoints = [];

    for (var section in jsonResponse['routes'][0]['sections']) {
      for (var road in section['roads']) {
        for (int i = 0; i < road['vertexes'].length; i += 2) {
          // vertexes 배열에서 경로 좌표 추출
          double lng = road['vertexes'][i];
          double lat = road['vertexes'][i + 1];
          routePoints.add(MapPoint(latitude: lat, longitude: lng));
        }
      }
    }

    if (routePoints.isNotEmpty) {
      await MethodChannel('com.example.easytrip/map').invokeMethod('drawRouteLine', {
        'points': routePoints.map((point) => {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.refreshData,
      child: Container(
        child: PlatformViewLink(
          viewType: 'KakaoMapView',
          surfaceFactory: (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            MethodChannel('com.example.easytrip/map').invokeMethod('removeMapView'); // Remove existing map view

            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'KakaoMapView',
              layoutDirection: TextDirection.ltr,
              creationParams: {
                'startLatitude': widget.startPoint?.latitude,
                'startLongitude': widget.startPoint?.longitude,
                'endLatitude': widget.endPoint?.latitude,
                'endLongitude': widget.endPoint?.longitude,
                // waypoints 추가
                'waypoints': widget.waypoints.map((point) => {
                  'latitude': point.latitude,
                  'longitude': point.longitude,
                }).toList(),
              },
              creationParamsCodec: const StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        ),
      ),
    );
  }
}
