  import 'attendance_status.dart';
import 'geofence_model.dart';

  class AttendanceModel {
    final String id;
    final String? userId;
    final DateTime timestamp;
    final AttendanceType type;
    final GeofenceModel? geofence;
    final double latitude;
    final double longitude;
    final String projectName;
    final String? notes; // Add this
    final AttendanceStatus? status; // Add this

    AttendanceModel({
      required this.id,
      required this.timestamp,
      required this.type,
      this.geofence,
      required this.latitude,
      required this.longitude,
      required this.userId,
      this.projectName = 'Default Project',
      this.notes,
      this.status,
    });

    Map<String, dynamic> toJson() => {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'geofence': geofence?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'status': status?.toString(),
    };

    factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: AttendanceType.values.firstWhere(
              (e) => e.toString() == json['type']
      ),
      geofence: json['geofence'] != null
          ? GeofenceModel.fromJson(json['geofence'])
          : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      userId:json['userid'],
      notes: json['notes'],
      status: json['status'] != null
          ? AttendanceStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
      )
          : null,
    );

    String get date => "${timestamp.toLocal()}";
    // Add inside AttendanceModel class

    bool get isLate {
      if (type == AttendanceType.enter || type == AttendanceType.checkIn) {
        final hour = timestamp.hour;
        final minute = timestamp.minute;
        return hour > 9 || (hour == 9 && minute > 15); // Late if after 9:15 AM
      }
      return false;
    }

    bool get isHalfDay {
      // Logic: if checkout before 2 PM or total hours < 4
      return false; // Implement based on your rules
    }

    Duration? getDuration(AttendanceModel? checkout) {
      if (checkout != null &&
          (type == AttendanceType.enter || type == AttendanceType.checkIn) &&
          (checkout.type == AttendanceType.exit || checkout.type == AttendanceType.checkOut)) {
        return checkout.timestamp.difference(timestamp);
      }
      return null;
    }
  }

  enum AttendanceType { checkIn, checkOut, enter, exit }