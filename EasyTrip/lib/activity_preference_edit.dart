import 'package:flutter/material.dart';
import 'helpers/database_helper.dart';
import 'models/user.dart';

class ActivityPreferenceEditPage extends StatefulWidget {
  final int userId;

  ActivityPreferenceEditPage({required this.userId});

  @override
  _ActivityPreferenceEditPageState createState() => _ActivityPreferenceEditPageState();
}

class _ActivityPreferenceEditPageState extends State<ActivityPreferenceEditPage> {
  List<String> _availableActivities = [];
  List<String> _availableFoods = [];
  List<String> _availableAccommodations = [];

  List<String> _selectedActivities = [];
  List<String> _selectedFoods = [];
  List<String> _selectedAccommodations = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final dbHelper = DatabaseHelper.instance;
    _user = await dbHelper.getUser(widget.userId);
    if (_user != null) {
      setState(() {
        _availableActivities = _user!.activityPreferences;
        _availableFoods = _user!.foodPreferences;
        _availableAccommodations = _user!.accommodationPreferences;

        _selectedActivities = List<String>.from(_user!.activityPreferences);
        _selectedFoods = List<String>.from(_user!.foodPreferences);
        _selectedAccommodations = List<String>.from(_user!.accommodationPreferences);
      });
    }
  }

  void _savePreferences() async {
    if (_user != null) {
      final dbHelper = DatabaseHelper.instance;
      final updatedUser = User(
        id: _user!.id,
        password: _user!.password,
        name: _user!.name,
        nickname: _user!.nickname,
        birthDate: _user!.birthDate,
        phoneNumber: _user!.phoneNumber,
        email: _user!.email, // 이메일 필드 추가
        profileImage: _user!.profileImage,
        isBlocked: _user!.isBlocked,
        age: _user!.age,
        gender: _user!.gender,
        activityPreferences: _selectedActivities,
        foodPreferences: _selectedFoods,
        accommodationPreferences: _selectedAccommodations,
      );
      await dbHelper.updateUser(updatedUser);
      Navigator.pop(context, updatedUser);
    }
  }

  void _onReorder(List<String> list, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
    });
  }

  Widget _buildPreferenceList(String title, List<String> options, List<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ReorderableListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) => _onReorder(selectedOptions, oldIndex, newIndex),
          children: selectedOptions.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            return Container(
              key: ValueKey(option),
              margin: EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: Text('${index + 1}'),
                ),
                title: Text(option),
                trailing: Icon(Icons.menu),
              ),
            );
          }).toList(),
        ),
        Wrap(
          spacing: 8.0,
          children: options.where((option) => !selectedOptions.contains(option)).map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: false,
              onSelected: (_) {
                setState(() {
                  selectedOptions.add(option);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            '선호도 수정',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Center(child: CircularProgressIndicator()),
        backgroundColor: Colors.white,
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          '선호도 수정',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: _savePreferences,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreferenceList(
              '활동 선호도',
              _availableActivities,
              _selectedActivities,
            ),
            SizedBox(height: 20),
            _buildPreferenceList(
              '음식 선호도',
              _availableFoods,
              _selectedFoods,
            ),
            SizedBox(height: 20),
            _buildPreferenceList(
              '숙소 선호도',
              _availableAccommodations,
              _selectedAccommodations,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}