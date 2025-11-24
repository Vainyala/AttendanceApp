// services/leaveservices/leave_database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/leavemodels/leave_model.dart';

class LeaveDatabaseService {
  static const String _databaseName = 'leave_management.db';
  static const int _databaseVersion = 3;

  static const String leaveTable = 'leave_applications';
  static const String balanceTable = 'leave_balances';

  static LeaveDatabaseService? _instance;
  static Database? _database;

  LeaveDatabaseService._internal();

  factory LeaveDatabaseService() {
    _instance ??= LeaveDatabaseService._internal();
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
    // Create leave applications table
    await db.execute('''
      CREATE TABLE $leaveTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        employee_role TEXT NOT NULL,
        employee_email TEXT NOT NULL,
        employee_phone TEXT NOT NULL,
        employee_photo TEXT,
        project_name TEXT NOT NULL,
        leave_type TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        total_days INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL,
        manager_remarks TEXT,
        approved_by TEXT,
        applied_date INTEGER NOT NULL,
        approved_date INTEGER,
        supporting_docs TEXT,
        contact_number TEXT NOT NULL,
        handover_person_name TEXT NOT NULL,
        handover_person_email TEXT NOT NULL,
        handover_person_phone TEXT NOT NULL,
        handover_person_photo TEXT
      )
    ''');

    // Create leave balances table
    await db.execute('''
      CREATE TABLE $balanceTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL,
        leave_type TEXT NOT NULL,
        total_days INTEGER NOT NULL,
        used_days INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');

    await _insertSampleData(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $leaveTable ADD COLUMN employee_phone TEXT NOT NULL DEFAULT ''
      ''');
      await db.execute('''
        ALTER TABLE $leaveTable ADD COLUMN handover_person_photo TEXT
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $balanceTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          employee_id TEXT NOT NULL,
          leave_type TEXT NOT NULL,
          total_days INTEGER NOT NULL,
          used_days INTEGER NOT NULL,
          year INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now();

    // Insert sample leave applications
    final sampleApplications = [
      LeaveApplication(
        employeeId: 'EMP001',
        employeeName: 'Raj Sharma',
        employeeRole: 'Senior Developer',
        employeeEmail: 'raj.sharma@company.com',
        employeePhone: '+91 9876543210',
        employeePhoto: '',
        projectName: 'Mobile App Development',
        leaveType: LeaveType.casual,
        startDate: DateTime(now.year, now.month, 15),
        endDate: DateTime(now.year, now.month, 16),
        totalDays: 2,
        reason:
            'Family wedding ceremony in hometown. Need to attend the function and help with family arrangements.',
        status: LeaveStatus.pending,
        appliedDate: DateTime(now.year, now.month, 10, 9, 30),
        contactNumber: '+91 9876543210',
        handoverPersonName: 'Amit Kumar',
        handoverPersonEmail: 'amit.kumar@company.com',
        handoverPersonPhone: '+91 9876543212',
        handoverPersonPhoto: '',
      ),
      LeaveApplication(
        employeeId: 'EMP002',
        employeeName: 'Priya Singh',
        employeeRole: 'UI/UX Designer',
        employeeEmail: 'priya.singh@company.com',
        employeePhone: '+91 9876543211',
        employeePhoto: '',
        projectName: 'Website Redesign',
        leaveType: LeaveType.sick,
        startDate: DateTime(now.year, now.month, 18),
        endDate: DateTime(now.year, now.month, 18),
        totalDays: 1,
        reason:
            'High fever and doctor appointment for medical checkup. Doctor advised complete rest for one day.',
        status: LeaveStatus.approved,
        appliedDate: DateTime(now.year, now.month, 12, 10, 15),
        approvedDate: DateTime(now.year, now.month, 13, 11, 0),
        approvedBy: 'Manager User',
        managerRemarks:
            'Medical reason seems genuine. Approved as per company policy. Employee has provided doctor certificate. Work handover has been properly arranged with Neha Patel.',
        contactNumber: '+91 9876543211',
        handoverPersonName: 'Neha Patel',
        handoverPersonEmail: 'neha.patel@company.com',
        handoverPersonPhone: '+91 9876543213',
        handoverPersonPhoto: '',
      ),
      LeaveApplication(
        employeeId: 'EMP003',
        employeeName: 'Amit Kumar',
        employeeRole: 'QA Engineer',
        employeeEmail: 'amit.kumar@company.com',
        employeePhone: '+91 9876543212',
        employeePhoto: '',
        projectName: 'Mobile App Development',
        leaveType: LeaveType.earned,
        startDate: DateTime(now.year, now.month, 20),
        endDate: DateTime(now.year, now.month, 24),
        totalDays: 5,
        reason:
            'Vacation with family to hill station. Already planned and booked tickets 2 months ago. Need this break for mental refreshment.',
        status: LeaveStatus.rejected,
        appliedDate: DateTime(now.year, now.month, 5, 14, 20),
        approvedDate: DateTime(now.year, now.month, 6, 16, 0),
        approvedBy: 'Manager User',
        managerRemarks:
            'Project deadline approaching in the same week. Critical testing phase cannot be handled by single team member. Please reschedule your vacation after project delivery which is in next month.',
        contactNumber: '+91 9876543212',
        handoverPersonName: 'Raj Sharma',
        handoverPersonEmail: 'raj.sharma@company.com',
        handoverPersonPhone: '+91 9876543210',
        handoverPersonPhoto: '',
      ),
      LeaveApplication(
        employeeId: 'EMP004',
        employeeName: 'Neha Patel',
        employeeRole: 'Project Manager',
        employeeEmail: 'neha.patel@company.com',
        employeePhone: '+91 9876543213',
        employeePhoto: '',
        projectName: 'Client Management System',
        leaveType: LeaveType.maternity,
        startDate: DateTime(now.year, now.month + 1, 1),
        endDate: DateTime(now.year, now.month + 3, 30),
        totalDays: 90,
        reason:
            'Maternity leave as per company policy for expecting mothers. Doctor has recommended complete rest during this period.',
        status: LeaveStatus.query,
        appliedDate: DateTime(now.year, now.month, 1, 16, 45),
        managerRemarks:
            'Please provide medical documents and delivery date confirmation from hospital.',
        contactNumber: '+91 9876543213',
        handoverPersonName: 'Sanjay Verma',
        handoverPersonEmail: 'sanjay.verma@company.com',
        handoverPersonPhone: '+91 9876543214',
        handoverPersonPhoto: '',
      ),
    ];

    // for (final application in sampleApplications) {
    //   await db.insert(leaveTable, application.toMap());
    // }

    int insertedCount = 0;
    for (final application in sampleApplications) {
      try {
        // YEH LINE CHANGE KARO - toMap() add karo
        final result = await db.insert(leaveTable, application.toMap());
        if (result > 0) insertedCount++;
        print('Inserted application: ${application.employeeName}'); // Debug
      } catch (e) {
        print('Error inserting ${application.employeeName}: $e'); // Debug
      }
    }

    print('Successfully inserted $insertedCount applications'); // Debug

    // Insert sample leave balances
    final sampleBalances = [
      LeaveBalance(
        employeeId: 'EMP001',
        leaveType: LeaveType.casual,
        totalDays: 18,
        usedDays: 6,
        year: now.year,
      ),
      LeaveBalance(
        employeeId: 'EMP001',
        leaveType: LeaveType.sick,
        totalDays: 12,
        usedDays: 2,
        year: now.year,
      ),
      LeaveBalance(
        employeeId: 'EMP001',
        leaveType: LeaveType.earned,
        totalDays: 20,
        usedDays: 8,
        year: now.year,
      ),
    ];

    // for (final balance in sampleBalances) {
    //   await db.insert(balanceTable, balance.toMap());
    // }
    int balanceCount = 0;
    for (final balance in sampleBalances) {
      try {
        // YEH BHI CHANGE KARO - toMap() add karo
        final result = await db.insert(balanceTable, balance.toMap());
        if (result > 0) balanceCount++;
      } catch (e) {
        print('Error inserting balance: $e'); // Debug
      }
    }
    print('Successfully inserted $balanceCount balances'); // Debug
  }

  // ========== LEAVE APPLICATIONS CRUD OPERATIONS ==========

  // Future<List<LeaveApplication>> getAllLeaveApplications() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     leaveTable,
  //     orderBy: 'applied_date DESC',
  //   );
  //   return maps.map((map) => LeaveApplication.fromMap(map)).toList();
  // }

  // services/leaveservices/leave_database_service.dart
  Future<List<LeaveApplication>> getAllLeaveApplications() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        leaveTable,
        orderBy: 'applied_date DESC',
      );

      print('📊 Raw database records found: ${maps.length}');

      // Pehle record check karo
      if (maps.isNotEmpty) {
        print('🔍 First record details:');
        final firstRecord = maps.first;
        firstRecord.forEach((key, value) {
          print('  $key: $value (type: ${value.runtimeType})');
        });
      }

      final applications = <LeaveApplication>[];
      for (final map in maps) {
        try {
          final application = LeaveApplication.fromMap(map);
          applications.add(application);
        } catch (e) {
          print('❌ Error parsing record: $e');
          print('❌ Problematic record: $map');
          // Skip problematic records
        }
      }

      return applications;
    } catch (e) {
      print('❌ Error in getAllLeaveApplications: $e');
      return [];
    }
  }

  Future<List<LeaveApplication>> getLeaveApplicationsByStatus(
    LeaveStatus status,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      leaveTable,
      where: 'status = ?',
      whereArgs: [status.toString().split('.').last],
      orderBy: 'applied_date DESC',
    );
    return maps.map((map) => LeaveApplication.fromMap(map)).toList();
  }

  Future<List<LeaveApplication>> getCurrentMonthApplications() async {
    final db = await database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      leaveTable,
      where: 'applied_date >= ? AND applied_date <= ?',
      whereArgs: [
        firstDayOfMonth.millisecondsSinceEpoch,
        lastDayOfMonth.millisecondsSinceEpoch,
      ],
      orderBy: 'applied_date DESC',
    );
    return maps.map((map) => LeaveApplication.fromMap(map)).toList();
  }

  //local data
  // services/leaveservices/leave_database_service.dart
  Future<bool> hasData() async {
    try {
      final db = await database;
      final count =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $leaveTable'),
          ) ??
          0;
      print('📊 Database has $count leave applications');
      return count > 0;
    } catch (e) {
      print('❌ Error checking database: $e');
      return false;
    }
  }

  // Database service mein yeh method add karo
  Future<void> checkDatabaseSchema() async {
    final db = await database;

    // Table structure check karo
    final tableInfo = await db.rawQuery('PRAGMA table_info($leaveTable)');
    print('📋 Leave Table Schema:');
    for (final column in tableInfo) {
      print('  ${column['name']} - ${column['type']}');
    }

    // Sample data check karo
    final sampleData = await db.query(leaveTable, limit: 1);
    if (sampleData.isNotEmpty) {
      print('🔍 Sample Data Types:');
      sampleData.first.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
    }
  }

  // Temporary solution - app uninstall karo ya database delete karo
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete(leaveTable);
    await db.delete(balanceTable);
    print('🗑️ Database reset complete');
    await _insertSampleData(db);
    print('🔄 Sample data reinserted');
  }

  Future<LeaveApplication?> getLeaveApplicationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      leaveTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return LeaveApplication.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertLeaveApplication(LeaveApplication application) async {
    final db = await database;
    return await db.insert(leaveTable, application.toMap());
  }

  Future<int> updateLeaveApplication(LeaveApplication application) async {
    final db = await database;
    return await db.update(
      leaveTable,
      application.toMap(),
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }

  Future<int> updateLeaveStatus(
    int id,
    LeaveStatus status,
    String managerRemarks,
    String approvedBy,
  ) async {
    final db = await database;
    return await db.update(
      leaveTable,
      {
        'status': status.toString().split('.').last,
        'manager_remarks': managerRemarks,
        'approved_by': approvedBy,
        'approved_date': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLeaveApplication(int id) async {
    final db = await database;
    return await db.delete(leaveTable, where: 'id = ?', whereArgs: [id]);
  }

  // ========== SEARCH OPERATIONS ==========

  Future<List<LeaveApplication>> searchLeaveApplications(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      leaveTable,
      where: '''
        employee_name LIKE ? OR 
        employee_id LIKE ? OR 
        employee_email LIKE ? OR 
        project_name LIKE ? OR 
        leave_type LIKE ? OR
        handover_person_name LIKE ? OR
        employee_role LIKE ?
      ''',
      whereArgs: List.filled(7, '%$query%'),
      orderBy: 'applied_date DESC',
    );
    return maps.map((map) => LeaveApplication.fromMap(map)).toList();
  }

  Future<List<LeaveApplication>> getLeaveApplicationsByEmployee(
    String employeeId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      leaveTable,
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'applied_date DESC',
    );
    return maps.map((map) => LeaveApplication.fromMap(map)).toList();
  }

  // ========== LEAVE BALANCES OPERATIONS ==========

  Future<List<LeaveBalance>> getLeaveBalances(String employeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      balanceTable,
      where: 'employee_id = ? AND year = ?',
      whereArgs: [employeeId, DateTime.now().year],
    );
    return maps.map((map) => LeaveBalance.fromMap(map)).toList();
  }

  Future<int> updateLeaveBalance(LeaveBalance balance) async {
    final db = await database;
    return await db.update(
      balanceTable,
      balance.toMap(),
      where: 'employee_id = ? AND leave_type = ? AND year = ?',
      whereArgs: [
        balance.employeeId,
        balance.leaveType.toString().split('.').last,
        balance.year,
      ],
    );
  }

  Future<int> insertLeaveBalance(LeaveBalance balance) async {
    final db = await database;
    return await db.insert(balanceTable, balance.toMap());
  }

  // ========== STATISTICS OPERATIONS ==========

  Future<LeaveStats> getLeaveStats() async {
    final currentMonthApps = await getCurrentMonthApplications();

    final total = currentMonthApps.length;
    final pending = currentMonthApps.where((app) => app.isPending).length;
    final approved = currentMonthApps.where((app) => app.isApproved).length;
    final rejected = currentMonthApps.where((app) => app.isRejected).length;

    return LeaveStats(
      totalRequests: total,
      pendingRequests: pending,
      approvedRequests: approved,
      rejectedRequests: rejected,
      currentMonthRequests: total,
    );
  }

  Future<Map<String, int>> getEmployeeLeaveStats(String employeeId) async {
    final db = await database;

    final total =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $leaveTable WHERE employee_id = ?',
            [employeeId],
          ),
        ) ??
        0;

    final pending =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $leaveTable WHERE employee_id = ? AND status = "pending"',
            [employeeId],
          ),
        ) ??
        0;

    final approved =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $leaveTable WHERE employee_id = ? AND status = "approved"',
            [employeeId],
          ),
        ) ??
        0;

    final rejected =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $leaveTable WHERE employee_id = ? AND status = "rejected"',
            [employeeId],
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

  // ========== EXPORT OPERATIONS ==========

  Future<List<Map<String, dynamic>>> getExportData(LeaveFilter filter) async {
    final List<LeaveApplication> applications;

    switch (filter) {
      case LeaveFilter.pending:
        applications = await getLeaveApplicationsByStatus(LeaveStatus.pending);
        break;
      case LeaveFilter.approved:
        applications = await getLeaveApplicationsByStatus(LeaveStatus.approved);
        break;
      case LeaveFilter.rejected:
        applications = await getLeaveApplicationsByStatus(LeaveStatus.rejected);
        break;
      case LeaveFilter.query:
        applications = await getLeaveApplicationsByStatus(LeaveStatus.query);
        break;
      case LeaveFilter.all:
      default:
        applications = await getAllLeaveApplications();
    }

    return applications.map((app) {
      return {
        'Employee ID': app.employeeId,
        'Employee Name': app.employeeName,
        'Role': app.employeeRole,
        'Email': app.employeeEmail,
        'Phone': app.employeePhone,
        'Project': app.projectName,
        'Leave Type': app.leaveTypeString,
        'Start Date':
            '${app.startDate.day}/${app.startDate.month}/${app.startDate.year}',
        'End Date':
            '${app.endDate.day}/${app.endDate.month}/${app.endDate.year}',
        'Total Days': app.totalDays,
        'Status': app.statusString,
        'Applied Date': app.appliedDateTime,
        'Contact Number': app.contactNumber,
        'Handover Person': app.handoverPersonName,
        'Handover Email': app.handoverPersonEmail,
        'Handover Phone': app.handoverPersonPhone,
        'Reason': app.reason,
        if (app.managerRemarks != null) 'Manager Remarks': app.managerRemarks!,
        if (app.approvedBy != null) 'Approved By': app.approvedBy!,
        if (app.approvedDate != null)
          'Approved Date':
              '${app.approvedDate!.day}/${app.approvedDate!.month}/${app.approvedDate!.year}',
      };
    }).toList();
  }

  // ========== UTILITY OPERATIONS ==========

  Future<int> deleteOldApplications(int daysOld) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    return await db.delete(
      leaveTable,
      where: 'applied_date < ? AND status != "pending"',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  Future<int> getApplicationCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $leaveTable'),
        ) ??
        0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
