import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 데이터베이스 객체를 반환하는 getter
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('users.db');
    return _database!;
  }

  // 데이터베이스 초기화 및 생성
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // 데이터베이스 생성
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      password TEXT NOT NULL,
      name TEXT NOT NULL,
      nickname TEXT NOT NULL,
      birthDate TEXT NOT NULL,
      phoneNumber TEXT NOT NULL,
      email TEXT NOT NULL,
      profileImage TEXT,
      isBlocked INTEGER NOT NULL DEFAULT 0,
      age INTEGER NOT NULL,
      gender TEXT NOT NULL,
      activityPreferences TEXT,
      foodPreferences TEXT,
      accommodationPreferences TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      sender TEXT NOT NULL,
      message TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      isRead INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE schedule_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      date TEXT NOT NULL,
      allPrice TEXT NOT NULL,
      scheduleName TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE recommendation_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      scheduleId INTEGER NOT NULL,
      placeName TEXT NOT NULL,
      price TEXT NOT NULL,
      location TEXT NOT NULL,
      sortOrder INTEGER NOT NULL,
      FOREIGN KEY (scheduleId) REFERENCES schedule_entries (id)
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT NOT NULL DEFAULT "";');
    }

    if (oldVersion < 7) {
      await db.execute('''
      CREATE TABLE schedule_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        allPrice TEXT NOT NULL,
        scheduleName TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
      ''');

      await db.execute('''
      CREATE TABLE recommendation_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scheduleId INTEGER NOT NULL,
        placeName TEXT NOT NULL,
        price TEXT NOT NULL,
        location TEXT NOT NULL,
        sortOrder INTEGER NOT NULL,
        FOREIGN KEY (scheduleId) REFERENCES schedule_entries (id)
      )
      ''');
    }
  }

  // 테스트 사용자 추가 메서드
  Future<int> insertTestUser() async {
    final db = await database;
    int userId = await db.insert(
      'users',
      {
        'password': 'testpass',
        'name': '테스트 사용자',
        'nickname': '테스트닉네임',
        'birthDate': '1990-01-01',
        'phoneNumber': '010-1234-5678',
        'email': 'test@example.com',
        'profileImage': null,
        'isBlocked': 0,
        'age': 30,
        'gender': '남성',
        'activityPreferences': '등산,여행',
        'foodPreferences': '한식,일식',
        'accommodationPreferences': '호텔,모텔'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("테스트 사용자 삽입 완료, userId: $userId"); // 삽입된 ID 확인
    return userId;
  }

  // 특정 사용자 조회
  Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      columns: [
        'id',
        'password',
        'name',
        'nickname',
        'birthDate',
        'phoneNumber',
        'email',
        'profileImage',
        'isBlocked',
        'age',
        'gender',
        'activityPreferences',
        'foodPreferences',
        'accommodationPreferences'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    print("getUser 쿼리 결과: $maps"); // 디버깅 로그 추가

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      print("사용자를 찾을 수 없음");
      return null;
    }
  }

  // 일정 추가
  Future<int> insertSchedule(int userId, String date, String allPrice, String scheduleName) async {
    final db = await database;
    return await db.insert(
      'schedule_entries',
      {
        'userId': userId,
        'date': date,
        'allPrice': allPrice,
        'scheduleName': scheduleName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 추천 리스트 추가
  Future<void> insertRecommendations(int scheduleId, List<Map<String, dynamic>> recommendations) async {
    final db = await database;

    for (int i = 0; i < recommendations.length; i++) {
      await db.insert(
        'recommendation_entries',
        {
          'scheduleId': scheduleId,
          'placeName': recommendations[i]['title'],
          'price': recommendations[i]['price'],
          'location': recommendations[i]['location'],
          'sortOrder': i,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // 일정 이름 업데이트
  Future<void> updateScheduleName(int scheduleId, String newScheduleName) async {
    final db = await database;
    await db.update(
      'schedule_entries',
      {'scheduleName': newScheduleName},
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  // 추천 리스트에서 특정 장소 삭제
  Future<void> deleteRecommendation(int scheduleId, String placeName) async {
    final db = await database;
    await db.delete(
      'recommendation_entries',
      where: 'scheduleId = ? AND placeName = ?',
      whereArgs: [scheduleId, placeName],
    );
  }

  // 일정 삭제 (추천 리스트도 함께 삭제)
  Future<void> deleteSchedule(int scheduleId) async {
    final db = await database;

    // 일정에 속한 추천 리스트 삭제
    await db.delete(
      'recommendation_entries',
      where: 'scheduleId = ?',
      whereArgs: [scheduleId],
    );

    // 일정 삭제
    await db.delete(
      'schedule_entries',
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  // 일정 및 추천 장소 조회
  Future<List<Map<String, dynamic>>> getScheduleWithRecommendations(int userId) async {
    final db = await database;

    final List<Map<String, dynamic>> schedules = await db.query(
      'schedule_entries',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    List<Map<String, dynamic>> resultSchedules = [];

    for (var schedule in schedules) {
      Map<String, dynamic> scheduleCopy = Map<String, dynamic>.from(schedule);

      final List<Map<String, dynamic>> recommendations = await db.query(
        'recommendation_entries',
        where: 'scheduleId = ?',
        whereArgs: [schedule['id']],
        orderBy: 'sortOrder ASC',
      );

      scheduleCopy['recommendations'] = recommendations;

      resultSchedules.add(scheduleCopy);
    }

    return resultSchedules;
  }

  // 사용자 차단
  Future<void> blockUser(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'isBlocked': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 사용자 차단 해제
  Future<void> unblockUser(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'isBlocked': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 차단된 사용자 목록 조회
  Future<List<User>> getBlockedUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'isBlocked = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // 차단되지 않은 사용자 목록 조회
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'isBlocked = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // 모든 사용자 목록 조회
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // 사용자 삭제
  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 사용자 추가
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 사용자 정보 업데이트
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // 특정 사용자 조회
  Future<User?> getUserById(String id) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: [
        'id',
        'password',
        'name',
        'nickname',
        'birthDate',
        'phoneNumber',
        'email',
        'profileImage',
        'isBlocked',
        'age',
        'gender',
        'activityPreferences',
        'foodPreferences',
        'accommodationPreferences'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // 메시지 삽입
  Future<void> insertMessage(int userId, String sender, String message) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'userId': userId,
        'sender': sender,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 특정 사용자의 메시지 목록 조회
  Future<List<Map<String, dynamic>>> getMessages(int userId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp ASC',
    );
  }

  // 읽지 않은 메시지 개수 조회
  Future<int> getUnreadMessagesCount(int userId, String sender) async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM messages WHERE userId = ? AND sender = ? AND isRead = 0',
        [userId, sender])) ??
        0;
  }

  // 메시지를 읽음으로 표시
  Future<void> markMessagesAsRead(int userId, String sender) async {
    final db = await database;
    await db.update(
      'messages',
      {'isRead': 1},
      where: 'userId = ? AND sender = ? AND isRead = 0',
      whereArgs: [userId, sender],
    );
  }
}
