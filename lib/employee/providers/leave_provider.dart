import 'package:AttendanceApp/employee/widgets/date_time_utils.dart';
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
      'managerComment': 'Approved. Enjoy your time!'
    },
    {
      'id': '2',
      'type': 'Sick Leave',
      'fromDate': DateTime(2025, 11, 5),
      'toDate': DateTime(2025, 11, 6),
      'days': 1,
      'status': 'Pending',
      'reason': 'Medical checkup',
      'appliedOn': DateTime(2025, 10, 20),
      'managerComment': 'Medical Report have to attach'
    },
    {
      'id': '3',
      'type': 'Annual Leave',
      'fromDate': DateTime(2025, 12, 20),
      'toDate': DateTime(2025, 12, 30),
      'days': 5,
      'status': 'Pending',
      'reason': 'Year end vacation',
      'appliedOn': DateTime(2025, 12, 5),
      'managerComment': 'Not more than 5 days leaves'
    },
    {
      'id': '4',
      'type': 'Casual Leave',
      'fromDate': DateTime(2025, 9, 10),
      'toDate': DateTime(2025, 9, 12),
      'days': 1,
      'status': 'Rejected',
      'reason': 'Personal work',
      'appliedOn': DateTime(2025, 9, 1),
      'managerComment': '....'
    },
    {
      'id': '5',
      'type': 'Emergency Leave',
      'fromDate': DateTime(2025, 11, 20),
      'toDate': DateTime(2025, 11, 25),
      'days': 2,
      'status': 'Approved',
      'reason': 'Family emergency',
      'appliedOn': DateTime(2025, 10, 3),
      'managerComment': 'Okay...'
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


  String get fromDateFormatted => DateFormattingUtils.formatDate(_fromDate);
  String get toDateFormatted   => DateFormattingUtils.formatDate(_toDate);
  String get fromTimeFormatted => '${_fromTime.hour.toString().padLeft(2, '0')}:${_fromTime.minute.toString().padLeft(2, '0')}';
  String get toTimeFormatted => '${_toTime.hour.toString().padLeft(2, '0')}:${_toTime.minute.toString().padLeft(2, '0')}';


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

  Future<void> pickFromDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate.isBefore(today) ? today : _fromDate,
      firstDate: today, // ✅ Only today and future dates
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setFromDate(picked);
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate.isBefore(today) ? today : _toDate,
      firstDate: _fromDate.isBefore(today) ? today : _fromDate, // ✅ Can't be before fromDate or today
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setToDate(picked);
    }
  }
  Future<void> pickFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _fromTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setFromTime(picked);
      calculateDayType();
    }
  }

  Future<void> pickToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _toTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // ✅ Validate time when same date
      if (_fromDate.year == _toDate.year &&
          _fromDate.month == _toDate.month &&
          _fromDate.day == _toDate.day) {

        final fromMinutes = _fromTime.hour * 60 + _fromTime.minute;
        final toMinutes = picked.hour * 60 + picked.minute;

        if (toMinutes <= fromMinutes) {
          // Show error - to time must be after from time
          return;
        }
      }

      setToTime(picked);
      calculateDayType();
    }
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
  // Add manager comments field to leave data
  String? getManagerComment(Map<String, dynamic> leave) {
    return leave['managerComment'] as String?;
  }

// Check if leave has started
  bool hasLeaveStarted(Map<String, dynamic> leave) {
    final now = DateTime.now();
    final fromDate = leave['fromDate'] as DateTime;
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedFrom = DateTime(fromDate.year, fromDate.month, fromDate.day);

    return normalizedFrom.isBefore(normalizedNow) ||
        normalizedFrom.isAtSameMomentAs(normalizedNow);
  }

// Check if leave can be edited (dates changed)
  bool canEditLeave(Map<String, dynamic> leave) {
    if (leave['status'] == 'Rejected') return false;

    final now = DateTime.now();
    final fromDate = leave['fromDate'] as DateTime;
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedFrom = DateTime(fromDate.year, fromDate.month, fromDate.day);

    // Can edit only if leave hasn't started yet
    return normalizedFrom.isAfter(normalizedNow);
  }

// Check if leave can be cancelled
  bool canCancelLeave(Map<String, dynamic> leave) {
    if (leave['status'] == 'Rejected' || leave['status'] == 'Cancelled') {
      return false;
    }

    final now = DateTime.now();
    final toDate = leave['toDate'] as DateTime;
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedTo = DateTime(toDate.year, toDate.month, toDate.day);

    // Calculate remaining days (including today if leave is ongoing)
    final remainingDays = normalizedTo.difference(normalizedNow).inDays;

    // Can cancel if more than 1 day remaining
    return remainingDays > 1;
  }

// Check if leave can be decreased (for ongoing leaves)
  bool canDecreaseLeave(Map<String, dynamic> leave) {
    if (leave['status'] != 'Approved') return false;

    final now = DateTime.now();
    final fromDate = leave['fromDate'] as DateTime;
    final toDate = leave['toDate'] as DateTime;
    final normalizedNow = DateTime(now.year, now.month, now.day);

    // Leave has started but not ended
    final hasStarted = fromDate.isBefore(normalizedNow) ||
        fromDate.isAtSameMomentAs(normalizedNow);
    final notEnded = toDate.isAfter(normalizedNow);

    // Can decrease if remaining days > 1
    if (hasStarted && notEnded) {
      final remainingDays = toDate.difference(normalizedNow).inDays;
      return remainingDays > 1;
    }

    return false;
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}