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
  }

  enum AttendanceType { checkIn, checkOut, enter, exit }