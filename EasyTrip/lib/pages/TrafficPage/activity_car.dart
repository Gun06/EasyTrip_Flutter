import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
