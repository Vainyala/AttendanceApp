import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../models/geofence_model.dart';
import '../services/storage_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<AttendanceModel> _allAttendance = [];
  List<AttendanceModel> _filteredAttendance = [];
  bool _isLoading = true;
  DateTime? _selectedDate;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Enter', 'Exit', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() => _isLoading = true);

    try {
      final attendance = await StorageService.getAttendanceHistory();
      setState(() {
        _allAttendance = attendance..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _filteredAttendance = _allAttendance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading attendance history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();

      switch (filter) {
        case 'All':
          _filteredAttendance = _allAttendance;
          break;
        case 'Enter':
          _filteredAttendance = _allAttendance
              .where((record) => record.type == AttendanceType.enter)
              .toList();
          break;
        case 'Exit':
          _filteredAttendance = _allAttendance
              .where((record) => record.type == AttendanceType.exit)
              .toList();
          break;
        case 'Today':
          _filteredAttendance = _allAttendance.where((record) {
            return record.timestamp.year == now.year &&
                record.timestamp.month == now.month &&
                record.timestamp.day == now.day;
          }).toList();
          break;
        case 'This Week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          _filteredAttendance = _allAttendance.where((record) {
            return record.timestamp.isAfter(weekStart.subtract(const Duration(days: 1)));
          }).toList();
          break;
        case 'This Month':
          _filteredAttendance = _allAttendance.where((record) {
            return record.timestamp.year == now.year &&
                record.timestamp.month == now.month;
          }).toList();
          break;
      }
    });
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A5AE8),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedFilter = 'Custom Date';
        _filteredAttendance = _allAttendance.where((record) {
          return record.timestamp.year == picked.year &&
              record.timestamp.month == picked.month &&
              record.timestamp.day == picked.day;
        }).toList();
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Widget _buildStatsCard() {
    final totalRecords = _filteredAttendance.length;
    final enterRecords = _filteredAttendance.where((r) => r.type == AttendanceType.enter).length;
    final exitRecords = _filteredAttendance.where((r) => r.type == AttendanceType.exit).length;

    // Calculate total time spent (simplified)
    Duration totalTime = Duration.zero;
    AttendanceModel? lastEnter;

    for (var record in _filteredAttendance.reversed) {
      if (record.type == AttendanceType.enter) {
        lastEnter = record;
      } else if (record.type == AttendanceType.exit && lastEnter != null) {
        totalTime += record.timestamp.difference(lastEnter.timestamp);
        lastEnter = null;
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF4A5AE8), Color(0xFF6B73FF)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Attendance Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalRecords.toString(), Icons.list),
                _buildStatItem('Entries', enterRecords.toString(), Icons.login),
                _buildStatItem('Exits', exitRecords.toString(), Icons.logout),
              ],
            ),
            if (totalTime.inMinutes > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total Time: ${_formatDuration(totalTime)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(AttendanceModel record) {
    final isEnter = record.type == AttendanceType.enter;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnter ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isEnter ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              isEnter ? Icons.login : Icons.logout,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: Text(
            '${isEnter ? 'ENTERED' : 'EXITED'} ${record.geofence?.name ?? 'Unknown Location'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(record.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              if (record.geofence != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Type: ${record.geofence!.type.toString().split('.').last.toUpperCase()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEnter ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              DateFormat('HH:mm').format(record.timestamp),
              style: TextStyle(
                color: isEnter ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: const Color(0xFF4A5AE8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _applyFilter,
            itemBuilder: (context) => _filterOptions.map((filter) {
              return PopupMenuItem<String>(
                value: filter,
                child: Row(
                  children: [
                    Icon(
                      _selectedFilter == filter ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: _selectedFilter == filter ? const Color(0xFF4A5AE8) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(filter),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAttendanceHistory,
        color: const Color(0xFF4A5AE8),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4A5AE8),
          ),
        )
            : Column(
          children: [
            // Filter Status
            if (_selectedFilter != 'All' || _selectedDate != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A5AE8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4A5AE8).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: const Color(0xFF4A5AE8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? 'Filtered by: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'
                            : 'Filtered by: $_selectedFilter',
                        style: const TextStyle(
                          color: Color(0xFF4A5AE8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF4A5AE8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'All';
                          _selectedDate = null;
                          _filteredAttendance = _allAttendance;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Stats Card
            if (_filteredAttendance.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatsCard(),
              ),
              const SizedBox(height: 16),
            ],

            // Attendance List
            Expanded(
              child: _filteredAttendance.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _selectedFilter == 'All'
                          ? 'No Attendance Records'
                          : 'No Records Found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFilter == 'All'
                          ? 'Your attendance history will appear here'
                          : 'Try changing the filter or date',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredAttendance.length,
                itemBuilder: (context, index) {
                  return _buildAttendanceCard(_filteredAttendance[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}