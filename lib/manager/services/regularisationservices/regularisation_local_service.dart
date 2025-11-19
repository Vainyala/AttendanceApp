// services/regularisationservices/regularisation_local_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/regularisationmodels/regularisation_model.dart';

class RegularisationLocalService {
  static const String _databaseName = 'regularisation.db';
  static const int _databaseVersion = 1;

  static const String tableName = 'regularisation_requests';

  // Singleton instance
  static RegularisationLocalService? _instance;
  static Database? _database;

  RegularisationLocalService._internal();

  factory RegularisationLocalService() {
    _instance ??= RegularisationLocalService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        project_id TEXT NOT NULL,
        date TEXT NOT NULL,
        requested_date TEXT NOT NULL,
        approved_date TEXT,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        reason TEXT NOT NULL,
        remarks TEXT,
        approved_by TEXT,
        supporting_docs TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_user_id ON $tableName(user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_status ON $tableName(status)
    ''');
    await db.execute('''
      CREATE INDEX idx_date ON $tableName(date)
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add upgrade logic as needed
    }
  }

  // CRUD Operations
  Future<int> insertRequest(RegularisationRequest request) async {
    final db = await database;
    return await db.insert(
      tableName,
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RegularisationRequest>> getAllRequests(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => RegularisationRequest.fromMap(map)).toList();
  }

  Future<List<RegularisationRequest>> getRequestsByStatus(
    String userId,
    RegularisationStatus status,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status.toString().split('.').last],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => RegularisationRequest.fromMap(map)).toList();
  }

  Future<int> updateRequest(RegularisationRequest request) async {
    final db = await database;
    return await db.update(
      tableName,
      request.toMap(),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  Future<int> deleteRequest(String requestId) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [requestId]);
  }

  Future<Map<String, int>> getRequestStats(String userId) async {
    final db = await database;

    final total =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $tableName WHERE user_id = ?',
            [userId],
          ),
        ) ??
        0;

    final pending =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $tableName WHERE user_id = ? AND status = "pending"',
            [userId],
          ),
        ) ??
        0;

    final approved =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $tableName WHERE user_id = ? AND status = "approved"',
            [userId],
          ),
        ) ??
        0;

    final rejected =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $tableName WHERE user_id = ? AND status = "rejected"',
            [userId],
          ),
        ) ??
        0;

    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }

  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete(tableName, where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
