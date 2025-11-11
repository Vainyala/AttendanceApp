import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/attendance_model.dart';
import '../models/analytics_data.dart';
import '../providers/dashboard_provider.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class AttendanceDetailedScreen extends StatefulWidget {
  final DateRange dateRange;
  final String? projectId;

  const AttendanceDetailedScreen({
    super.key,
    required this.dateRange,
    this.projectId,
  });

  @override
  State<AttendanceDetailedScreen> createState() => _AttendanceDetailedScreenState();
}

class _AttendanceDetailedScreenState extends State<AttendanceDetailedScreen> {
  List<AttendanceModel> _records = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _loading = true);

    final provider = context.read<AppProvider>();
    final userId = provider.user?.id ?? '';

    // Get all records in range
    final allAttendance = await StorageService.getAttendanceHistory();

    _records = allAttendance.where((record) {
      final matchesDate = record.timestamp.isAfter(widget.dateRange.start) &&
          record.timestamp.isBefore(widget.dateRange.end);
      final matchesUser = record.userId == userId;
      final matchesProject = widget.projectId == null ||
          record.projectName == widget.projectId;

      return matchesDate && matchesUser && matchesProject;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Latest first

    setState(() => _loading = false);
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ['Date', 'Project', 'In Time', 'Out Time', 'Status', 'Hours', 'Location']
    ];

    // Group by date
    Map<String, List<AttendanceModel>> byDate = {};
    for (var record in _records) {
      final dateKey = '${record.timestamp.year}-${record.timestamp.month.toString().padLeft(2, '0')}-${record.timestamp.day.toString().padLeft(2, '0')}';
      byDate.putIfAbsent(dateKey, () => []).add(record);
    }

    byDate.forEach((date, records) {
      records.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final checkIn = records.firstWhere(
            (r) => r.type == AttendanceType.enter || r.type == AttendanceType.checkIn,
        orElse: () => records.first,
      );

      final checkOut = records.lastWhere(
            (r) => r.type == AttendanceType.exit || r.type == AttendanceType.checkOut,
        orElse: () => records.last,
      );

      final duration = checkIn.getDuration(checkOut);
      final hours = duration != null ? (duration.inMinutes / 60.0).toStringAsFixed(2) : 'N/A';

      rows.add([
        date,
        checkIn.projectName,
        '${checkIn.timestamp.hour}:${checkIn.timestamp.minute.toString().padLeft(2, '0')}',
        checkOut != checkIn ? '${checkOut.timestamp.hour}:${checkOut.timestamp.minute.toString().padLeft(2, '0')}' : 'N/A',
        checkIn.status?.toString().split('.').last ?? 'present',
        hours,
        checkIn.geofence?.name ?? 'N/A',
      ]);
    });

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Attendance Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Attendance'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportCSV,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? Center(child: Text('No records found'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Project')),
              DataColumn(label: Text('In Time')),
              DataColumn(label: Text('Out Time')),
              DataColumn(label: Text('Hours')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Location')),
            ],
            rows: _buildRows(),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    // Group by date
    Map<String, List<AttendanceModel>> byDate = {};
    for (var record in _records) {
      final dateKey = '${record.timestamp.year}-${record.timestamp.month.toString().padLeft(2, '0')}-${record.timestamp.day.toString().padLeft(2, '0')}';
      byDate.putIfAbsent(dateKey, () => []).add(record);
    }

    List<DataRow> rows = [];

    byDate.forEach((date, records) {
      records.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final checkIn = records.firstWhere(
            (r) => r.type == AttendanceType.enter || r.type == AttendanceType.checkIn,
        orElse: () => records.first,
      );

      final checkOut = records.lastWhere(
            (r) => r.type == AttendanceType.exit || r.type == AttendanceType.checkOut,
        orElse: () => records.last,
      );

      final duration = checkIn.getDuration(checkOut);
      final hours = duration != null ? (duration.inMinutes / 60.0).toStringAsFixed(2) : 'N/A';

      rows.add(DataRow(cells: [
        DataCell(Text(date)),
        DataCell(Text(checkIn.projectName)),
        DataCell(Text('${checkIn.timestamp.hour}:${checkIn.timestamp.minute.toString().padLeft(2, '0')}')),
        DataCell(Text(checkOut != checkIn ? '${checkOut.timestamp.hour}:${checkOut.timestamp.minute.toString().padLeft(2, '0')}' : 'N/A')),
        DataCell(Text(hours)),
        DataCell(Text(
          checkIn.isLate ? 'Late' : (checkIn.status?.toString().split('.').last ?? 'Present'),
          style: TextStyle(color: checkIn.isLate ? Colors.red : Colors.green),
        )),
        DataCell(Text(checkIn.geofence?.name ?? 'N/A')),
      ]));
    });

    return rows;
  }
}