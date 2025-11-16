import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
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
      version: 2, // Increment version to add new table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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

    // **NEW: Employee daily data table**
    await db.execute('''
      CREATE TABLE employee_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        emp_id TEXT NOT NULL,
        emp_name TEXT NOT NULL,
        emp_email TEXT,
        emp_role TEXT,
        project_id TEXT,
        project_name TEXT,
        mapped_projects TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        work_mode TEXT,
        check_in_date TEXT,
        check_in_time TEXT,
        created_at TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_user_id ON users(user_id)');
    await db.execute('CREATE INDEX idx_attendance_user ON attendance(user_id)');
    await db.execute('CREATE INDEX idx_attendance_date ON attendance(date)');
    await db.execute('CREATE INDEX idx_employee_data_emp_id ON employee_data(emp_id)');
    await db.execute('CREATE INDEX idx_employee_data_date ON employee_data(check_in_date)');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add employee_data table if upgrading from version 1
      await db.execute('''
        CREATE TABLE employee_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          emp_id TEXT NOT NULL,
          emp_name TEXT NOT NULL,
          emp_email TEXT,
          emp_role TEXT,
          project_id TEXT,
          project_name TEXT,
          mapped_projects TEXT,
          latitude REAL,
          longitude REAL,
          address TEXT,
          work_mode TEXT,
          check_in_date TEXT,
          check_in_time TEXT,
          created_at TEXT
        )
      ''');
      await db.execute('CREATE INDEX idx_employee_data_emp_id ON employee_data(emp_id)');
      await db.execute('CREATE INDEX idx_employee_data_date ON employee_data(check_in_date)');
    }
  }

  // **NEW: Check if employee data exists for today**
  Future<bool> checkEmployeeDataExistsToday(String empId) async {
    try {
      final db = await database;
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final result = await db.query(
        'employee_data',
        where: 'emp_id = ? AND check_in_date = ?',
        whereArgs: [empId, todayStr],
      );

      debugPrint('📊 Employee data check for $todayStr: ${result.isNotEmpty ? "EXISTS" : "NOT FOUND"}');
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking employee data: $e');
      return false;
    }
  }

  // **NEW: Store employee data**
  Future<int> storeEmployeeData(Map<String, dynamic> data) async {
    try {
      final db = await database;
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      final employeeData = {
        'emp_id': data['emp_id'] ?? '',
        'emp_name': data['emp_name'] ?? '',
        'emp_email': data['emp_email'] ?? '',
        'emp_role': data['emp_role'] ?? '',
        'project_id': data['project_id'] ?? '',
        'project_name': data['project_name'] ?? '',
        'mapped_projects': data['mapped_projects'] ?? '',
        'latitude': data['latitude'] ?? 0.0,
        'longitude': data['longitude'] ?? 0.0,
        'address': data['address'] ?? '',
        'work_mode': data['work_mode'] ?? 'Unknown',
        'check_in_date': dateStr,
        'check_in_time': timeStr,
        'created_at': now.toIso8601String(),
      };

      final result = await db.insert('employee_data', employeeData);
      debugPrint('✅ Employee data stored successfully for $dateStr (ID: $result)');
      return result;
    } catch (e) {
      debugPrint('❌ Error storing employee data: $e');
      return -1;
    }
  }

  // **NEW: Get today's employee data**
  Future<Map<String, dynamic>?> getTodayEmployeeData(String empId) async {
    try {
      final db = await database;
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final result = await db.query(
        'employee_data',
        where: 'emp_id = ? AND check_in_date = ?',
        whereArgs: [empId, todayStr],
        limit: 1,
      );

      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('❌ Error getting today employee data: $e');
      return null;
    }
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
    await db.delete('employee_data');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}