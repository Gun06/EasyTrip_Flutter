import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'fragment_traffic.dart';

class CarPage extends StatefulWidget {
  final List<MapPoint> routePoints;
  final Future<void> Function() refreshData;

  CarPage({required this.routePoints, required this.refreshData});

  @override
  _CarPageState createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.refreshData,
      child: Stack(
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
                  'polyline': widget.routePoints.map((point) => [point.latitude, point.longitude]).toList(),
                },
                creationParamsCodec: const StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            },
          )
              : Center(child: Text('KakaoMap is not supported on this platform')),
          Center(
            child: Text('자동차 페이지', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
