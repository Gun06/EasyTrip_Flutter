import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
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

    await db.execute('''
    CREATE TABLE messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      sender TEXT NOT NULL,
      message TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
      ALTER TABLE users ADD COLUMN activityPreferences TEXT;
      ''');
      await db.execute('''
      ALTER TABLE users ADD COLUMN foodPreferences TEXT;
      ''');
      await db.execute('''
      ALTER TABLE users ADD COLUMN accommodationPreferences TEXT;
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        sender TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
      ''');
    }
  }

  Future<void> blockUser(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'isBlocked': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> unblockUser(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'isBlocked': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

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

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

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
      columns: ['id', 'password', 'name', 'nickname', 'birthDate', 'phoneNumber', 'profileImage', 'isBlocked', 'age', 'gender', 'activityPreferences', 'foodPreferences', 'accommodationPreferences'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // 메시지 관련 메서드
  Future<void> insertMessage(int userId, String sender, String message) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'userId': userId,
        'sender': sender,
        'message': message,
        'timestamp': DateTime.now().toIso8601String()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMessages(int userId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp ASC',
    );
  }
}
