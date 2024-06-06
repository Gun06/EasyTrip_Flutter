import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';

class HomeFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Fragment'),
      ),
      body: Center(
        child: Platform.isAndroid
            ? AndroidView(
          viewType: 'KakaoMapView',
          layoutDirection: TextDirection.ltr,
          creationParams: <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
        )
            : Text('KakaoMap is not supported on this platform'),
      ),
    );
  }
}
