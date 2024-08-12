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

  CarPage({required this.refreshData, required this.startPoint, required this.endPoint});

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
      _drawRoute(widget.startPoint!, widget.endPoint!);
    }
  }

  Future<void> _drawRoute(MapPoint start, MapPoint end) async {
    final String apiKey = "YOUR_KAKAO_REST_API_KEY";
    final String url = "https://apis-navi.kakaomobility.com/v1/directions?origin=${start.longitude},${start.latitude}&destination=${end.longitude},${end.latitude}&waypoints=&priority=RECOMMENDED&road_details=false";

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
        for (var vertex in road['vertexes']) {
          routePoints.add(MapPoint(
            latitude: vertex['location']['y'],
            longitude: vertex['location']['x'],
          ));
        }
      }
    }

    if (routePoints.isNotEmpty) {
      await MethodChannel('com.example.easytrip/map').invokeMethod('drawPolyline', {
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
