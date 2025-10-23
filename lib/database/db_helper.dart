import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // User table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        check_in TEXT,
        check_out TEXT,
        status TEXT,
        location TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (user_id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_user_id ON users(user_id)');
    await db.execute('CREATE INDEX idx_attendance_user ON attendance(user_id)');
    await db.execute('CREATE INDEX idx_attendance_date ON attendance(date)');
  }

  // User CRUD operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(String userId, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(String userId) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Attendance CRUD operations
  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.insert('attendance', attendance);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByUserId(String userId) async {
    final db = await database;
    return await db.query(
      'attendance',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(String userId, String date) async {
    final db = await database;
    return await db.query(
      'attendance',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
    );
  }

  Future<int> updateAttendance(int id, Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.update(
      'attendance',
      attendance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('attendance');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}