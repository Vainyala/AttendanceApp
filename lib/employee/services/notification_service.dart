import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Callback for notification tap
  static Function(String?)? onNotificationTap;

  static Future<void> initialize() async {
    if (_initialized) return;

    await Permission.notification.request();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (onNotificationTap != null) {
          onNotificationTap!(response.payload);
        }
      },
    );

    _initialized = true;
  }

  // Store notification timestamps for 5-minute expiry check
  static final Map<String, DateTime> _notificationTimestamps = {};

  static Future<void> showGeofenceNotification({
    required String title,
    required String body,
    required bool isEntering,
    String? payload,
  }) async {
    await initialize();

    // Store timestamp for this notification
    if (payload != null) {
      _notificationTimestamps[payload] = DateTime.now();
    }

    final androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      channelDescription: 'Notifications for geofence enter/exit events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: isEntering ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> showOutOfRangeNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'out_of_range_channel',
      'Out of Range Notifications',
      channelDescription: 'Notifications when employee goes out of range',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFF44336),
      playSound: true,
      enableVibration: true,
      ongoing: true, // Make it persistent
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> showAttendanceNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'attendance_channel',
      'Attendance Notifications',
      channelDescription: 'Notifications for attendance tracking',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4A5AE8),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  // Check if notification is still valid (within 5 minutes)
  static bool isNotificationValid(String payload) {
    if (!_notificationTimestamps.containsKey(payload)) {
      return false;
    }

    final timestamp = _notificationTimestamps[payload]!;
    final difference = DateTime.now().difference(timestamp);

    return difference.inMinutes < 5;
  }

  // Clear expired notifications
  static void clearExpiredNotifications() {
    final now = DateTime.now();
    _notificationTimestamps.removeWhere((key, timestamp) {
      return now.difference(timestamp).inMinutes >= 5;
    });
  }

  // Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    _notificationTimestamps.clear();
  }
}