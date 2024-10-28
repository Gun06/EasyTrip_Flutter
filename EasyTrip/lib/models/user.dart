class User {
  final int? id;
  final String password;
  final String name;
  final String nickname;
  final String birthDate;
  final String phoneNumber;
  final String email; // 이메일 필드 추가
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
    required this.email, // 이메일 필드 추가
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
      'email': email, // 이메일 필드 추가
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
    return User(
      id: map['id'],
      password: map['password'],
      name: map['name'],
      nickname: map['nickname'],
      birthDate: map['birthDate'],
      phoneNumber: map['phoneNumber'],
      email: map['email'], // 이메일 필드 추가
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
