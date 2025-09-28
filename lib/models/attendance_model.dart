  import 'geofence_model.dart';

  class AttendanceModel {
    final String id;
    final String userId;
    final DateTime timestamp;
    final AttendanceType type;
    final GeofenceModel? geofence;
    final double latitude;
    final double longitude;

    AttendanceModel({
      required this.id,
      required this.timestamp,
      required this.type,
      this.geofence,
      required this.latitude,
      required this.longitude,
      required this.userId,
    });

    Map<String, dynamic> toJson() => {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'geofence': geofence?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
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
    );

    String get date => "${timestamp.toLocal()}";
    String get status => type.toString().split('.').last;
  }

  enum AttendanceType { checkIn, checkOut, enter, exit }