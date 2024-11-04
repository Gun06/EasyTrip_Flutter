// user.dart

class User {
  final int? id;
  final String password;
  final String name;
  final String nickname;
  final String birthDate;
  final String phoneNumber;
  final String email;
  final String? profileImage;
  final int isBlocked;
  final int age;
  final String gender;
  final List<String> activityPreferences;
  final List<String> foodPreferences;
  final List<String> accommodationPreferences;

  User({
    this.id,
    required this.password,
    required this.name,
    required this.nickname,
    required this.birthDate,
    required this.phoneNumber,
    required this.email,
    this.profileImage,
    this.isBlocked = 0,
    required this.age,
    required this.gender,
    required this.activityPreferences,
    required this.foodPreferences,
    required this.accommodationPreferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password': password,
      'name': name,
      'nickname': nickname,
      'birthDate': birthDate,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
      'isBlocked': isBlocked,
      'age': age,
      'gender': gender,
      'activityPreferences': activityPreferences.join(','),
      'foodPreferences': foodPreferences.join(','),
      'accommodationPreferences': accommodationPreferences.join(','),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    print("User.fromMap 호출됨: $map"); // 디버깅 로그 추가
    return User(
      id: map['id'],
      password: map['password'],
      name: map['name'],
      nickname: map['nickname'],
      birthDate: map['birthDate'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      profileImage: map['profileImage'],
      isBlocked: map['isBlocked'],
      age: map['age'],
      gender: map['gender'],
      activityPreferences: map['activityPreferences']?.split(',') ?? [],
      foodPreferences: map['foodPreferences']?.split(',') ?? [],
      accommodationPreferences: map['accommodationPreferences']?.split(',') ?? [],
    );
  }
}
