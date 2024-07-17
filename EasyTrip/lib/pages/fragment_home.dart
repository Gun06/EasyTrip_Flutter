import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeFragment(),
    );
  }
}

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  static const platform = MethodChannel('com.example.easytrip/search');
  static const mapChannel = MethodChannel('com.example.easytrip/map');
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      // 위치 권한이 승인됨
    } else {
      // 위치 권한이 거부됨
      openAppSettings();
    }
  }

  void _search() async {
    try {
      final String result = await platform.invokeMethod('search', _searchController.text);
      final data = jsonDecode(result);
      setState(() {
        _searchResults = data['documents'];
      });
    } on PlatformException catch (e) {
      print('Failed to search: ${e.message}');
    }
  }

  void _moveToLocation(double latitude, double longitude) async {
    try {
      await mapChannel.invokeMethod('moveToLocation', {'latitude': latitude, 'longitude': longitude});
    } on PlatformException catch (e) {
      print('Failed to move to location: ${e.message}');
    }
  }

  void _addMarker(double latitude, double longitude) async {
    try {
      await mapChannel.invokeMethod('addMarker', {'latitude': latitude, 'longitude': longitude});
    } on PlatformException catch (e) {
      print('Failed to add marker: ${e.message}');
    }
  }

  void _zoomIn() async {
    try {
      await mapChannel.invokeMethod('zoomIn');
    } on PlatformException catch (e) {
      print('Failed to zoom in: ${e.message}');
    }
  }

  void _zoomOut() async {
    try {
      await mapChannel.invokeMethod('zoomOut');
    } on PlatformException catch (e) {
      print('Failed to zoom out: ${e.message}');
    }
  }

  void _moveToCurrentLocation() async {
    try {
      await mapChannel.invokeMethod('moveToCurrentLocation');
    } on PlatformException catch (e) {
      print('Failed to move to current location: ${e.message}');
    }
  }

  void _onPlaceTap(double latitude, double longitude) {
    _moveToLocation(latitude, longitude);
    _addMarker(latitude, longitude);
    setState(() {
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Platform.isAndroid
              ? PlatformViewLink(
            viewType: 'KakaoMapView',
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <
                    Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: 'KakaoMapView',
                layoutDirection: TextDirection.ltr,
                creationParams: {},
                creationParamsCodec: const StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener(
                    params.onPlatformViewCreated)
                ..create();
            },
          )
              : Center(child: Text('KakaoMap is not supported on this platform')),
          Positioned(
            top: 50,
            left: 10,
            right: 70,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      // 목록 버튼 기능 추가
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '검색어를 입력하세요',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => _search(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _search,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                // 길찾기 버튼 기능 추가
              },
              child: Icon(Icons.directions, color: Colors.white),
              backgroundColor: Colors.blue,
              mini: true,
              heroTag: 'directionsHero',
            ),
          ),
          Positioned(
            top: 110,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('맛집랭킹', Icons.star, Colors.red),
                  _buildCategoryButton('음식점', Icons.restaurant, Colors.orange),
                  _buildCategoryButton('카페', Icons.local_cafe, Colors.brown),
                  _buildCategoryButton('편의점', Icons.local_convenience_store, Colors.green),
                  _buildCategoryButton('셀프사진관', Icons.camera_alt, Colors.purple),
                ],
              ),
            ),
          ),
          Positioned(
            top: 170,
            right: 10,
            child: Column(
              children: [
                _buildShadowButton(
                  FloatingActionButton(
                    onPressed: _zoomIn,
                    child: Icon(Icons.zoom_in, color: Colors.black),
                    backgroundColor: Colors.white,
                    mini: true,
                    heroTag: 'zoomInHero',
                  ),
                ),
                SizedBox(height: 8),
                _buildShadowButton(
                  FloatingActionButton(
                    onPressed: _zoomOut,
                    child: Icon(Icons.zoom_out, color: Colors.black),
                    backgroundColor: Colors.white,
                    mini: true,
                    heroTag: 'zoomOutHero',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: FloatingActionButton(
              onPressed: _moveToCurrentLocation,
              child: Icon(Icons.my_location, color: Colors.blue),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
              heroTag: 'locationHero',
            ),
          ),
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 110,
              left: 10,
              right: 10,
              child: Container(
                height: 240,
                color: Colors.black12,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: (_searchResults.length / 3).ceil(),
                  itemBuilder: (context, pageIndex) {
                    int startIndex = pageIndex * 3;
                    int endIndex = (startIndex + 3 < _searchResults.length) ? startIndex + 3 : _searchResults.length;
                    return Column(
                      children: List.generate(endIndex - startIndex, (index) {
                        final place = _searchResults[startIndex + index];
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          elevation: 4.0,
                          shadowColor: Colors.black26,
                          child: ListTile(
                            title: Text(place['place_name']),
                            subtitle: Text(place['address_name']),
                            onTap: () {
                              double lat = double.parse(place['y']);
                              double lon = double.parse(place['x']);
                              _onPlaceTap(lat, lon);
                            },
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Add the functionality for the category buttons here
        },
        icon: Icon(icon, color: iconColor, size: 24),
        label: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          elevation: 8,
          shadowColor: Colors.black45,
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          minimumSize: Size(100, 40),
        ),
      ),
    );
  }

  Widget _buildShadowButton(Widget button) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 60.0,
            spreadRadius: 2.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: button,
    );
  }
}