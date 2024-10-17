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

    return await openDatabase(path, version: 7, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  // 데이터베이스 생성
  Future _createDB(Database db, int version) async {
    // 사용자 테이블 생성
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      password TEXT NOT NULL,
      name TEXT NOT NULL,
      nickname TEXT NOT NULL,
      birthDate TEXT NOT NULL,
      phoneNumber TEXT NOT NULL,
      profileImage TEXT,
      isBlocked INTEGER NOT NULL DEFAULT 0,
      age INTEGER NOT NULL,
      gender TEXT NOT NULL,
      activityPreferences TEXT,
      foodPreferences TEXT,
      accommodationPreferences TEXT
    )
    ''');

    // 메시지 테이블 생성
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

    // 일정 테이블 생성
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

    // 추천된 장소 테이블 생성
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
    if (oldVersion < 7) {
      // 일정 테이블 추가
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

      // 추천된 장소 테이블 추가
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
// 추천 리스트 추가
  Future<void> insertRecommendations(int scheduleId, List<Map<String, dynamic>> recommendations) async {
    final db = await database;

    for (int i = 0; i < recommendations.length; i++) {
      await db.insert(
        'recommendation_entries',
        {
          'scheduleId': scheduleId,
          'placeName': recommendations[i]['title'],  // 'title' 키가 맞는지 확인하세요.
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
      // 새로 Map 객체 생성
      Map<String, dynamic> scheduleCopy = Map<String, dynamic>.from(schedule);

      final List<Map<String, dynamic>> recommendations = await db.query(
        'recommendation_entries',
        where: 'scheduleId = ?',
        whereArgs: [schedule['id']],
        orderBy: 'sortOrder ASC',
      );

      // 새롭게 복사한 객체에 추천 정보를 추가
      scheduleCopy['recommendations'] = recommendations;

      resultSchedules.add(scheduleCopy); // 복사한 객체를 리스트에 추가
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

  // 특정 사용자의 특정 발신자로부터의 읽지 않은 메시지 개수 조회
  Future<int> getUnreadMessagesCount(int userId, String sender) async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM messages WHERE userId = ? AND sender = ? AND isRead = 0',
        [userId, sender])) ??
        0;
  }

  // 특정 사용자의 특정 발신자로부터의 메시지를 읽음으로 표시
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
