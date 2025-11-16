import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:local_auth/local_auth.dart';

enum VerificationType {
  faceBlinking,
  fingerprint,
}

enum VerificationReason {
  checkIn,
  goingOut,
  goingOutReturning,
  returning,
  checkOut,
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

class _AuthVerificationScreenState extends State<AuthVerificationScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();

    if (widget.isNotificationExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showExpiryMessage();
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showExpiryMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_filled,
                  color: AppColors.error.shade600,
                  size: 48,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Session Expired',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHint.shade900,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'This verification session has expired (5 minutes limit). Please request a new check-in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textHint.shade600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.shade600,
                    foregroundColor: AppColors.textLight,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.reason) {
      case VerificationReason.checkIn:
        return 'Check-In';
      case VerificationReason.goingOut:
      case VerificationReason.goingOutReturning:
        return 'Going Out';
      case VerificationReason.returning:
        return 'Welcome Back';
      case VerificationReason.checkOut:
        return 'Check-Out';
    }
  }

  String _getSubtitle() {
    switch (widget.reason) {
      case VerificationReason.checkIn:
        return 'Verify your identity to start your day';
      case VerificationReason.goingOut:
      case VerificationReason.goingOutReturning:
        return 'Choose your verification method';
      case VerificationReason.returning:
        return 'Verify to confirm your return';
      case VerificationReason.checkOut:
        return 'Verify to complete your day';
    }
  }

  IconData _getHeaderIcon() {
    switch (widget.reason) {
      case VerificationReason.checkIn:
        return Icons.login;
      case VerificationReason.goingOut:
      case VerificationReason.goingOutReturning:
        return Icons.exit_to_app;
      case VerificationReason.returning:
        return Icons.home;
      case VerificationReason.checkOut:
        return Icons.logout;
    }
  }

  Color _getHeaderColor() {
    switch (widget.reason) {
      case VerificationReason.checkIn:
        return AppColors.success;
      case VerificationReason.goingOut:
      case VerificationReason.goingOutReturning:
        return Colors.orange;
      case VerificationReason.returning:
        return Colors.blue;
      case VerificationReason.checkOut:
        return Colors.purple;
    }
  }

  Future<void> _handleFaceVerification() async {
    // Add haptic feedback
    await Future.delayed(Duration(milliseconds: 100));

    widget.onVerificationSuccess(VerificationType.faceBlinking);
    Navigator.pop(context);
  }

  Future<void> _handleFingerprintVerification() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canAuthenticate || !isDeviceSupported) {
        _showError('Fingerprint not available on this device');
        setState(() => _isAuthenticating = false);
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        widget.onVerificationSuccess(VerificationType.fingerprint);

        // Show quick success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.textLight),
                SizedBox(width: 12),
                Text('Verified successfully!'),
              ],
            ),
            backgroundColor: AppColors.success.shade600,
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context);
      } else {
        _showError('Verification failed. Please try again.');
      }
    } catch (e) {
      _showError('Authentication error occurred');
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.textLight),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error.shade600,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNotificationExpired) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: Container(),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getHeaderColor().withOpacity(0.8),
              _getHeaderColor().withOpacity(0.9),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.textLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Header Icon
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.textLight.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textLight.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getHeaderIcon(),
                              size: 54,
                              color: AppColors.textLight,
                            ),
                          ),

                          SizedBox(height: 25),

                          // Title
                          Text(
                            _getTitle(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),

                          SizedBox(height: 12),

                          // Subtitle
                          Text(
                            _getSubtitle(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColors.textLight.withOpacity(0.85),
                              height: 1.4,
                            ),
                          ),

                          SizedBox(height: 30),

                          // Face Verification Button
                          _buildVerificationCard(
                            icon: Icons.face_rounded,
                            title: 'Face Verification',
                            subtitle: widget.reason == VerificationReason.goingOut ||
                                widget.reason == VerificationReason.goingOutReturning
                                ? 'Not returning today'
                                : 'Blink 3 times to verify',
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                            ),
                            onTap: _handleFaceVerification,
                          ),

                          if (widget.allowFingerprint) ...[
                            SizedBox(height: 20),

                            // OR Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.textLight.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: AppColors.textLight.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.textLight.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // Fingerprint Verification Button
                            _buildVerificationCard(
                              icon: Icons.fingerprint,
                              title: 'Fingerprint',
                              subtitle: 'Will return later today',
                              gradient: LinearGradient(
                                colors: [AppColors.success.shade400, AppColors.success.shade600],
                              ),
                              onTap: _isAuthenticating ? null : _handleFingerprintVerification,
                              loading: _isAuthenticating,
                            ),
                          ],

                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: onTap == null && !loading ? null : gradient,
          color: onTap == null && !loading ? AppColors.textHint.shade700 : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: onTap == null && !loading
                  ? Colors.black.withOpacity(0.3)
                  : _getHeaderColor().withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: loading
            ? Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.textLight,
              strokeWidth: 3,
            ),
          ),
        )
            : Column(
          children: [
            // Icon
            Icon(
              icon,
              size: 56,
              color: AppColors.textLight,
            ),

            SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),

            SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textLight.withOpacity(0.9),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}