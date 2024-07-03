class User {
  final int? id;
  final String password;
  final String name;
  final String nickname;
  final String birthDate;
  final String phoneNumber;
  final String? profileImage;
  final int isBlocked;

  User({
    this.id,
    required this.password,
    required this.name,
    required this.nickname,
    required this.birthDate,
    required this.phoneNumber,
    this.profileImage,
    this.isBlocked = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password': password,
      'name': name,
      'nickname': nickname,
      'birthDate': birthDate,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'isBlocked': isBlocked,
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
      profileImage: map['profileImage'],
      isBlocked: map['isBlocked'],
    );
  }
}
