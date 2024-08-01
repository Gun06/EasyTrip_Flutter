import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<CartItem> _cartItems = [];
  List<CartItem> _removedCartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartItemsJson = prefs.getString('cart_items');
    final String? removedCartItemsJson = prefs.getString('removed_cart_items');
    if (cartItemsJson != null) {
      final List<dynamic> cartItemsList = json.decode(cartItemsJson);
      setState(() {
        _cartItems = cartItemsList.map((item) => CartItem.fromJson(item)).toList();
        _cartItems.sort((a, b) => a.date.compareTo(b.date));
      });
    } else {
      setState(() {
        _cartItems = _defaultCartItems();
        _cartItems.sort((a, b) => a.date.compareTo(b.date));
      });
    }
    if (removedCartItemsJson != null) {
      final List<dynamic> removedCartItemsList = json.decode(removedCartItemsJson);
      _removedCartItems = removedCartItemsList.map((item) => CartItem.fromJson(item)).toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String cartItemsJson = json.encode(_cartItems.map((item) => item.toJson()).toList());
    final String removedCartItemsJson = json.encode(_removedCartItems.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items', cartItemsJson);
    await prefs.setString('removed_cart_items', removedCartItemsJson);
  }

  List<CartItem> _defaultCartItems() {
    return [
      CartItem(
        date: '2023-06-25',
        title: '북한산',
        location: 'Panjer, South Denpasar',
        price: '₩ 5,000',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      CartItem(
        date: '2023-06-28',
        title: '밤 도깨비 야시장',
        location: 'Sanur, South Denpasar',
        price: '₩ 6,000 ~',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      CartItem(
        date: '2023-06-29',
        title: '낙산 공원',
        location: 'Sanur, South Denpasar',
        price: '₩ 0',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      CartItem(
        date: '2023-06-30',
        title: '해운대 해변',
        location: 'Sanur, South Denpasar',
        price: '₩ 25,000 ~',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      CartItem(
        date: '2023-06-28',
        title: '오이도 뒤 등대',
        location: 'Sanur, South Denpasar',
        price: '₩ 60,000 ~',
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }

  void _sortCartItems() {
    setState(() {
      _cartItems.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _removeCartItem(int index) {
    final removedItem = _cartItems.removeAt(index);
    _removedCartItems.add(removedItem);
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildCartItem(context, removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );
    _sortCartItems();
    _saveCartItems();
  }

  void _restoreCartItem() {
    if (_removedCartItems.isNotEmpty) {
      final restoredItem = _removedCartItems.removeLast();
      _cartItems.add(restoredItem);
      _sortCartItems();
      _listKey.currentState?.insertItem(_cartItems.indexOf(restoredItem), duration: const Duration(milliseconds: 300));
      _saveCartItems();
    }
  }

  void _addCartItem(CartItem newItem) {
    _cartItems.add(newItem);
    _sortCartItems();
    _listKey.currentState?.insertItem(_cartItems.indexOf(newItem), duration: const Duration(milliseconds: 300));
    _saveCartItems();
  }

  void showAddItemDialog(BuildContext context) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('새 항목 추가'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final newItem = CartItem(
                  date: dateController.text,
                  title: titleController.text,
                  location: locationController.text,
                  price: priceController.text,
                  imageUrl: imageUrlController.text,
                );
                _addCartItem(newItem);
                Navigator.of(context).pop();
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경색 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // 제목 가운데 정렬
        title: Text(
          '장바구니',
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
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              showAddItemDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
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
            ElevatedButton(
              onPressed: _restoreCartItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9), // 배경색과 투명도 설정
              ),
              child: Text('Restore Last Removed Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartItem item, Animation<double> animation, [int? index]) {
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
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.place, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        item.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.price,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Spacer(),
              if (index != null) // Only show delete button if index is provided
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _removeCartItem(index);
                  },
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
      date: json['date'],
      title: json['title'],
      location: json['location'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'title': title,
      'location': location,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

void main() {
  runApp(MaterialApp(
    home: ShoppingCartPage(),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', 'US'), // English
      const Locale('ko', 'KR'), // Korean
      // 다른 지원 언어 추가
    ],
  ));
}
