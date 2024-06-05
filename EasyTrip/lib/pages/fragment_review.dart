import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

class ReviewFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      appBar: AppBar(
        title: Text(
          'Find your Happiness with Us!',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          AnimSearchBar(
            width: MediaQuery.of(context).size.width, // 화면 끝까지 열리도록 설정
            textController: TextEditingController(),
            onSuffixTap: () {},
            onSubmitted: (String value) {
              // 검색어 제출 시 동작
              print('Search: $value');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 새로고침 시 동작
          print('Page refreshed');
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPopularItem(
                      context,
                      '해운대',
                      '9 해운대, South Korea',
                      '16.5 km',
                      'https://via.placeholder.com/150',
                    ),
                    _buildPopularItem(
                      context,
                      '광안리',
                      '8 광안리, South Korea',
                      '16.5 km',
                      'https://via.placeholder.com/150',
                    ),
                    _buildPopularItem(
                      context,
                      'Jimburan',
                      '7 Jimburan, Indonesia',
                      '10.5 km',
                      'https://via.placeholder.com/150',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '추천',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              _buildRecommendedItem(
                context,
                '북한산',
                'Panjer, South Denpasar',
                '3.3 km',
                'https://via.placeholder.com/150',
              ),
              _buildRecommendedItem(
                context,
                '정동진 해변',
                'Sanur, South Denpasar',
                '10.4 km',
                'https://via.placeholder.com/150',
              ),
              _buildRecommendedItem(
                context,
                '정동진 해변',
                'Sanur, South Denpasar',
                '10.4 km',
                'https://via.placeholder.com/150',
              ),
              _buildRecommendedItem(
                context,
                '정동진 해변',
                'Sanur, South Denpasar',
                '10.4 km',
                'https://via.placeholder.com/150',
              ),
              _buildRecommendedItem(
                context,
                '정동진 해변',
                'Sanur, South Denpasar',
                '10.4 km',
                'https://via.placeholder.com/150',
              ),
              _buildRecommendedItem(
                context,
                '울왕리 해변',
                'Sanur, South Denpasar',
                '5.6 km',
                'https://via.placeholder.com/150',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularItem(BuildContext context, String title, String location, String distance, String imageUrl) {
    return Container(
      margin: EdgeInsets.only(right: 16.0),
      width: 200,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              imageUrl,
              height: 250,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    distance,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // 자세히 버튼 클릭 시 동작
                      },
                      child: Text(
                        '자세히',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItem(BuildContext context, String title, String location, String distance, String imageUrl) {
    return Card(
      color: Colors.white, // 배경을 흰색으로 설정
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
              child: Image.network(
                imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  distance,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                // 자세히 버튼 클릭 시 동작
              },
              child: Text(
                '자세히',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
