import 'dart:ui';

class AttendanceRecord {
  final int? id;
  final String userId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? location;
  final String status;
  final DateTime date; // Add date field for filtering
  final Duration? workingHours; // Add working hours
  final String? notes; // Add notes for remarks

  AttendanceRecord({
    this.id,
    required this.userId,
    required this.checkIn,
    this.checkOut,
    this.location,
    required this.status,
    DateTime? date, // Make optional with default
    this.workingHours,
    this.notes,
  }) : date = date ?? checkIn; // Default to checkIn date if not provided

  // Calculate working hours if not provided
  Duration get calculatedWorkingHours {
    if (workingHours != null) return workingHours!;
    if (checkOut == null) return Duration.zero;
    return checkOut!.difference(checkIn);
  }

  // Get only date part (without time)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'location': location,
      'status': status,
      'date': date.toIso8601String(), // Add date to map
      'working_hours': workingHours?.inMinutes, // Store as minutes
      'notes': notes,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      userId: map['user_id'],
      checkIn: DateTime.parse(map['check_in']),
      checkOut: map['check_out'] != null
          ? DateTime.parse(map['check_out'])
          : null,
      location: map['location'],
      status: map['status'],
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.parse(map['check_in']),
      workingHours: map['working_hours'] != null
          ? Duration(minutes: map['working_hours'])
          : null,
      notes: map['notes'],
    );
  }

  // Helper method to create a copy with updated fields
  AttendanceRecord copyWith({
    int? id,
    String? userId,
    DateTime? checkIn,
    DateTime? checkOut,
    String? location,
    String? status,
    DateTime? date,
    Duration? workingHours,
    String? notes,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      location: location ?? this.location,
      status: status ?? this.status,
      date: date ?? this.date,
      workingHours: workingHours ?? this.workingHours,
      notes: notes ?? this.notes,
    );
  }

  // Helper to check if attendance is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Helper to get status color
  Color get statusColor {
    switch (status) {
      case 'present':
        return const Color(0xFF4CAF50); // Green
      case 'absent':
        return const Color(0xFFF44336); // Red
      case 'late':
        return const Color(0xFFFF9800); // Orange
      case 'half-day':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Helper to get display text for status
  String get statusDisplayText {
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      case 'half-day':
        return 'Half Day';
      default:
        return 'Unknown';
    }
  }
}

// class AttendanceRecord {
//   final int? id;
//   final String userId;
//   final DateTime checkIn;
//   final DateTime? checkOut;
//   final String? location;
//   final String status;

//   AttendanceRecord({
//     this.id,
//     required this.userId,
//     required this.checkIn,
//     this.checkOut,
//     this.location,
//     required this.status,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'check_in': checkIn.toIso8601String(),
//       'check_out': checkOut?.toIso8601String(),
//       'location': location,
//       'status': status,
//     };
//   }

//   factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
//     return AttendanceRecord(
//       id: map['id'],
//       userId: map['user_id'],
//       checkIn: DateTime.parse(map['check_in']),
//       checkOut: map['check_out'] != null
//           ? DateTime.parse(map['check_out'])
//           : null,
//       location: map['location'],
//       status: map['status'],
//     );
//   }
// }
