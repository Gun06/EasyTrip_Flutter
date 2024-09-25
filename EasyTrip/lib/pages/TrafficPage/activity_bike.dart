import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class BikePage extends StatefulWidget {
  @override
  _BikePageState createState() => _BikePageState();
}

class _BikePageState extends State<BikePage> {
  @override
  void initState() {
    super.initState();
    _setBikeOverlay();
  }

  // 자전거 도로 오버레이 호출
  Future<void> _setBikeOverlay() async {
    try {
      await MethodChannel('com.example.easytrip/map').invokeMethod('setBicycleOverlay');
    } catch (e) {
      print("Failed to set bike overlay: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                        creationParams: {}, // 자전거 도로의 경우 별도의 좌표 파라미터 없음
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
              onPressed: _setBikeOverlay,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.white, // 글씨 색 파란색
              ),
              child: Text('자전거 도로 표시'),
            ),
          ),
        ],
      ),
    );
  }
}
