import 'geofence_model.dart';

class AttendanceModel {
  final String id;
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
  );
}

enum AttendanceType { checkIn, checkOut, enter, exit }