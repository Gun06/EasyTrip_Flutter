import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'fragment_traffic.dart'; // Import the shared MapPoint class

class WalkPage extends StatefulWidget {
  final Future<void> Function() refreshData;
  final MapPoint? startPoint;
  final MapPoint? endPoint;

  WalkPage({required this.refreshData, required this.startPoint, required this.endPoint});

  @override
  _WalkPageState createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {

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
    final Map<String, dynamic> params = {
      'startLatLng': {'latitude': start.latitude, 'longitude': start.longitude},
      'endLatLng': {'latitude': end.latitude, 'longitude': end.longitude},
    };

    try {
      await MethodChannel('com.example.easytrip/map').invokeMethod('drawRouteLine', params);
    } catch (e) {
      print("Failed to draw route line: $e");
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
            MethodChannel('com.example.easytrip/map').invokeMethod('removeMapView'); // 기존 지도 제거

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
