import 'package:flutter/material.dart';

class ProfileImageSelector extends StatelessWidget {
  final List<String> profileImages = [
    'assets/ph_profile01.png',
    'assets/ph_profile02.png',
    'assets/ph_profile03.png',
    'assets/ph_profile04.png',
    'assets/ph_profile05.png',
    'assets/ph_profile06.png',
    'assets/ph_profile07.png',
    'assets/ph_profile08.png',
    'assets/ph_profile09.png',
    'assets/ph_profile10.png',
    'assets/ph_profile11.png',
    'assets/ph_profile12.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      height: 500.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              '앱은 사용자가 선택한 사진에만 액세스할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, 'assets/ph_profile_img_01.jpg'); // 기본 이미지로 초기화
                },
                icon: Icon(Icons.refresh),
                label: Text('이미지 초기화'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '완료',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: profileImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, profileImages[index]);
                  },
                  child: Image.asset(profileImages[index], fit: BoxFit.cover),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showProfileImageSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProfileImageSelector(),
  );
}
