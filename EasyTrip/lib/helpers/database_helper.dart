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
    final dbPath = await getDatabasesPath(); // 데이터베이스 경로를 가져옴
    final path = join(dbPath, filePath); // 경로와 파일명을 합침

    return await openDatabase(path,
        version: 6, onCreate: _createDB, onUpgrade: _upgradeDB);
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
  }

  // 데이터베이스 업그레이드 (버전 변경 시 호출)
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute(
          'ALTER TABLE messages ADD COLUMN isRead INTEGER NOT NULL DEFAULT 0');
    }
  }

  // 사용자 차단
  Future<void> blockUser(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'isBlocked': 1}, // isBlocked를 1로 업데이트
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 사용자 차단 해제
  Future<void> unblockUser(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'isBlocked': 0}, // isBlocked를 0으로 업데이트
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
