import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'fragment_traffic.dart'; // Import the shared MapPoint class

class CarPage extends StatelessWidget {
  final Future<void> Function() refreshData;
  final MapPoint? startPoint;
  final MapPoint? endPoint;

  CarPage({required this.refreshData, required this.startPoint, required this.endPoint});

  void _navigateToHome(BuildContext context) {
    Navigator.pop(context);
    MethodChannel('com.example.easytrip/map').invokeMethod('removeMapView');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
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
                'startLatitude': startPoint?.latitude,
                'startLongitude': startPoint?.longitude,
                'endLatitude': endPoint?.latitude,
                'endLongitude': endPoint?.longitude,
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

  void dispose() {
    MethodChannel('com.example.easytrip/map').invokeMethod('removeMapView');
  }
}
