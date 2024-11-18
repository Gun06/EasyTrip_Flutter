import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewFragment extends StatefulWidget {
  final String accessToken;

  ReviewFragment({required this.accessToken});

  @override
  _ReviewFragmentState createState() => _ReviewFragmentState();
}

class _ReviewFragmentState extends State<ReviewFragment> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  List<int> _scheduleIds = []; // Schedule ID 목록
  List<Map<String, dynamic>> _scheduleDetails = []; // Schedule 세부 정보
  List<List<Map<String, dynamic>>> _recommendations = []; // 추천 장소 정보
  List<bool> _isExpanded = []; // 각 카드를 펼침/접힘 상태로 관리
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadReviewItems(); // `/api/sns/posts` 호출
  }

  void _scrollListener() {
    if (_scrollController.offset >= 50) {
      setState(() {
        _showScrollToTopButton = true;
      });
    } else {
      setState(() {
        _showScrollToTopButton = false;
      });
    }
  }

  /// `/api/sns/posts`에서 리뷰 목록 불러오기
  Future<void> _loadReviewItems() async {
    final url = Uri.parse('http://44.214.72.11:8080/api/sns/posts');
    print('Requesting reviews from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> reviewList = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          _scheduleIds = reviewList.map<int>((item) => item['scheduleId'] ?? 0).toList();
          _isExpanded = List.generate(_scheduleIds.length, (_) => false); // 초기 접힘 상태 설정
          _isLoading = false;
        });

        print('Loaded Schedule IDs: $_scheduleIds');

        // Schedule ID를 사용해 세부 정보 가져오기
        await _loadScheduleDetails();
      } else {
        print('Failed to load reviews. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// `/api/schedules/{scheduleId}`에서 스케줄 세부 정보와 추천 장소 가져오기
  Future<void> _loadScheduleDetails() async {
    for (int scheduleId in _scheduleIds) {
      final url = Uri.parse('http://44.214.72.11:8080/api/schedules/$scheduleId');
      print('Requesting schedule details for ID $scheduleId from: $url');

      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.accessToken}',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> detail = json.decode(utf8.decode(response.bodyBytes));

          setState(() {
            _scheduleDetails.add({
              'title': detail['title'] ?? '알 수 없는 장소',
              'date': detail['date'] ?? '알 수 없는 날짜',
              'price': detail['price']?.toString() ?? '0',
              'image': detail['image'] ?? 'https://via.placeholder.com/150',
            });

            _recommendations.add((detail['pathDetails'] as List<dynamic>)
                .map((rec) => {
              'placeName': rec['placeName'] ?? 'Unknown Place',
              'location': rec['address'] ?? 'Unknown Address',
              'price': rec['price']?.toString() ?? '0',
            })
                .toList());
          });

          print('Loaded Schedule Details for ID $scheduleId: ${_scheduleDetails.last}');
          print('Loaded Recommendations for ID $scheduleId: ${_recommendations.last}');
        } else {
          print('Failed to load schedule details for ID $scheduleId. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error loading schedule details for ID $scheduleId: $e');
      }
    }
  }

  void _toggleExpanded(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Find your Happiness with Us!',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _scheduleDetails.isEmpty
          ? Center(child: Text('No schedule details available.'))
          : ListView.builder(
        controller: _scrollController,
        itemCount: _scheduleDetails.length,
        itemBuilder: (context, index) {
          return _buildScheduleItem(context, _scheduleDetails[index], _recommendations[index], index);
        },
      ),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(Icons.arrow_upward, color: Colors.black),
      )
          : null,
    );
  }

  Widget _buildScheduleItem(
      BuildContext context,
      Map<String, dynamic> detail,
      List<Map<String, dynamic>> recommendations,
      int index,
      ) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 카드 좌우 여백 추가
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
                    imageUrl: detail['image']!,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/150.png',
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
                      Text(
                        detail['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        detail['date']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${detail['price']}원',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded[index] ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  onPressed: () => _toggleExpanded(index),
                ),
              ],
            ),
            if (_isExpanded[index])
              Column(
                children: recommendations.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              rec['placeName']!,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              rec['location']!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              '${rec['price']}원',
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
