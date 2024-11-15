import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AllSchedulePage extends StatefulWidget {
  final String accessToken;

  AllSchedulePage({required this.accessToken});

  @override
  _AllSchedulePageState createState() => _AllSchedulePageState();
}

class _AllSchedulePageState extends State<AllSchedulePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<CartItem> _cartItems = [];
  List<List<Map<String, dynamic>>> recommendations = [];
  List<bool> _isExpanded = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItemsFromServer();
  }

  Future<void> _loadCartItemsFromServer() async {
    final url = Uri.parse('http://44.214.72.11:8080/api/schedules/all/1');
    print('Requesting cart items from: $url');
    print('Using accessToken: ${widget.accessToken}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> cartItemsList =
        json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _cartItems = cartItemsList
              .map((item) => CartItem.fromJson(item))
              .toList();

          recommendations = cartItemsList
              .map((item) => (item['pathDetails'] as List<dynamic>)
              .map((rec) => {
            'placeName': rec['placeName'] ?? 'Unknown Place',
            'location': rec['address'] ?? 'Unknown Address',
            'price': rec['price']?.toString() ?? '0',
          })
              .toList())
              .toList();

          _isExpanded = List.generate(_cartItems.length, (_) => false);
          _cartItems.sort((a, b) => a.date.compareTo(b.date));
          _isLoading = false;
        });
        print('Loaded cart items: $_cartItems');
        print('Loaded recommendations: $recommendations');
      } else {
        print(
            'Failed to load cart items. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading cart items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleExpanded(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  void _removeCartItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
      recommendations.removeAt(index);
      _isExpanded.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '내 일정 리스트',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
          ? Center(child: Text('일정이 없습니다.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _cartItems.length,
          itemBuilder: (context, index, animation) {
            return _buildCartItem(
              context,
              _cartItems[index],
              animation,
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartItem item, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/150.png', // 기본 이미지 파일
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              item.date,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        Text(
                          item.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${item.price}원',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded[index]
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.grey,
                    ),
                    onPressed: () => _toggleExpanded(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCartItem(index),
                  ),
                ],
              ),
              if (_isExpanded[index])
                Column(
                  children: recommendations[index]
                      .map(
                        (rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['placeName']!,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Text(
                              rec['location']!,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${rec['price']}원',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItem {
  final String date;
  final String title;
  final String location;
  final String price;
  final String imageUrl;

  CartItem({
    required this.date,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      date: json['date'] ?? 'N/A',
      title: json['title'] ?? 'No Title',
      location: json['location'] ?? '',
      price: json['price']?.toString() ?? '0',
      imageUrl: json['image'] ?? 'https://via.placeholder.com/150',
    );
  }
}
