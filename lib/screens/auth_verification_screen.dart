import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

enum VerificationType {
  faceBlinking,
  fingerprint,
}

enum VerificationReason {
  checkIn,           // Initial check-in
  goingOut,          // Going out, not returning
  goingOutReturning, // Going out, will return
  returning,         // Coming back after going out
  checkOut,          // End of day checkout
}

class AuthVerificationScreen extends StatefulWidget {
  final VerificationReason reason;
  final Function(VerificationType) onVerificationSuccess;
  final bool allowFingerprint;
  final bool isNotificationExpired;

  const AuthVerificationScreen({
    Key? key,
    required this.reason,
    required this.onVerificationSuccess,
    this.allowFingerprint = false,
    this.isNotificationExpired = false,
  }) : super(key: key);

  @override
  State<AuthVerificationScreen> createState() => _AuthVerificationScreenState();
}

class _AuthVerificationScreenState extends State<AuthVerificationScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();

    // Show expiry message if notification expired
    if (widget.isNotificationExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showExpiryMessage();
      });
    }
  }

  void _showExpiryMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Notification Expired'),
          ],
        ),
        content: Text(
          'This notification has expired (5 minutes limit). Check-in is disabled for this instance.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close auth screen
            },
            child: Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.reason) {
      case VerificationReason.checkIn:
        return 'Check-In Verification';
      case VerificationReason.goingOut:
      case VerificationReason.goingOutReturning:
        return 'Going Out Verification';
      case VerificationReason.returning:
        return 'Return Verification';
      case VerificationReason.checkOut:
        return 'Check-Out Verification';
    }
  }

  String _getDescription() {
    switch (widget.reason) {
      case VerificationReason.checkIn:
        return 'Complete face verification to check in';
      case VerificationReason.goingOut:
        return 'Choose verification method';
      case VerificationReason.goingOutReturning:
        return 'Choose verification method';
      case VerificationReason.returning:
        return 'Verify to mark your return';
      case VerificationReason.checkOut:
        return 'Complete face verification to check out';
    }
  }

  Future<void> _handleFaceVerification() async {
    Navigator.pop(context); // Close this screen

    // Navigate to face detection screen
    // You'll need to import your FaceDetectionScreen
    // For now, simulating navigation with callback
    widget.onVerificationSuccess(VerificationType.faceBlinking);
  }

  Future<void> _handleFingerprintVerification() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canAuthenticate || !isDeviceSupported) {
        _showError('Fingerprint authentication is not available on this device');
        setState(() => _isAuthenticating = false);
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity with fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        widget.onVerificationSuccess(VerificationType.fingerprint);
        Navigator.pop(context);
      } else {
        _showError('Fingerprint verification failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If notification expired, show nothing (dialog handles it)
    if (widget.isNotificationExpired) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: Container(), // Empty, dialog will show
      );
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 30),
              Text(
                _getTitle(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                _getDescription(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),

              // Face Authentication Button
              _buildVerificationButton(
                icon: Icons.face,
                title: 'Face Verification',
                subtitle: _getFaceSubtitle(),
                color: Colors.blue,
                onTap: _handleFaceVerification,
              ),

              if (widget.allowFingerprint) ...[
                SizedBox(height: 20),
                Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Fingerprint Authentication Button
                _buildVerificationButton(
                  icon: Icons.fingerprint,
                  title: 'Fingerprint Verification',
                  subtitle: _getFingerprintSubtitle(),
                  color: Colors.green,
                  onTap: _isAuthenticating ? null : _handleFingerprintVerification,
                  loading: _isAuthenticating,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getFaceSubtitle() {
    if (widget.reason == VerificationReason.goingOut ||
        widget.reason == VerificationReason.goingOutReturning) {
      return 'Going out, not returning today';
    }
    return 'Complete 3 eye blinks';
  }

  String _getFingerprintSubtitle() {
    return 'Going out, will return later';
  }

  Widget _buildVerificationButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey : color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: loading
            ? Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : Column(
          children: [
            Icon(icon, size: 60, color: Colors.white),
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}