import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/leave_model.dart';

class LeaveProvider extends ChangeNotifier {
  // Form controllers
  final TextEditingController notesController = TextEditingController();

  // Form state
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _toTime = const TimeOfDay(hour: 17, minute: 0);
  String _selectedLeaveType = 'Casual Leave';
  bool _isHalfDayFrom = false;
  bool _isHalfDayTo = false;
  bool _isLoading = false;

  // Filter and search state
  String _filterStatus = 'All';
  String _searchQuery = '';
  bool _showAllLeaves = false;

  // Leave data
  List<Map<String, dynamic>> _appliedLeaves = [];

  final Map<String, dynamic> _leaveBalance = {
    'Carry Forward': {'count': 3, 'color': const Color(0xFF4CAF50)},
    'Eligible': {'count': 6, 'color': const Color(0xFF2196F3)},
    'Availed': {'count': 2, 'color': const Color(0xFFF44336)},
    'Balance': {'count': 4, 'color': const Color(0xFFFFEB3B)},
  };

  final List<String> _leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Annual Leave',
    'Emergency Leave',
    'Maternity Leave',
    'Paternity Leave',
  ];

  // =================== LEAVE TYPE PIE CHART DATA =====================
  Map<String, int> get leaveTypeCount {
    final Map<String, int> counts = {
      "Casual Leave": 0,
      "Sick Leave": 0,
      "Annual Leave": 0,
      "Emergency Leave": 0,
      "Maternity Leave": 0,
      "Paternity Leave": 0,
    };

    for (var leave in allLeaves) {
      String type = leave['type'];
      int days = leave['days'];

      if (counts.containsKey(type)) {
        counts[type] = counts[type]! + days;
      }
    }

    return counts;
  }


  final List<String> _statusFilters = ['All', 'Pending', 'Approved', 'Rejected'];

  // Dummy leave data
  final List<Map<String, dynamic>> _dummyLeaves = [
    {
      'id': '1',
      'type': 'Casual Leave',
      'fromDate': DateTime(2025, 10, 15),
      'toDate': DateTime(2025, 10, 16),
      'days': 2,
      'status': 'Approved',
      'reason': 'Family function',
      'appliedOn': DateTime(2025, 10, 1),
    },
    {
      'id': '2',
      'type': 'Sick Leave',
      'fromDate': DateTime(2025, 11, 5),
      'toDate': DateTime(2025, 11, 5),
      'days': 1,
      'status': 'Pending',
      'reason': 'Medical checkup',
      'appliedOn': DateTime(2025, 10, 20),
    },
    {
      'id': '3',
      'type': 'Annual Leave',
      'fromDate': DateTime(2025, 12, 20),
      'toDate': DateTime(2025, 12, 25),
      'days': 5,
      'status': 'Pending',
      'reason': 'Year end vacation',
      'appliedOn': DateTime(2025, 10, 5),
    },
    {
      'id': '4',
      'type': 'Casual Leave',
      'fromDate': DateTime(2025, 9, 10),
      'toDate': DateTime(2025, 9, 10),
      'days': 1,
      'status': 'Rejected',
      'reason': 'Personal work',
      'appliedOn': DateTime(2025, 9, 1),
    },
    {
      'id': '5',
      'type': 'Emergency Leave',
      'fromDate': DateTime(2025, 11, 20),
      'toDate': DateTime(2025, 11, 21),
      'days': 2,
      'status': 'Pending',
      'reason': 'Family emergency',
      'appliedOn': DateTime(2025, 10, 3),
    },
  ];

  // Getters
  DateTime get fromDate => _fromDate;
  DateTime get toDate => _toDate;
  TimeOfDay get fromTime => _fromTime;
  TimeOfDay get toTime => _toTime;
  String get selectedLeaveType => _selectedLeaveType;
  bool get isHalfDayFrom => _isHalfDayFrom;
  bool get isHalfDayTo => _isHalfDayTo;
  bool get isLoading => _isLoading;
  String get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;
  bool get showAllLeaves => _showAllLeaves;
  List<Map<String, dynamic>> get appliedLeaves => _appliedLeaves;
  Map<String, dynamic> get leaveBalance => _leaveBalance;
  List<String> get leaveTypes => _leaveTypes;
  List<String> get statusFilters => _statusFilters;

  // Get all leaves (dummy + applied)
  List<Map<String, dynamic>> get allLeaves {
    return [..._appliedLeaves, ..._dummyLeaves];
  }

  // Get filtered leaves
  List<Map<String, dynamic>> get filteredLeaves {
    return allLeaves.where((leave) {
      if (_filterStatus != 'All' && leave['status'] != _filterStatus) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesType = leave['type'].toString().toLowerCase().contains(query);
        final matchesReason = leave['reason'].toString().toLowerCase().contains(query);
        return matchesType || matchesReason;
      }

      return true;
    }).toList()..sort((a, b) => b['appliedOn'].compareTo(a['appliedOn']));
  }




  bool canCancelPartialLeave(Map<String, dynamic> leave) {
    final now = DateTime.now();
    final fromDate = leave['fromDate'] as DateTime;
    final toDate = leave['toDate'] as DateTime;

    final normalizedNow = DateTime(now.year, now.month, now.day);

    // From date is today or in the past
    final isFromDatePastOrToday =
        fromDate.isBefore(normalizedNow) ||
            fromDate.isAtSameMomentAs(normalizedNow);

    // To date is in the future
    final isTodateInFuture = toDate.isAfter(normalizedNow);

    return isFromDatePastOrToday && isTodateInFuture;
  }

  int getRemainingLeaveDays(Map<String, dynamic> leave) {
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);

    if (leave['toDate'].isBefore(normalizedNow)) {
      return 0;
    }

    // Calculate remaining days from tomorrow onwards
    final nextDay = normalizedNow.add(const Duration(days: 1));
    final remaining = leave['toDate'].difference(nextDay).inDays + 1;

    return remaining > 0 ? remaining : 0;
  }

  // Get display leaves (with show all/less logic)
  List<Map<String, dynamic>> get displayLeaves {
    return _showAllLeaves
        ? filteredLeaves
        : (filteredLeaves.length > 2 ? filteredLeaves.sublist(0, 2) : filteredLeaves);
  }

  // Calculate total days
  int get totalLeaveDays {
    return allLeaves.fold<int>(0, (sum, leave) => sum + (leave['days'] as int));
  }

  bool isFormPrefilled() {
    // Check if form has been filled with data from editing
    return notesController.text.isNotEmpty &&
        selectedLeaveType.isNotEmpty;
  }

  // Setters
  void setFromDate(DateTime date) {
    _fromDate = date;
    if (_toDate.isBefore(_fromDate)) {
      _toDate = _fromDate;
    }
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    notifyListeners();
  }

  void setFromTime(TimeOfDay time) {
    _fromTime = time;
    notifyListeners();
  }

  void setToTime(TimeOfDay time) {
    _toTime = time;
    notifyListeners();
  }

  void setSelectedLeaveType(String type) {
    _selectedLeaveType = type;
    notifyListeners();
  }

  void setIsHalfDayFrom(bool value) {
    _isHalfDayFrom = value;
    notifyListeners();
  }

  void setIsHalfDayTo(bool value) {
    _isHalfDayTo = value;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowAllLeaves() {
    _showAllLeaves = !_showAllLeaves;
    notifyListeners();
  }

  void setShowAllLeaves(bool value) {
    _showAllLeaves = value;
    notifyListeners();
  }

  // Submit leave
  Future<void> submitLeave() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final leave = LeaveModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      fromDate: _fromDate,
      toDate: _toDate,
      fromTime: _fromTime,
      toTime: _toTime,
      leaveType: _selectedLeaveType,
      notes: notesController.text,
      isHalfDayFrom: _isHalfDayFrom,
      isHalfDayTo: _isHalfDayTo,
      appliedDate: DateTime.now(),
    );

    _appliedLeaves.insert(0, {
      'id': leave.id,
      'type': leave.leaveType,
      'fromDate': leave.fromDate,
      'toDate': leave.toDate,
      'days': leave.toDate.difference(leave.fromDate).inDays + 1,
      'status': 'Pending',
      'reason': leave.notes,
      'appliedOn': leave.appliedDate,
    });

    _isLoading = false;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    notesController.clear();
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    _fromTime = const TimeOfDay(hour: 9, minute: 30);
    _toTime = const TimeOfDay(hour: 17, minute: 0);
    _selectedLeaveType = 'Casual Leave';
    _isHalfDayFrom = false;
    _isHalfDayTo = false;
    notifyListeners();
  }

  // Update leave
  void updateLeave(String leaveId, {
    DateTime? fromDate,
    DateTime? toDate,
    String? reason,
  }) {
    final index = _appliedLeaves.indexWhere((l) => l['id'] == leaveId);
    if (index != -1) {
      if (fromDate != null) {
        _appliedLeaves[index]['fromDate'] = fromDate;
      }
      if (toDate != null) {
        _appliedLeaves[index]['toDate'] = toDate;
      }
      if (reason != null) {
        _appliedLeaves[index]['reason'] = reason;
      }

      // Recalculate days
      final from = _appliedLeaves[index]['fromDate'] as DateTime;
      final to = _appliedLeaves[index]['toDate'] as DateTime;
      _appliedLeaves[index]['days'] = to.difference(from).inDays + 1;

      notifyListeners();
    }
  }

  // Pre-fill form for editing
  void prefillFormForEdit(Map<String, dynamic> leave) {
    _fromDate = leave['fromDate'];
    _toDate = leave['toDate'];
    _selectedLeaveType = leave['type'];
    notesController.text = leave['reason'];
    notifyListeners();
  }

  void cancelLeave(String leaveId, {bool isPartialCancel = false}) {
    final index = _appliedLeaves.indexWhere((leave) => leave['id'] == leaveId);

    if (index != -1) {
      if (isPartialCancel) {
        // For partial cancellation, update the toDate to today
        _appliedLeaves[index]['toDate'] = DateTime.now();
        final from = _appliedLeaves[index]['fromDate'] as DateTime;
        final to = _appliedLeaves[index]['toDate'] as DateTime;
        _appliedLeaves[index]['days'] = to.difference(from).inDays + 1;
      } else {
        // Full cancellation - remove the leave
        _appliedLeaves.removeAt(index);
      }
    }
    notifyListeners();
  }

  void calculateDayType() {
    final from = DateTime(2025, 1, 1, fromTime.hour, fromTime.minute);
    final to = DateTime(2025, 1, 1, toTime.hour, toTime.minute);

    final difference = to.difference(from).inHours;

    if (difference >= 8) {
      // FULL DAY
      setIsHalfDayFrom(false);
      setIsHalfDayTo(false);
    }
    else if (difference >= 4) {
      // HALF DAY (FIRST HALF)
      setIsHalfDayFrom(true);
      setIsHalfDayTo(false);
    }
    else {
      // HALF DAY (SECOND HALF)
      setIsHalfDayFrom(false);
      setIsHalfDayTo(true);
    }
  }


  void updateLeaveDay(String leaveId, DateTime date, bool isHalfDay) {
    // Update specific day in the leave record
    // This persists to your backend
  }

  // Validate if days can be decreased for approved leave
  bool canDecreaseApprovedLeaveDays(int originalDays, int newDays) {
    return newDays < originalDays;
  }
  bool canEditOrDeleteLeave(Map<String, dynamic> leave) {
    final now = DateTime.now();
    final fromDate = leave['fromDate'] as DateTime;

    // Both dates must be in the future (excluding today)
    return fromDate.isAfter(DateTime(now.year, now.month, now.day));
  }
  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}