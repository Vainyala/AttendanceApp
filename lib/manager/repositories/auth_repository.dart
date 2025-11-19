import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../services/geofencing_service.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final GeofencingService _geofencingService = GeofencingService();

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🔐 Login attempt for: $email');

      // Debug: Check database state before login
      await _databaseHelper.debugPrintUsers();

      // First check geofencing
      final locationCheck = await _geofencingService.checkAllowedLocation();
      if (!locationCheck['allowed']) {
        print('📍 Location check failed: ${locationCheck['message']}');
        return LoginResponse(success: false, message: locationCheck['message']);
      }

      // Try local database only
      final user = await _databaseHelper.getUserByEmail(email);
      print('👤 User found: ${user != null}');

      if (user != null) {
        final hashedInputPassword = _hashPassword(password);
        print('🔑 Stored password (hashed): ${user.password}');
        print('🔑 Input password (hashed): $hashedInputPassword');
        print('🔑 Input password (plain): $password');

        // Compare HASHED passwords
        if (user.password == hashedInputPassword) {
          print('✅ Password match successful - HASHED COMPARISON');
          return LoginResponse(
            success: true,
            message: 'Login successful from ${locationCheck['city']}',
            user: user,
            token: 'local_token_${DateTime.now().millisecondsSinceEpoch}',
            locationData: locationCheck,
          );
        } else {
          print('❌ Password mismatch - HASHED COMPARISON FAILED');
          print(
            '💡 Tip: Uninstall and reinstall app to reset database with proper hashed passwords',
          );

          // Additional debug: Test what the correct hash should be
          final correctHash = _hashPassword(_getExpectedPassword(email));
          print('🔍 Expected hash for $email: $correctHash');
          print('🔍 Actual stored hash: ${user.password}');

          return LoginResponse(
            success: false,
            message: 'Invalid email or password',
          );
        }
      } else {
        print('❌ User not found in database');
        return LoginResponse(
          success: false,
          message: 'Invalid email or password',
        );
      }
    } catch (e) {
      print('💥 Login error: $e');
      return LoginResponse(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  // Helper method to get expected password for debugging
  String _getExpectedPassword(String email) {
    switch (email) {
      case 'employee@nutantek.com':
        return 'employee123';
      case 'manager@nutantek.com':
        return 'manager123';
      case 'hr@nutantek.com':
        return 'hr123';
      case 'finance@nutantek.com':
        return 'finance123';
      default:
        return 'unknown';
    }
  }

  // Additional method to verify database state
  Future<void> verifyDatabaseState() async {
    print('🔍 VERIFYING DATABASE STATE:');
    await _databaseHelper.debugPrintUsers();

    // Test all user logins
    final testUsers = [
      'employee@nutantek.com',
      'manager@nutantek.com',
      'hr@nutantek.com',
      'finance@nutantek.com',
    ];

    for (final email in testUsers) {
      final password = _getExpectedPassword(email);
      final hashedPassword = _hashPassword(password);
      final user = await _databaseHelper.getUserByEmail(email);

      print('🧪 Testing $email:');
      print('   Expected Hash: $hashedPassword');
      print('   Stored Hash: ${user?.password ?? "NOT FOUND"}');
      print('   Match: ${user?.password == hashedPassword}');
      print('   ---');
    }
  }
}

// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import '../database/database_helper.dart';
// import '../models/user_model.dart';
// import '../services/geofencing_service.dart';

// class AuthRepository {
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//   final GeofencingService _geofencingService = GeofencingService();

//   Future<LoginResponse> login(String email, String password) async {
//     try {
//       print('🔐 Login attempt for: $email');

//       // First check geofencing
//       final locationCheck = await _geofencingService.checkAllowedLocation();
//       if (!locationCheck['allowed']) {
//         print('📍 Location check failed: ${locationCheck['message']}');
//         return LoginResponse(success: false, message: locationCheck['message']);
//       }

//       // Try local database only
//       final user = await _databaseHelper.getUserByEmail(email);
//       print('👤 User found: ${user != null}');

//       if (user != null) {
//         print('🔑 Stored password: ${user.password}');
//         print('🔑 Input password: $password');

//         // Compare plain text passwords (since database has plain text)
//         if (user.password == password) {
//           print('✅ Password match successful');
//           return LoginResponse(
//             success: true,
//             message: 'Login successful from ${locationCheck['city']}',
//             user: user,
//             token: 'local_token_${DateTime.now().millisecondsSinceEpoch}',
//             locationData: locationCheck,
//           );
//         } else {
//           print('❌ Password mismatch');
//           return LoginResponse(
//             success: false,
//             message: 'Invalid email or password',
//           );
//         }
//       } else {
//         print('❌ User not found in database');
//         return LoginResponse(
//           success: false,
//           message: 'Invalid email or password',
//         );
//       }
//     } catch (e) {
//       print('💥 Login error: $e');
//       return LoginResponse(
//         success: false,
//         message: 'Login failed: ${e.toString()}',
//       );
//     }
//   }
// }
