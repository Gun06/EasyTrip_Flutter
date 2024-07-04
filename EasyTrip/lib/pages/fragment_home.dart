import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  static const platform = MethodChannel('com.example.easytrip/search');
  final TextEditingController _searchController = TextEditingController();

  void _search() async {
    try {
      final String result = await platform.invokeMethod('search', _searchController.text);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Search Results'),
            content: Text(result),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } on PlatformException catch (e) {
      print('Failed to search: ${e.message}');
    }
  }

  void _zoomIn() async {
    try {
      await platform.invokeMethod('zoomIn');
    } on PlatformException catch (e) {
      print('Failed to zoom in: ${e.message}');
    }
  }

  void _zoomOut() async {
    try {
      await platform.invokeMethod('zoomOut');
    } on PlatformException catch (e) {
      print('Failed to zoom out: ${e.message}');
    }
  }

  void _moveToCurrentLocation() async {
    try {
      await platform.invokeMethod('moveToCurrentLocation');
    } on PlatformException catch (e) {
      print('Failed to move to current location: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Platform.isAndroid
              ? AndroidView(
            viewType: 'KakaoMapView',
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{},
            creationParamsCodec: const StandardMessageCodec(),
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
            child: Container(
              width: 48,
              height: 48,
              child: FloatingActionButton(
                onPressed: () {
                  // 길찾기 버튼 기능 추가
                },
                child: Icon(Icons.directions, color: Colors.white),
                backgroundColor: Colors.blue,
                mini: true,
              ),
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
                  ),
                ),
                SizedBox(height: 8),
                _buildShadowButton(
                  FloatingActionButton(
                    onPressed: _zoomOut,
                    child: Icon(Icons.zoom_out, color: Colors.black),
                    backgroundColor: Colors.white,
                    mini: true,
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