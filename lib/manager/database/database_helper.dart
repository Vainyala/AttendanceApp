import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const int _currentVersion = 4; // Updated version

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance_app.db');
    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        user_type TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    print('✅ Users table created successfully');
    await _insertDefaultUsers(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from v$oldVersion to v$newVersion');

    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _migrateToVersion(db, version);
    }
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('⚠️  Database downgrade not supported. Recreating database...');
    await db.execute('DROP TABLE IF EXISTS users');
    await _createTables(db, newVersion);
  }

  Future<void> _migrateToVersion(Database db, int targetVersion) async {
    switch (targetVersion) {
      case 2:
        print('📦 Migrating to v2: Adding hashed passwords');
        await db.delete('users');
        await _insertDefaultUsers(db);
        break;
      case 3:
        print('📦 Migrating to v3: Final hashed password structure');
        await _verifyAndFixPasswords(db);
        break;
      case 4:
        print('📦 Migrating to v4: Adding multiple users');
        await db.delete('users');
        await _insertDefaultUsers(db);
        break;
      default:
        print('❌ Unknown migration version: $targetVersion');
    }
  }

  Future<void> _verifyAndFixPasswords(Database db) async {
    final users = await db.query('users');
    int fixedCount = 0;

    for (final user in users) {
      final email = user['email'] as String;
      final storedPassword = user['password'] as String;
      final expectedPassword = _getPasswordForEmail(email);
      final expectedHash = _hashPassword(expectedPassword);

      if (storedPassword != expectedHash) {
        print('🔧 Fixing password for: $email');
        await db.update(
          'users',
          {'password': expectedHash},
          where: 'email = ?',
          whereArgs: [email],
        );
        fixedCount++;
      }
    }

    if (fixedCount > 0) {
      print('✅ Fixed $fixedCount user passwords');
    } else {
      print('✅ All passwords are correctly hashed');
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _insertDefaultUsers(Database db) async {
    final defaultUsers = [
      // Multiple Employees
      _createUser(
        email: 'employee1@nutantek.com',
        password: 'employee123',
        userType: 'employee',
        name: 'John Employee',
      ),
      _createUser(
        email: 'employee2@nutantek.com',
        password: 'employee123',
        userType: 'employee',
        name: 'Sarah Wilson',
      ),
      _createUser(
        email: 'employee3@nutantek.com',
        password: 'employee123',
        userType: 'employee',
        name: 'Mike Johnson',
      ),

      // Multiple Managers
      _createUser(
        email: 'manager1@nutantek.com',
        password: 'manager123',
        userType: 'manager',
        name: 'Jane Manager',
      ),
      _createUser(
        email: 'manager2@nutantek.com',
        password: 'manager123',
        userType: 'manager',
        name: 'Robert Brown',
      ),
      _createUser(
        email: 'manager3@nutantek.com',
        password: 'manager123',
        userType: 'manager',
        name: 'Lisa Davis',
      ),

      // HR
      _createUser(
        email: 'hr@nutantek.com',
        password: 'hr123',
        userType: 'hr',
        name: 'Mike HR',
      ),

      // Finance Manager
      _createUser(
        email: 'finance@nutantek.com',
        password: 'finance123',
        userType: 'finance_manager',
        name: 'Sarah Finance',
      ),
    ];

    final batch = db.batch();
    int successCount = 0;

    for (final user in defaultUsers) {
      batch.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    try {
      await batch.commit(noResult: true);
      successCount = defaultUsers.length;
      print(
        '✅ Successfully inserted $successCount users with hashed passwords',
      );
    } catch (e) {
      print('❌ Batch insert failed: $e');
      successCount = await _insertUsersOneByOne(db, defaultUsers);
    }

    await _performFinalVerification(db);
  }

  User _createUser({
    required String email,
    required String password,
    required String userType,
    required String name,
  }) {
    return User(
      email: email,
      password: _hashPassword(password),
      userType: userType,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  Future<int> _insertUsersOneByOne(Database db, List<User> users) async {
    int successCount = 0;
    for (final user in users) {
      try {
        await db.insert(
          'users',
          user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        successCount++;
        print('✅ Inserted: ${user.email}');
      } catch (e) {
        print('❌ Failed to insert ${user.email}: $e');
      }
    }
    return successCount;
  }

  Future<void> _performFinalVerification(Database db) async {
    print('🔍 PERFORMING FINAL DATABASE VERIFICATION');

    final users = await db.query('users');
    if (users.isEmpty) {
      print('❌ CRITICAL: No users found in database!');
      return;
    }

    bool allPasswordsValid = true;
    for (final user in users) {
      final email = user['email'] as String;
      final storedHash = user['password'] as String;
      final expectedHash = _hashPassword(_getPasswordForEmail(email));

      if (storedHash != expectedHash) {
        print('❌ INVALID PASSWORD: $email');
        print('   Stored: $storedHash');
        print('   Expected: $expectedHash');
        allPasswordsValid = false;
      } else {
        print('✅ VALID: $email');
      }
    }

    if (allPasswordsValid) {
      print('🎉 ALL PASSWORDS ARE CORRECTLY HASHED!');
      print('🔐 Available Logins:');
      print('   Employee Logins:');
      print('   - employee1@nutantek.com / employee123');
      print('   - employee2@nutantek.com / employee123');
      print('   - employee3@nutantek.com / employee123');
      print('   Manager Logins:');
      print('   - manager1@nutantek.com / manager123');
      print('   - manager2@nutantek.com / manager123');
      print('   - manager3@nutantek.com / manager123');
      print('   HR Login:');
      print('   - hr@nutantek.com / hr123');
      print('   Finance Login:');
      print('   - finance@nutantek.com / finance123');
    } else {
      print('💥 SOME PASSWORDS ARE INVALID!');
    }
  }

  // Public Methods
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  Future<void> debugPrintUsers() async {
    try {
      final db = await database;
      final users = await db.query('users');

      print('\n📊 === DATABASE STATE v$_currentVersion ===');
      print('📊 Total users: ${users.length}');

      final employeeCount = users
          .where((user) => user['user_type'] == 'employee')
          .length;
      final managerCount = users
          .where((user) => user['user_type'] == 'manager')
          .length;
      final hrCount = users.where((user) => user['user_type'] == 'hr').length;
      final financeCount = users
          .where((user) => user['user_type'] == 'finance_manager')
          .length;

      print('📊 User Distribution:');
      print('   👨‍💼 Employees: $employeeCount');
      print('   👔 Managers: $managerCount');
      print('   📋 HR: $hrCount');
      print('   💰 Finance: $financeCount');
      print('');

      for (var i = 0; i < users.length; i++) {
        final user = users[i];
        final email = user['email'] as String;
        final storedHash = user['password'] as String;
        final expectedHash = _hashPassword(_getPasswordForEmail(email));
        final isValid = storedHash == expectedHash;

        print('👤 ${i + 1}. ${user['name']}');
        print('   📧 ${user['email']}');
        print(
          '   🔑 ${isValid ? '✅' : '❌'} ${user['password']?.toString().substring(0, 20)}...',
        );
        print('   👥 ${user['user_type']}');
        print('   ---');
      }
      print('📊 === END DEBUG ===\n');
    } catch (e) {
      print('❌ Error reading database: $e');
    }
  }

  String _getPasswordForEmail(String email) {
    switch (email) {
      case 'employee1@nutantek.com':
      case 'employee2@nutantek.com':
      case 'employee3@nutantek.com':
        return 'employee123';
      case 'manager1@nutantek.com':
      case 'manager2@nutantek.com':
      case 'manager3@nutantek.com':
        return 'manager123';
      case 'hr@nutantek.com':
        return 'hr123';
      case 'finance@nutantek.com':
        return 'finance123';
      default:
        return 'unknown';
    }
  }

  Future<void> printAllUsers() async {
    await debugPrintUsers();
  }

  Future<void> testAllLogins() async {
    print('\n🧪 TESTING ALL USER LOGINS:');
    final testCredentials = [
      ('employee1@nutantek.com', 'employee123'),
      ('employee2@nutantek.com', 'employee123'),
      ('employee3@nutantek.com', 'employee123'),
      ('manager1@nutantek.com', 'manager123'),
      ('manager2@nutantek.com', 'manager123'),
      ('manager3@nutantek.com', 'manager123'),
      ('hr@nutantek.com', 'hr123'),
      ('finance@nutantek.com', 'finance123'),
    ];

    for (final (email, password) in testCredentials) {
      await testLogin(email, password);
    }

    print('\n📈 LOGIN TEST SUMMARY:');
    print('   Total users: ${testCredentials.length}');
    print('   Employees: 3');
    print('   Managers: 3');
    print('   HR: 1');
    print('   Finance: 1');
  }

  Future<void> testLogin(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null) {
      final inputHash = _hashPassword(password);
      final isValid = user.password == inputHash;

      print('${isValid ? '✅' : '❌'} $email: ${isValid ? 'SUCCESS' : 'FAILED'}');
    } else {
      print('❌ $email: USER NOT FOUND');
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('users');
    print('🗑️ Database reset complete');
    await _insertDefaultUsers(db);
  }

  Future<List<User>> getUsersByType(String userType) async {
    try {
      final db = await database;
      final maps = await db.query(
        'users',
        where: 'user_type = ?',
        whereArgs: [userType],
      );
      return maps.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error getting users by type: $e');
      return [];
    }
  }

  Future<Map<String, int>> getUserCountByType() async {
    try {
      final db = await database;
      final users = await db.query('users');
      final counts = <String, int>{};
      for (final user in users) {
        final type = user['user_type'] as String;
        counts[type] = (counts[type] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      print('❌ Error getting user counts: $e');
      return {};
    }
  }
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import '../models/user_model.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;
//   static const int _currentVersion = 3; // Permanent version

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'attendance_app.db');
//     return await openDatabase(
//       path,
//       version: _currentVersion,
//       onCreate: _createTables,
//       onUpgrade: _onUpgrade,
//       onDowngrade: _onDowngrade,
//     );
//   }

//   Future<void> _createTables(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE users(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         email TEXT UNIQUE NOT NULL,
//         password TEXT NOT NULL,
//         user_type TEXT NOT NULL,
//         name TEXT NOT NULL,
//         created_at TEXT NOT NULL
//       )
//     ''');

//     print('✅ Users table created successfully');
//     await _insertDefaultUsers(db);
//   }

//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     print('🔄 Upgrading database from v$oldVersion to v$newVersion');

//     // Step-by-step migration
//     for (int version = oldVersion + 1; version <= newVersion; version++) {
//       await _migrateToVersion(db, version);
//     }
//   }

//   Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
//     print('⚠️  Database downgrade not supported. Recreating database...');
//     await db.execute('DROP TABLE IF EXISTS users');
//     await _createTables(db, newVersion);
//   }

//   Future<void> _migrateToVersion(Database db, int targetVersion) async {
//     switch (targetVersion) {
//       case 2:
//         print('📦 Migrating to v2: Adding hashed passwords');
//         await db.delete('users');
//         await _insertDefaultUsers(db);
//         break;
//       case 3:
//         print('📦 Migrating to v3: Final hashed password structure');
//         // Verify and fix any password inconsistencies
//         await _verifyAndFixPasswords(db);
//         break;
//       default:
//         print('❌ Unknown migration version: $targetVersion');
//     }
//   }

//   Future<void> _verifyAndFixPasswords(Database db) async {
//     final users = await db.query('users');
//     int fixedCount = 0;

//     for (final user in users) {
//       final email = user['email'] as String;
//       final storedPassword = user['password'] as String;
//       final expectedPassword = _getPasswordForEmail(email);
//       final expectedHash = _hashPassword(expectedPassword);

//       if (storedPassword != expectedHash) {
//         print('🔧 Fixing password for: $email');
//         await db.update(
//           'users',
//           {'password': expectedHash},
//           where: 'email = ?',
//           whereArgs: [email],
//         );
//         fixedCount++;
//       }
//     }

//     if (fixedCount > 0) {
//       print('✅ Fixed $fixedCount user passwords');
//     } else {
//       print('✅ All passwords are correctly hashed');
//     }
//   }

//   String _hashPassword(String password) {
//     return sha256.convert(utf8.encode(password)).toString();
//   }

//   Future<void> _insertDefaultUsers(Database db) async {
//     final defaultUsers = [
//       // Multiple Employees
//       _createUser(
//         email: 'employee1@nutantek.com',
//         password: 'employee123',
//         userType: 'employee',
//         name: 'John Employee',
//       ),
//       _createUser(
//         email: 'employee2@nutantek.com',
//         password: 'employee123',
//         userType: 'employee',
//         name: 'Sarah Wilson',
//       ),
//       _createUser(
//         email: 'employee3@nutantek.com',
//         password: 'employee123',
//         userType: 'employee',
//         name: 'Mike Johnson',
//       ),

//       // Multiple Managers
//       _createUser(
//         email: 'manager1@nutantek.com',
//         password: 'manager123',
//         userType: 'manager',
//         name: 'Jane Manager',
//       ),
//       _createUser(
//         email: 'manager2@nutantek.com',
//         password: 'manager123',
//         userType: 'manager',
//         name: 'Robert Brown',
//       ),
//       _createUser(
//         email: 'manager3@nutantek.com',
//         password: 'manager123',
//         userType: 'manager',
//         name: 'Lisa Davis',
//       ),

//       // HR
//       _createUser(
//         email: 'hr@nutantek.com',
//         password: 'hr123',
//         userType: 'hr',
//         name: 'Mike HR',
//       ),

//       // Finance Manager
//       _createUser(
//         email: 'finance@nutantek.com',
//         password: 'finance123',
//         userType: 'finance_manager',
//         name: 'Sarah Finance',
//       ),
//     ];

//     final batch = db.batch();
//     int successCount = 0;

//     for (final user in defaultUsers) {
//       batch.insert(
//         'users',
//         user.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     }

//     try {
//       await batch.commit(noResult: true);
//       successCount = defaultUsers.length;
//       print(
//         '✅ Successfully inserted $successCount users with hashed passwords',
//       );
//     } catch (e) {
//       print('❌ Batch insert failed: $e');
//       // Fallback: Insert one by one
//       successCount = await _insertUsersOneByOne(db, defaultUsers);
//     }

//     await _performFinalVerification(db);
//   }

//   User _createUser({
//     required String email,
//     required String password,
//     required String userType,
//     required String name,
//   }) {
//     return User(
//       email: email,
//       password: _hashPassword(password), // Always hash during creation
//       userType: userType,
//       name: name,
//       createdAt: DateTime.now(),
//     );
//   }

//   Future<int> _insertUsersOneByOne(Database db, List<User> users) async {
//     int successCount = 0;
//     for (final user in users) {
//       try {
//         await db.insert(
//           'users',
//           user.toMap(),
//           conflictAlgorithm: ConflictAlgorithm.replace,
//         );
//         successCount++;
//         print('✅ Inserted: ${user.email}');
//       } catch (e) {
//         print('❌ Failed to insert ${user.email}: $e');
//       }
//     }
//     return successCount;
//   }

//   Future<void> _performFinalVerification(Database db) async {
//     print('🔍 PERFORMING FINAL DATABASE VERIFICATION');

//     final users = await db.query('users');
//     if (users.isEmpty) {
//       print('❌ CRITICAL: No users found in database!');
//       return;
//     }

//     bool allPasswordsValid = true;
//     for (final user in users) {
//       final email = user['email'] as String;
//       final storedHash = user['password'] as String;
//       final expectedHash = _hashPassword(_getPasswordForEmail(email));

//       if (storedHash != expectedHash) {
//         print('❌ INVALID PASSWORD: $email');
//         print('   Stored: $storedHash');
//         print('   Expected: $expectedHash');
//         allPasswordsValid = false;
//       } else {
//         print('✅ VALID: $email');
//       }
//     }

//     if (allPasswordsValid) {
//       print('🎉 ALL PASSWORDS ARE CORRECTLY HASHED!');
//       print('🔐 Login should work with:');
//       print('   Employee Logins:');
//       print('   - employee1@nutantek.com / employee123');
//       print('   - employee2@nutantek.com / employee123');
//       print('   - employee3@nutantek.com / employee123');
//       print('   Manager Logins:');
//       print('   - manager1@nutantek.com / manager123');
//       print('   - manager2@nutantek.com / manager123');
//       print('   - manager3@nutantek.com / manager123');
//       print('   HR Login:');
//       print('   - hr@nutantek.com / hr123');
//       print('   Finance Login:');
//       print('   - finance@nutantek.com / finance123');
//     } else {
//       print('💥 SOME PASSWORDS ARE INVALID!');
//     }
//   }

//   // Public Methods
//   Future<User?> getUserByEmail(String email) async {
//     try {
//       final db = await database;
//       final maps = await db.query(
//         'users',
//         where: 'email = ?',
//         whereArgs: [email],
//       );

//       if (maps.isNotEmpty) {
//         return User.fromMap(maps.first);
//       }
//       return null;
//     } catch (e) {
//       print('❌ Error getting user by email: $e');
//       return null;
//     }
//   }

//   Future<void> debugPrintUsers() async {
//     try {
//       final db = await database;
//       final users = await db.query('users');

//       print('\n📊 === DATABASE STATE v$_currentVersion ===');
//       print('📊 Total users: ${users.length}');

//       // Count by user type
//       final employeeCount = users
//           .where((user) => user['user_type'] == 'employee')
//           .length;
//       final managerCount = users
//           .where((user) => user['user_type'] == 'manager')
//           .length;
//       final hrCount = users.where((user) => user['user_type'] == 'hr').length;
//       final financeCount = users
//           .where((user) => user['user_type'] == 'finance_manager')
//           .length;

//       print('📊 User Distribution:');
//       print('   👨‍💼 Employees: $employeeCount');
//       print('   👔 Managers: $managerCount');
//       print('   📋 HR: $hrCount');
//       print('   💰 Finance: $financeCount');
//       print('');

//       for (var i = 0; i < users.length; i++) {
//         final user = users[i];
//         final email = user['email'] as String;
//         final storedHash = user['password'] as String;
//         final expectedHash = _hashPassword(_getPasswordForEmail(email));
//         final isValid = storedHash == expectedHash;

//         print('👤 ${i + 1}. ${user['name']}');
//         print('   📧 ${user['email']}');
//         print('   🔑 ${isValid ? '✅' : '❌'} ${user['password']}');
//         print('   👥 ${user['user_type']}');
//         if (!isValid) {
//           print('   💡 Expected: $expectedHash');
//         }
//         print('   ---');
//       }
//       print('📊 === END DEBUG ===\n');
//     } catch (e) {
//       print('❌ Error reading database: $e');
//     }
//   }

//   String _getPasswordForEmail(String email) {
//     switch (email) {
//       case 'employee1@nutantek.com':
//       case 'employee2@nutantek.com':
//       case 'employee3@nutantek.com':
//         return 'employee123';
//       case 'manager1@nutantek.com':
//       case 'manager2@nutantek.com':
//       case 'manager3@nutantek.com':
//         return 'manager123';
//       case 'hr@nutantek.com':
//         return 'hr123';
//       case 'finance@nutantek.com':
//         return 'finance123';
//       default:
//         return 'unknown';
//     }
//   }

//   Future<void> printAllUsers() async {
//     await debugPrintUsers();
//   }

//   Future<void> testAllLogins() async {
//     print('\n🧪 TESTING ALL USER LOGINS:');
//     final testCredentials = [
//       // Employees
//       ('employee1@nutantek.com', 'employee123'),
//       ('employee2@nutantek.com', 'employee123'),
//       ('employee3@nutantek.com', 'employee123'),
//       // Managers
//       ('manager1@nutantek.com', 'manager123'),
//       ('manager2@nutantek.com', 'manager123'),
//       ('manager3@nutantek.com', 'manager123'),
//       // HR
//       ('hr@nutantek.com', 'hr123'),
//       // Finance
//       ('finance@nutantek.com', 'finance123'),
//     ];

//     int successCount = 0;
//     int totalCount = testCredentials.length;

//     for (final (email, password) in testCredentials) {
//       await testLogin(email, password);
//     }

//     print('\n📈 LOGIN TEST SUMMARY:');
//     print('   Total users: $totalCount');
//     print('   Employees: 3');
//     print('   Managers: 3');
//     print('   HR: 1');
//     print('   Finance: 1');
//   }

//   Future<void> testLogin(String email, String password) async {
//     final user = await getUserByEmail(email);
//     if (user != null) {
//       final inputHash = _hashPassword(password);
//       final isValid = user.password == inputHash;

//       print('${isValid ? '✅' : '❌'} $email: ${isValid ? 'SUCCESS' : 'FAILED'}');
//       if (!isValid) {
//         print('   Stored:  ${user.password}');
//         print('   Input:   $inputHash');
//       }
//     } else {
//       print('❌ $email: USER NOT FOUND');
//     }
//   }

//   // Utility method to reset database (for testing)
//   Future<void> resetDatabase() async {
//     final db = await database;
//     await db.delete('users');
//     print('🗑️ Database reset complete');
//     await _insertDefaultUsers(db);
//   }

//   // Get all users by type for dashboard purposes
//   Future<List<User>> getUsersByType(String userType) async {
//     try {
//       final db = await database;
//       final maps = await db.query(
//         'users',
//         where: 'user_type = ?',
//         whereArgs: [userType],
//       );

//       return maps.map((map) => User.fromMap(map)).toList();
//     } catch (e) {
//       print('❌ Error getting users by type: $e');
//       return [];
//     }
//   }

//   // Get user count by type
//   Future<Map<String, int>> getUserCountByType() async {
//     try {
//       final db = await database;
//       final users = await db.query('users');

//       final counts = <String, int>{};
//       for (final user in users) {
//         final type = user['user_type'] as String;
//         counts[type] = (counts[type] ?? 0) + 1;
//       }

//       return counts;
//     } catch (e) {
//       print('❌ Error getting user counts: $e');
//       return {};
//     }
//   }
// }
