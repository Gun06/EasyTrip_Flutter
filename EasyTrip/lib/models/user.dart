class User {
  final int? id;
  final String password;
  final String name;
  final String nickname;
  final String birthDate;
  final String phoneNumber;
  final String? profileImage; // 프로필 이미지 속성 추가

  User({
    this.id,
    required this.password,
    required this.name,
    required this.nickname,
    required this.birthDate,
    required this.phoneNumber,
    this.profileImage,
  });

  // 데이터베이스에서 User 객체를 생성하는 메서드
  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"],
    password: json["password"],
    name: json["name"],
    nickname: json["nickname"],
    birthDate: json["birthDate"],
    phoneNumber: json["phoneNumber"],
    profileImage: json["profileImage"],
  );

  // 데이터베이스에 저장할 수 있는 Map 객체를 생성하는 메서드
  Map<String, dynamic> toMap() => {
    "id": id,
    "password": password,
    "name": name,
    "nickname": nickname,
    "birthDate": birthDate,
    "phoneNumber": phoneNumber,
    "profileImage": profileImage,
  };
}
