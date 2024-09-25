import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'fragment_traffic.dart';

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
      _getWalkingRoute(widget.startPoint!, widget.endPoint!);
    }
  }

  // getWalkingRoute를 호출하는 함수
  Future<void> _getWalkingRoute(MapPoint start, MapPoint end) async {
    try {
      await MethodChannel('com.example.easytrip/map').invokeMethod('getWalkingRoute', {
        'startLatitude': start.latitude,
        'startLongitude': start.longitude,
        'endLatitude': end.latitude,
        'endLongitude': end.longitude,
      });
      setState(() {});
    } catch (e) {
      print("Failed to fetch walking route: $e");
    }
  }

  // 로드뷰 라인 오버레이 호출
  Future<void> _setRoadViewLineOverlay() async {
    try {
      await MethodChannel('com.example.easytrip/map').invokeMethod('setRoadViewLineOverlay');
    } catch (e) {
      print("Failed to set road view line overlay: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.refreshData,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height, // 화면 높이를 기준으로 제한
            child: Column(
              children: [
                Expanded(
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
                      MethodChannel('com.example.easytrip/map').invokeMethod('removeMapView');

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
              ],
            ),
          ),
          Positioned(
            top: 20, // 상단에서 20픽셀 떨어지도록 설정
            right: 20, // 오른쪽에서 20픽셀 떨어지도록 설정
            child: ElevatedButton(
              onPressed: _setRoadViewLineOverlay,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.white, // 글씨 색 파란색
              ),
              child: Text('로드뷰 라인 표시'),
            ),
          ),
        ],
      ),
    );
  }
}
