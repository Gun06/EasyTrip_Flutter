// lib/models/user.dart
class User {
  final int? id;
  final String userId;
  final String password;
  final String name;
  final String nickname;
  final String birthDate;
  final String phoneNumber;

  User({
    this.id,
    required this.userId,
    required this.password,
    required this.name,
    required this.nickname,
    required this.birthDate,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'password': password,
      'name': name,
      'nickname': nickname,
      'birthDate': birthDate,
      'phoneNumber': phoneNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      userId: map['userId'],
      password: map['password'],
      name: map['name'],
      nickname: map['nickname'],
      birthDate: map['birthDate'],
      phoneNumber: map['phoneNumber'],
    );
  }

  User copy({int? id}) => User(
    id: id ?? this.id,
    userId: this.userId,
    password: this.password,
    name: this.name,
    nickname: this.nickname,
    birthDate: this.birthDate,
    phoneNumber: this.phoneNumber,
  );
}
