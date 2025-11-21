
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/view_models/button_view_model.dart';
import '../core/view_models/common_view_model.dart';
import '../database/database_helper.dart';
import '../view_models/auth_view_model.dart';
import '../services/geofencing_service.dart';
import '../services/ai_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _obscurePassword = true;
  bool _checkingLocation = false;
  bool _aiAnalyzing = false;
  String _locationStatus = 'Checking security...';
  Color _locationStatusColor = AppColors.warning;
  String? _currentCity;
  double _securityScore = 0.0;
  List<String> _aiInsights = [];

  // AI-Powered Security Metrics
  final AIAuthService _aiAuthService = AIAuthService();
  Map<String, dynamic> _behaviorMetrics = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkInitialLocation();
    _testDatabase();
    _initializeAIAnalytics();
  }

  void _testDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.printAllUsers();
  }

  void _initializeAIAnalytics() {
    _behaviorMetrics = {
      'login_attempts': 0,
      'typical_login_time': DateTime.now(),
      'device_fingerprint': _generateDeviceFingerprint(),
      'network_analysis': _analyzeNetworkSecurity(),
    };
  }

  String _generateDeviceFingerprint() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_aiAuthService.generateDeviceHash()}';
  }

  Map<String, dynamic> _analyzeNetworkSecurity() {
    return {
      'vpn_detected': false,
      'proxy_usage': false,
      'network_trust_score': 0.95,
      'threat_level': 'low',
    };
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  // 🔧 DEBUG METHODS
  void _resetAndTestDatabase() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.resetDatabase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Database Reset Complete'),
        content: Text(
          'All users have been reset with correct passwords.\n\nNow try logging in with:\n\nEmployee: employee1@nutantek.com / employee123\nManager: manager1@nutantek.com / manager123\nHR: hr@nutantek.com / hr123\nFinance: finance@nutantek.com / finance123',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _emergencyLogin(String userType) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final commonState = Provider.of<CommonState>(context, listen: false);

    authViewModel.emergencyLogin(userType);
    commonState.clearError();
    authViewModel.navigateToDashboard(context);

    print('🚀 Emergency login activated for: $userType');
  }

  void _testLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.testAllLogins();
  }

  void _quickLogin(String email, String password) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final commonState = Provider.of<CommonState>(context, listen: false);

    _emailController.text = email;
    _passwordController.text = password;
    commonState.clearError();

    print('🚀 Quick login: $email');
    _handleLogin();
  }

  Future<void> _checkInitialLocation() async {
    final commonState = Provider.of<CommonState>(context, listen: false);

    setState(() {
      _checkingLocation = true;
      _locationStatus = 'Checking location security...';
    });

    try {
      final geofencingService = GeofencingService();
      final locationCheck = await geofencingService.checkAllowedLocation();

      final locationAnalysis = await _aiAuthService.analyzeLocationPattern(
        locationCheck,
        _behaviorMetrics['typical_login_time'],
      );

      setState(() {
        _checkingLocation = false;
        if (locationCheck['allowed'] == true &&
            locationAnalysis['trustworthy']) {
          _locationStatus = '✓ ${locationAnalysis['message']}';
          _locationStatusColor = AppColors.success;
          _currentCity = locationCheck['city'];
          _securityScore =
              (locationAnalysis['security_score'] as double?) ?? 0.0;
          _aiInsights = (locationAnalysis['insights'] as List<String>?) ?? [];
        } else {
          _locationStatus = '✗ ${locationAnalysis['message']}';
          _locationStatusColor = AppColors.error;
          _currentCity = null;
          _securityScore =
              (locationAnalysis['security_score'] as double?) ?? 0.0;
          _aiInsights = (locationAnalysis['insights'] as List<String>?) ?? [];
        }
      });
    } catch (e) {
      setState(() {
        _checkingLocation = false;
        _locationStatus = '✗ Security check failed';
        _locationStatusColor = AppColors.error;
      });
      commonState.setError('Location service error: $e');
    }
  }

  Future<void> _handleLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final buttonState = Provider.of<ButtonState>(context, listen: false);
    final commonState = Provider.of<CommonState>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;

    buttonState.setLoading(true);

    try {
      final success = await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        await _aiAuthService.recordSuccessfulLogin(
          authViewModel.currentUser!,
          _behaviorMetrics,
        );

        commonState.setLoading(false);
        buttonState.setLoading(false);

        _showAIEnhancedSuccessSnackbar(
          context,
          authViewModel.currentUser!.name,
          _getUserRoleDisplay(authViewModel.currentUser!.userType),
          _securityScore,
        );

        authViewModel.navigateToDashboard(context);
      } else if (!success) {
        await _aiAuthService.recordFailedLoginAttempt(
          _emailController.text.trim(),
          _behaviorMetrics,
        );

        commonState.setError(authViewModel.errorMessage);
        buttonState.setLoading(false);
      }
    } catch (e) {
      commonState.setError('Login failed: ${e.toString()}');
      buttonState.setLoading(false);
    } finally {
      setState(() {
        _aiAnalyzing = false;
      });
    }
  }

  // ✅ SINGLE _getUserRoleDisplay METHOD
  String _getUserRoleDisplay(String userType) {
    switch (userType) {
      case 'manager':
        return 'Manager';
      case 'hr':
        return 'HR Manager';
      case 'finance_manager':
        return 'Finance Manager';
      case 'employee':
      default:
        return 'Employee';
    }
  }

  void _showAIEnhancedSuccessSnackbar(
    BuildContext context,
    String userName,
    String userRole,
    double securityScore,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Access Granted, $userName!',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  Text(
                    'Logged in as $userRole • Security Score: ${(securityScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getSecurityColor(securityScore),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Color _getSecurityColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  // Helper methods for debug section
  String _getPasswordForUser(String email) {
    switch (email) {
      case 'employee1@nutantek.com':
      case 'employee2@nutantek.com':
      case 'employee3@nutantek.com':
        return 'employee123';
      case 'manager1@nutantek.com':
      case 'manager2@nutantek.com':
      case 'manager3@nutantek.com':
        return 'manager123';
      case 'hr@nutantek.com':
        return 'hr123';
      case 'finance@nutantek.com':
        return 'finance123';
      default:
        return 'employee123';
    }
  }

  IconData _getUserIcon(String userType) {
    switch (userType) {
      case 'manager':
        return Icons.manage_accounts;
      case 'hr':
        return Icons.people;
      case 'finance_manager':
        return Icons.attach_money;
      case 'employee':
      default:
        return Icons.person;
    }
  }

  Color _getUserColor(String userType) {
    switch (userType) {
      case 'manager':
        return Colors.blue;
      case 'hr':
        return Colors.purple;
      case 'finance_manager':
        return Colors.teal;
      case 'employee':
      default:
        return Colors.green;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final commonState = Provider.of<CommonState>(context);
    final bool isDarkMode = theme.isDarkMode;

    // Safe colors that work in both themes
    final backgroundColor = isDarkMode
        ? Colors.black
        : AppColors.backgroundLight;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final cardColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white;
    final inputFillColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : AppColors.grey50;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : AppColors.grey300;
    final hintColor = isDarkMode
        ? Colors.white.withOpacity(0.5)
        : AppColors.textDisabled;
    final secondaryTextColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? RadialGradient(
                  center: Alignment.topLeft,
                  radius: 2.0,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.secondary.withOpacity(0.1),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.secondary.withOpacity(0.03),
                    AppColors.backgroundLight,
                  ],
                ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildHeader(textColor, secondaryTextColor),
                          const SizedBox(height: 40),
                          _buildLoginCard(
                            cardColor,
                            borderColor,
                            inputFillColor,
                            textColor,
                            hintColor,
                            commonState, // ✅ commonState pass kiya
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 30),
        _buildWelcomeText(textColor, secondaryTextColor),
      ],
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/nutantek_logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business_center_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(Color textColor, Color secondaryTextColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'WELCOME',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enterprise Attendance System',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(
    Color cardColor,
    Color borderColor,
    Color inputFillColor,
    Color textColor,
    Color hintColor,
    CommonState commonState, // ✅ Parameter mein commonState receive kiya
    bool isDarkMode,
  ) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSecurityStatus(),
              const SizedBox(height: 24),
              _buildEmailField(
                inputFillColor,
                textColor,
                hintColor,
                commonState,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                inputFillColor,
                textColor,
                hintColor,
                commonState,
              ),
              const SizedBox(height: 16),
              _buildActionRow(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              if (commonState.hasError) ...[
                const SizedBox(height: 16),
                _buildErrorSection(commonState),
              ],
              if (_aiAnalyzing) ...[
                const SizedBox(height: 16),
                _buildAnalysisProgress(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityStatus() {
    final isLocationVerified = _locationStatusColor == AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _locationStatusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _locationStatusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (_checkingLocation || _aiAnalyzing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_locationStatusColor),
              ),
            ),
          if (!_checkingLocation && !_aiAnalyzing)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _locationStatusColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _locationStatusColor.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Icon(
                isLocationVerified
                    ? Icons.verified_rounded
                    : Icons.warning_rounded,
                color: _locationStatusColor,
                size: 12,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _locationStatus,
              style: TextStyle(
                color: _locationStatusColor.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 18),
            onPressed: _checkingLocation ? null : _checkInitialLocation,
            color: _locationStatusColor,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(
    Color inputFillColor,
    Color textColor,
    Color hintColor,
    CommonState commonState,
  ) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: 'EMAIL',
        labelStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintText: 'your.email@nutantek.com',
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
        prefixIcon: Icon(
          Icons.email_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: _validateEmail,
      onChanged: (_) {
        commonState.clearError();
      },
    );
  }

  Widget _buildPasswordField(
    Color inputFillColor,
    Color textColor,
    Color hintColor,
    CommonState commonState,
  ) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: 'PASSWORD',
        labelStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintText: 'Enter your password',
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
        prefixIcon: Icon(
          Icons.lock_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: hintColor,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: _validatePassword,
      onChanged: (_) => commonState.clearError(),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _triggerAIPasswordRecovery,
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleLogin,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSection(CommonState commonState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              commonState.errorMessage,
              style: TextStyle(
                color: AppColors.error.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Analyzing security patterns...',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AI-Powered Methods
  void _analyzeEmailPattern(String email) async {
    final analysis = await _aiAuthService.analyzeEmailPattern(email);
    if (analysis['suspicious'] as bool) {
      _showAIEmailWarning(analysis['reason'] as String);
    }
  }

  void _performRealTimeEmailAnalysis(String email) {
    _aiAuthService.realTimeEmailAnalysis(email).then((analysis) {
      if (mounted && analysis['insights'] != null) {
        setState(() {
          _aiInsights = (analysis['insights'] as List<String>?) ?? [];
        });
      }
    });
  }

  void _showAIEmailWarning(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Detection: $reason', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _triggerAIPasswordRecovery() {
    _aiAuthService.initiateSmartPasswordRecovery(_emailController.text.trim());
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    if (_aiAuthService.isSuspiciousEmail(value)) {
      return 'Email pattern detected as suspicious';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }

    final strengthAnalysis = _aiAuthService.analyzePasswordStrength(value);
    if (!(strengthAnalysis['strong'] as bool)) {
      return 'Password too weak: ${strengthAnalysis['suggestion']}';
    }

    return null;
  }
}



// import 'package:attendanceapp/database/database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/view_models/theme_view_model.dart';
// import '../core/view_models/button_view_model.dart';
// import '../core/view_models/common_view_model.dart';
// import '../view_models/auth_view_model.dart';
// import '../services/geofencing_service.dart';
// import '../services/ai_auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;

//   bool _obscurePassword = true;
//   bool _checkingLocation = false;
//   bool _aiAnalyzing = false;
//   String _locationStatus = 'Checking security...';
//   Color _locationStatusColor = AppColors.warning;
//   String? _currentCity;
//   double _securityScore = 0.0;
//   List<String> _aiInsights = [];

//   // AI-Powered Security Metrics
//   final AIAuthService _aiAuthService = AIAuthService();
//   Map<String, dynamic> _behaviorMetrics = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _checkInitialLocation();
//     _testDatabase();
//     _initializeAIAnalytics();
//   }

//   void _testDatabase() async {
//     final dbHelper = DatabaseHelper();
//     await dbHelper.printAllUsers();
//   }

//   void _initializeAIAnalytics() {
//     _behaviorMetrics = {
//       'login_attempts': 0,
//       'typical_login_time': DateTime.now(),
//       'device_fingerprint': _generateDeviceFingerprint(),
//       'network_analysis': _analyzeNetworkSecurity(),
//     };
//   }

//   String _generateDeviceFingerprint() {
//     return '${DateTime.now().millisecondsSinceEpoch}_${_aiAuthService.generateDeviceHash()}';
//   }

//   Map<String, dynamic> _analyzeNetworkSecurity() {
//     return {
//       'vpn_detected': false,
//       'proxy_usage': false,
//       'network_trust_score': 0.95,
//       'threat_level': 'low',
//     };
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _scaleAnimation = Tween<double>(
//       begin: 0.95,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   // 🔧 DEBUG METHODS
//   void _resetAndTestDatabase() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     await authViewModel.resetDatabase();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Database Reset Complete'),
//         content: Text(
//           'All users have been reset with correct passwords.\n\nNow try logging in with:\n\nEmployee: employee1@nutantek.com / employee123\nManager: manager1@nutantek.com / manager123\nHR: hr@nutantek.com / hr123\nFinance: finance@nutantek.com / finance123',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _emergencyLogin(String userType) {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     authViewModel.emergencyLogin(userType);
//     commonState.clearError();
//     authViewModel.navigateToDashboard(context);

//     print('🚀 Emergency login activated for: $userType');
//   }

//   void _testLogin() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     await authViewModel.testAllLogins();
//   }

//   void _quickLogin(String email, String password) {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     _emailController.text = email;
//     _passwordController.text = password;
//     commonState.clearError();

//     print('🚀 Quick login: $email');
//     _handleLogin();
//   }

//   Future<void> _checkInitialLocation() async {
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     setState(() {
//       _checkingLocation = true;
//       _locationStatus = 'Checking location security...';
//     });

//     try {
//       final geofencingService = GeofencingService();
//       final locationCheck = await geofencingService.checkAllowedLocation();

//       final locationAnalysis = await _aiAuthService.analyzeLocationPattern(
//         locationCheck,
//         _behaviorMetrics['typical_login_time'],
//       );

//       setState(() {
//         _checkingLocation = false;
//         if (locationCheck['allowed'] == true &&
//             locationAnalysis['trustworthy']) {
//           _locationStatus = '✓ ${locationAnalysis['message']}';
//           _locationStatusColor = AppColors.success;
//           _currentCity = locationCheck['city'];
//           _securityScore =
//               (locationAnalysis['security_score'] as double?) ?? 0.0;
//           _aiInsights = (locationAnalysis['insights'] as List<String>?) ?? [];
//         } else {
//           _locationStatus = '✗ ${locationAnalysis['message']}';
//           _locationStatusColor = AppColors.error;
//           _currentCity = null;
//           _securityScore =
//               (locationAnalysis['security_score'] as double?) ?? 0.0;
//           _aiInsights = (locationAnalysis['insights'] as List<String>?) ?? [];
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _checkingLocation = false;
//         _locationStatus = '✗ Security check failed';
//         _locationStatusColor = AppColors.error;
//       });
//       commonState.setError('Location service error: $e');
//     }
//   }

//   Future<void> _handleLogin() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     final buttonState = Provider.of<ButtonState>(context, listen: false);
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     if (!_formKey.currentState!.validate()) return;

//     buttonState.setLoading(true);

//     try {
//       final success = await authViewModel.login(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       if (success && mounted) {
//         await _aiAuthService.recordSuccessfulLogin(
//           authViewModel.currentUser!,
//           _behaviorMetrics,
//         );

//         commonState.setLoading(false);
//         buttonState.setLoading(false);

//         _showAIEnhancedSuccessSnackbar(
//           context,
//           authViewModel.currentUser!.name,
//           _getUserRoleDisplay(authViewModel.currentUser!.userType),
//           _securityScore,
//         );

//         authViewModel.navigateToDashboard(context);
//       } else if (!success) {
//         await _aiAuthService.recordFailedLoginAttempt(
//           _emailController.text.trim(),
//           _behaviorMetrics,
//         );

//         commonState.setError(authViewModel.errorMessage);
//         buttonState.setLoading(false);
//       }
//     } catch (e) {
//       commonState.setError('Login failed: ${e.toString()}');
//       buttonState.setLoading(false);
//     } finally {
//       setState(() {
//         _aiAnalyzing = false;
//       });
//     }
//   }

//   // ✅ SINGLE _getUserRoleDisplay METHOD
//   String _getUserRoleDisplay(String userType) {
//     switch (userType) {
//       case 'manager':
//         return 'Manager';
//       case 'hr':
//         return 'HR Manager';
//       case 'finance_manager':
//         return 'Finance Manager';
//       case 'employee':
//       default:
//         return 'Employee';
//     }
//   }

//   void _showAIEnhancedSuccessSnackbar(
//     BuildContext context,
//     String userName,
//     String userRole,
//     double securityScore,
//   ) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Access Granted, $userName!',
//                     style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
//                   ),
//                   Text(
//                     'Logged in as $userRole • Security Score: ${(securityScore * 100).toStringAsFixed(0)}%',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: _getSecurityColor(securityScore),
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(20),
//       ),
//     );
//   }

//   Color _getSecurityColor(double score) {
//     if (score >= 0.8) return AppColors.success;
//     if (score >= 0.6) return AppColors.warning;
//     return AppColors.error;
//   }

//   // Helper methods for debug section
//   String _getPasswordForUser(String email) {
//     switch (email) {
//       case 'employee1@nutantek.com':
//       case 'employee2@nutantek.com':
//       case 'employee3@nutantek.com':
//         return 'employee123';
//       case 'manager1@nutantek.com':
//       case 'manager2@nutantek.com':
//       case 'manager3@nutantek.com':
//         return 'manager123';
//       case 'hr@nutantek.com':
//         return 'hr123';
//       case 'finance@nutantek.com':
//         return 'finance123';
//       default:
//         return 'employee123';
//     }
//   }

//   IconData _getUserIcon(String userType) {
//     switch (userType) {
//       case 'manager':
//         return Icons.manage_accounts;
//       case 'hr':
//         return Icons.people;
//       case 'finance_manager':
//         return Icons.attach_money;
//       case 'employee':
//       default:
//         return Icons.person;
//     }
//   }

//   Color _getUserColor(String userType) {
//     switch (userType) {
//       case 'manager':
//         return Colors.blue;
//       case 'hr':
//         return Colors.purple;
//       case 'finance_manager':
//         return Colors.teal;
//       case 'employee':
//       default:
//         return Colors.green;
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final commonState = Provider.of<CommonState>(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment.topLeft,
//             radius: 2.0,
//             colors: [
//               AppColors.primary.withOpacity(0.15),
//               AppColors.secondary.withOpacity(0.1),
//               Colors.black,
//             ],
//             stops: const [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, child) {
//               return FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: SlideTransition(
//                   position: _slideAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         children: [
//                           _buildHeader(),
//                           const SizedBox(height: 40),
//                           _buildLoginCard(theme, commonState),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [_buildLogo(), const SizedBox(height: 30), _buildWelcomeText()],
//     );
//   }

//   Widget _buildLogo() {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         width: 100,
//         height: 100,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [AppColors.primary, AppColors.primaryLight],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withOpacity(0.4),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Center(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.asset(
//               'assets/images/nutantek_logo.png',
//               width: 50,
//               height: 50,
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.business_center_rounded,
//                     color: AppColors.primary,
//                     size: 30,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeText() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Column(
//         children: [
//           Text(
//             'WELCOME',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 2.0,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Enterprise Attendance System',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.white.withOpacity(0.8),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoginCard(AppTheme theme, CommonState commonState) {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _buildSecurityStatus(),
//               const SizedBox(height: 24),
//               _buildEmailField(theme, commonState),
//               const SizedBox(height: 16),
//               _buildPasswordField(theme, commonState),
//               const SizedBox(height: 16),
//               _buildActionRow(),
//               const SizedBox(height: 24),
//               _buildLoginButton(),
//               if (commonState.hasError) ...[
//                 const SizedBox(height: 16),
//                 _buildErrorSection(commonState),
//               ],
//               if (_aiAnalyzing) ...[
//                 const SizedBox(height: 16),
//                 _buildAnalysisProgress(),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSecurityStatus() {
//     final isLocationVerified = _locationStatusColor == AppColors.success;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _locationStatusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: _locationStatusColor.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           if (_checkingLocation || _aiAnalyzing)
//             SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(_locationStatusColor),
//               ),
//             ),
//           if (!_checkingLocation && !_aiAnalyzing)
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 color: _locationStatusColor.withOpacity(0.2),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: _locationStatusColor.withOpacity(0.6),
//                   width: 2,
//                 ),
//               ),
//               child: Icon(
//                 isLocationVerified
//                     ? Icons.verified_rounded
//                     : Icons.warning_rounded,
//                 color: _locationStatusColor,
//                 size: 12,
//               ),
//             ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               _locationStatus,
//               style: TextStyle(
//                 color: _locationStatusColor.withOpacity(0.9),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.refresh_rounded, size: 18),
//             onPressed: _checkingLocation ? null : _checkInitialLocation,
//             color: _locationStatusColor,
//             padding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmailField(AppTheme theme, CommonState commonState) {
//     return TextFormField(
//       controller: _emailController,
//       keyboardType: TextInputType.emailAddress,
//       style: TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.w500,
//         fontSize: 16,
//       ),
//       decoration: InputDecoration(
//         labelText: 'EMAIL',
//         labelStyle: TextStyle(
//           color: AppColors.primary,
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//         ),
//         hintText: 'your.email@nutantek.com',
//         hintStyle: TextStyle(
//           color: Colors.white.withOpacity(0.5),
//           fontWeight: FontWeight.w400,
//         ),
//         prefixIcon: Icon(
//           Icons.email_rounded,
//           color: AppColors.primary,
//           size: 20,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//       ),
//       validator: _validateEmail,
//       onChanged: (_) {
//         commonState.clearError();
//       },
//     );
//   }

//   Widget _buildPasswordField(AppTheme theme, CommonState commonState) {
//     return TextFormField(
//       controller: _passwordController,
//       obscureText: _obscurePassword,
//       style: TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.w500,
//         fontSize: 16,
//       ),
//       decoration: InputDecoration(
//         labelText: 'PASSWORD',
//         labelStyle: TextStyle(
//           color: AppColors.primary,
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//         ),
//         hintText: 'Enter your password',
//         hintStyle: TextStyle(
//           color: Colors.white.withOpacity(0.5),
//           fontWeight: FontWeight.w400,
//         ),
//         prefixIcon: Icon(
//           Icons.lock_rounded,
//           color: AppColors.primary,
//           size: 20,
//         ),
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscurePassword
//                 ? Icons.visibility_off_rounded
//                 : Icons.visibility_rounded,
//             color: Colors.white.withOpacity(0.7),
//             size: 20,
//           ),
//           onPressed: () {
//             setState(() {
//               _obscurePassword = !_obscurePassword;
//             });
//           },
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//       ),
//       validator: _validatePassword,
//       onChanged: (_) => commonState.clearError(),
//     );
//   }

//   Widget _buildActionRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         TextButton(
//           onPressed: _triggerAIPasswordRecovery,
//           child: Text(
//             'Forgot Password?',
//             style: TextStyle(
//               color: AppColors.primary,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoginButton() {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.primary, AppColors.primaryDark],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _handleLogin,
//           borderRadius: BorderRadius.circular(12),
//           child: Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.login_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Text(
//                   'LOGIN',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorSection(CommonState commonState) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.error.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.error.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               commonState.errorMessage,
//               style: TextStyle(
//                 color: AppColors.error.withOpacity(0.9),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalysisProgress() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'Analyzing security patterns...',
//               style: TextStyle(
//                 color: AppColors.primary.withOpacity(0.9),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // AI-Powered Methods
//   void _analyzeEmailPattern(String email) async {
//     final analysis = await _aiAuthService.analyzeEmailPattern(email);
//     if (analysis['suspicious'] as bool) {
//       _showAIEmailWarning(analysis['reason'] as String);
//     }
//   }

//   void _performRealTimeEmailAnalysis(String email) {
//     _aiAuthService.realTimeEmailAnalysis(email).then((analysis) {
//       if (mounted && analysis['insights'] != null) {
//         setState(() {
//           _aiInsights = (analysis['insights'] as List<String>?) ?? [];
//         });
//       }
//     });
//   }

//   void _showAIEmailWarning(String reason) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text('Detection: $reason', style: TextStyle(fontSize: 13)),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.warning,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _triggerAIPasswordRecovery() {
//     _aiAuthService.initiateSmartPasswordRecovery(_emailController.text.trim());
//   }

//   // Validation methods
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }

//     final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

//     if (!emailRegex.hasMatch(value)) {
//       return 'Please enter a valid email';
//     }

//     if (_aiAuthService.isSuspiciousEmail(value)) {
//       return 'Email pattern detected as suspicious';
//     }

//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }

//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }

//     if (value.length > 128) {
//       return 'Password must be less than 128 characters';
//     }

//     final strengthAnalysis = _aiAuthService.analyzePasswordStrength(value);
//     if (!(strengthAnalysis['strong'] as bool)) {
//       return 'Password too weak: ${strengthAnalysis['suggestion']}';
//     }

//     return null;
//   }
// }

/* ###################################################################################################################

************************************                   A I S C R E E N C O D E              **************************
############################ */

// import 'dart:math';
// import 'dart:ui';
// import 'package:attendanceapp/database/database_helper.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/view_models/theme_view_model.dart';
// import '../core/view_models/button_view_model.dart';
// import '../core/view_models/common_view_model.dart';
// import '../core/widgets/custom_buttons.dart';
// import '../view_models/auth_view_model.dart';
// import '../services/geofencing_service.dart';
// import '../services/ai_auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _bounceAnimation;
//   late Animation<Color?> _gradientAnimation;
//   late Animation<double> _neuralAnimation;
//   late Animation<double> _particleAnimation;

//   bool _obscurePassword = true;
//   bool _checkingLocation = false;
//   bool _aiAnalyzing = false;
//   String _locationStatus = 'Initializing Neural Security...';
//   Color _locationStatusColor = QuickAIColors.cyber.warning;
//   String? _currentCity;
//   double _securityScore = 0.0;
//   List<String> _aiInsights = [];
//   List<Particle> _particles = [];

//   // AI-Powered Security Metrics
//   final AIAuthService _aiAuthService = AIAuthService();
//   Map<String, dynamic> _behaviorMetrics = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeParticles();
//     _initializeAnimations();
//     _checkInitialLocation();
//     _testDatabase();
//     _initializeAIAnalytics();
//   }

//   void _initializeParticles() {
//     for (int i = 0; i < 20; i++) {
//       _particles.add(Particle());
//     }
//   }

//   void _testDatabase() async {
//     final dbHelper = DatabaseHelper();
//     await dbHelper.printAllUsers();
//   }

//   void _initializeAIAnalytics() {
//     _behaviorMetrics = {
//       'login_attempts': 0,
//       'typical_login_time': DateTime.now(),
//       'device_fingerprint': _generateDeviceFingerprint(),
//       'network_analysis': _analyzeNetworkSecurity(),
//     };
//   }

//   String _generateDeviceFingerprint() {
//     return '${DateTime.now().millisecondsSinceEpoch}_${_aiAuthService.generateDeviceHash()}';
//   }

//   Map<String, dynamic> _analyzeNetworkSecurity() {
//     return {
//       'vpn_detected': false,
//       'proxy_usage': false,
//       'network_trust_score': 0.95,
//       'threat_level': 'low',
//     };
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2500),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
//           ),
//         );

//     _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.3, 0.9, curve: Curves.elasticOut),
//       ),
//     );

//     _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.4, 1.0, curve: Curves.bounceOut),
//       ),
//     );

//     _gradientAnimation = ColorTween(
//       begin: QuickAIColors.cyber.primary.withOpacity(0.6),
//       end: QuickAIColors.cyber.primary,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _neuralAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
//       ),
//     );

//     _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _controller.forward();
//   }

//   // 🔧 DEBUG METHODS
//   void _resetAndTestDatabase() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     await authViewModel.resetDatabase();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Database Reset Complete'),
//         content: Text(
//           'All users have been reset with correct passwords.\n\nNow try logging in with:\n\nEmployee: employee1@nutantek.com / employee123\nManager: manager1@nutantek.com / manager123\nHR: hr@nutantek.com / hr123\nFinance: finance@nutantek.com / finance123',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _emergencyLogin(String userType) {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     authViewModel.emergencyLogin(userType);
//     commonState.clearError();
//     authViewModel.navigateToDashboard(context);

//     print('🚀 Emergency login activated for: $userType');
//   }

//   void _testLogin() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     await authViewModel.testAllLogins();
//   }

//   void _quickLogin(String email, String password) {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     _emailController.text = email;
//     _passwordController.text = password;
//     commonState.clearError();

//     print('🚀 Quick login: $email');
//     _handleLogin();
//   }

//   Future<void> _checkInitialLocation() async {
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     setState(() {
//       _checkingLocation = true;
//       _locationStatus = 'Analyzing neural security patterns...';
//     });

//     try {
//       final geofencingService = GeofencingService();
//       final locationCheck = await geofencingService.checkAllowedLocation();

//       final locationAnalysis = await _aiAuthService.analyzeLocationPattern(
//         locationCheck,
//         _behaviorMetrics['typical_login_time'],
//       );

//       setState(() {
//         _checkingLocation = false;
//         if (locationCheck['allowed'] == true &&
//             locationAnalysis['trustworthy']) {
//           _locationStatus = '✓ ${locationAnalysis['message']}';
//           _locationStatusColor = QuickAIColors.cyber.accent;
//           _currentCity = locationCheck['city'];
//           _securityScore =
//               (locationAnalysis['security_score'] as double?) ?? 0.0;
//           _aiInsights = (locationAnalysis['insights'] as List<String>?) ?? [];
//         } else {
//           _locationStatus = '✗ ${locationAnalysis['message']}';
//           _locationStatusColor = QuickAIColors.cyber.error;
//           _currentCity = null;
//           _securityScore =
//               (locationAnalysis['security_score'] as double?) ?? 0.0;
//           _aiInsights = (locationAnalysis['insights'] as List<String>?) ?? [];
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _checkingLocation = false;
//         _locationStatus = '✗ Neural Security Analysis Failed';
//         _locationStatusColor = QuickAIColors.cyber.error;
//       });
//       commonState.setError('AI Location service error: $e');
//     }
//   }

//   Future<void> _handleLogin() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     final buttonState = Provider.of<ButtonState>(context, listen: false);
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     if (!_formKey.currentState!.validate()) return;

//     buttonState.setLoading(true);

//     try {
//       final success = await authViewModel.login(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       if (success && mounted) {
//         await _aiAuthService.recordSuccessfulLogin(
//           authViewModel.currentUser!,
//           _behaviorMetrics,
//         );

//         commonState.setLoading(false);
//         buttonState.setLoading(false);

//         _showAIEnhancedSuccessSnackbar(
//           context,
//           authViewModel.currentUser!.name,
//           _getUserRoleDisplay(authViewModel.currentUser!.userType),
//           _securityScore,
//         );

//         authViewModel.navigateToDashboard(context);
//       } else if (!success) {
//         await _aiAuthService.recordFailedLoginAttempt(
//           _emailController.text.trim(),
//           _behaviorMetrics,
//         );

//         commonState.setError(authViewModel.errorMessage);
//         buttonState.setLoading(false);
//       }
//     } catch (e) {
//       commonState.setError('Login failed: ${e.toString()}');
//       buttonState.setLoading(false);
//     } finally {
//       setState(() {
//         _aiAnalyzing = false;
//       });
//     }
//   }

//   // ✅ SINGLE _getUserRoleDisplay METHOD
//   String _getUserRoleDisplay(String userType) {
//     switch (userType) {
//       case 'manager':
//         return 'Manager';
//       case 'hr':
//         return 'HR Manager';
//       case 'finance_manager':
//         return 'Finance Manager';
//       case 'employee':
//       default:
//         return 'Employee';
//     }
//   }

//   void _showAIEnhancedSuccessSnackbar(
//     BuildContext context,
//     String userName,
//     String userRole,
//     double securityScore,
//   ) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Access Granted, $userName!',
//                     style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
//                   ),
//                   Text(
//                     'Logged in as $userRole • Neural Score: ${(securityScore * 100).toStringAsFixed(0)}%',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: _getSecurityColor(securityScore),
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         margin: const EdgeInsets.all(20),
//       ),
//     );
//   }

//   Color _getSecurityColor(double score) {
//     if (score >= 0.8) return QuickAIColors.cyber.accent;
//     if (score >= 0.6) return QuickAIColors.cyber.warning;
//     return QuickAIColors.cyber.error;
//   }

//   // Helper methods for debug section
//   String _getPasswordForUser(String email) {
//     switch (email) {
//       case 'employee1@nutantek.com':
//       case 'employee2@nutantek.com':
//       case 'employee3@nutantek.com':
//         return 'employee123';
//       case 'manager1@nutantek.com':
//       case 'manager2@nutantek.com':
//       case 'manager3@nutantek.com':
//         return 'manager123';
//       case 'hr@nutantek.com':
//         return 'hr123';
//       case 'finance@nutantek.com':
//         return 'finance123';
//       default:
//         return 'employee123';
//     }
//   }

//   IconData _getUserIcon(String userType) {
//     switch (userType) {
//       case 'manager':
//         return Icons.manage_accounts;
//       case 'hr':
//         return Icons.people;
//       case 'finance_manager':
//         return Icons.attach_money;
//       case 'employee':
//       default:
//         return Icons.person;
//     }
//   }

//   Color _getUserColor(String userType) {
//     switch (userType) {
//       case 'manager':
//         return Colors.blue;
//       case 'hr':
//         return Colors.purple;
//       case 'finance_manager':
//         return Colors.teal;
//       case 'employee':
//       default:
//         return Colors.green;
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final commonState = Provider.of<CommonState>(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           _buildBackground(),
//           _buildNeuralParticles(),
//           SafeArea(
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: ScaleTransition(
//                       scale: _scaleAnimation,
//                       child: SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           children: [
//                             _buildHeader(),
//                             const SizedBox(height: 40),
//                             _buildLoginCard(theme, commonState),
//                             // const SizedBox(height: 20),
//                             // _buildDebugSection(),
//                             // const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // DEBUG SECTION
//   Widget _buildDebugSection() {
//     return FutureBuilder<List<User>>(
//       future: Provider.of<AuthViewModel>(
//         context,
//         listen: false,
//       ).getAvailableUsers(),
//       builder: (context, snapshot) {
//         final users = snapshot.data ?? [];

//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 8),
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.red.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.red),
//           ),
//           child: Column(
//             children: [
//               Text(
//                 '🚨 DEBUG OPTIONS - ALL USERS',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(height: 10),

//               // Quick Login Buttons
//               Text(
//                 'QUICK LOGIN:',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 5),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 5,
//                 children: [
//                   _buildQuickLoginButton(
//                     'Employee 1',
//                     'employee1@nutantek.com',
//                     'employee123',
//                     Colors.green,
//                   ),
//                   _buildQuickLoginButton(
//                     'Manager 1',
//                     'manager1@nutantek.com',
//                     'manager123',
//                     Colors.blue,
//                   ),
//                   _buildQuickLoginButton(
//                     'HR',
//                     'hr@nutantek.com',
//                     'hr123',
//                     Colors.purple,
//                   ),
//                   _buildQuickLoginButton(
//                     'Finance',
//                     'finance@nutantek.com',
//                     'finance123',
//                     Colors.teal,
//                   ),
//                 ],
//               ),

//               SizedBox(height: 10),

//               // Control Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _resetAndTestDatabase,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                     ),
//                     child: Text(
//                       'Reset DB',
//                       style: TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: _testLogin,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                     ),
//                     child: Text(
//                       'Test Logins',
//                       style: TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQuickLoginButton(
//     String role,
//     String email,
//     String password,
//     Color color,
//   ) {
//     return ElevatedButton(
//       onPressed: () => _quickLogin(email, password),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       ),
//       child: Text(role, style: TextStyle(color: Colors.white, fontSize: 10)),
//     );
//   }

//   // Rest of your existing UI methods (_buildBackground, _buildNeuralParticles, etc.)
//   // ... (yeh sab methods aapke existing code se raheinge)

//   Widget _buildBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: RadialGradient(
//           center: Alignment.topLeft,
//           radius: 2.0,
//           colors: [
//             QuickAIColors.cyber.primary.withOpacity(0.3),
//             QuickAIColors.cyber.secondary.withOpacity(0.2),
//             Colors.black,
//           ],
//           stops: const [0.0, 0.5, 1.0],
//         ),
//       ),
//     );
//   }

//   Widget _buildNeuralParticles() {
//     return AnimatedBuilder(
//       animation: _particleAnimation,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: _NeuralParticlePainter(
//             particles: _particles,
//             animationValue: _particleAnimation.value,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [_buildLogo(), const SizedBox(height: 30), _buildWelcomeText()],
//     );
//   }

//   Widget _buildLogo() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         _buildOrbitals(),
//         _buildCoreAnimation(),
//         ScaleTransition(
//           scale: _bounceAnimation,
//           child: Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   QuickAIColors.cyber.primary,
//                   QuickAIColors.cyber.secondary,
//                 ],
//               ),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: QuickAIColors.cyber.primary.withOpacity(0.6),
//                   blurRadius: 40,
//                   offset: const Offset(0, 20),
//                 ),
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 30,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.3),
//                         Colors.transparent,
//                         Colors.transparent,
//                       ],
//                       stops: const [0.0, 0.5, 1.0],
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(25),
//                     child: Image.asset(
//                       'assets/images/nutantek_logo.png',
//                       width: 60,
//                       height: 60,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             Icons.business_center_rounded,
//                             color: QuickAIColors.cyber.primary,
//                             size: 30,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOrbitals() {
//     return AnimatedBuilder(
//       animation: _neuralAnimation,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: _OrbitalPainter(animationValue: _neuralAnimation.value),
//           size: const Size(180, 180),
//         );
//       },
//     );
//   }

//   Widget _buildCoreAnimation() {
//     return AnimatedBuilder(
//       animation: _neuralAnimation,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: _CorePainter(
//             animationValue: _neuralAnimation.value,
//             securityScore: _securityScore,
//           ),
//           size: const Size(140, 140),
//         );
//       },
//     );
//   }

//   Widget _buildWelcomeText() {
//     return FadeTransition(
//       opacity: CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.4, 0.8),
//       ),
//       child: Column(
//         children: [
//           ShaderMask(
//             shaderCallback: (bounds) {
//               return LinearGradient(
//                 colors: [
//                   QuickAIColors.cyber.primary,
//                   QuickAIColors.cyber.accent,
//                   QuickAIColors.cyber.secondary,
//                 ],
//               ).createShader(bounds);
//             },
//             child: Text(
//               'WELCOME',
//               style: TextStyle(
//                 fontSize: 42,
//                 fontWeight: FontWeight.w900,
//                 letterSpacing: 3.0,
//                 height: 1.1,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoginCard(AppTheme theme, CommonState commonState) {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(32),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 50,
//               offset: const Offset(0, 25),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(32),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
//             child: Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white.withOpacity(0.15),
//                     Colors.white.withOpacity(0.05),
//                   ],
//                 ),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 1.5,
//                 ),
//                 borderRadius: BorderRadius.circular(32),
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     _buildSecurityStatus(),
//                     const SizedBox(height: 32),
//                     _buildEmailField(theme, commonState),
//                     const SizedBox(height: 20),
//                     _buildPasswordField(theme, commonState),
//                     const SizedBox(height: 16),
//                     _buildActionRow(),
//                     const SizedBox(height: 32),
//                     _buildLoginButton(),
//                     if (commonState.hasError) ...[
//                       const SizedBox(height: 20),
//                       _buildErrorSection(commonState),
//                     ],
//                     if (_aiAnalyzing) ...[
//                       const SizedBox(height: 20),
//                       _buildAnalysisProgress(),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSecurityStatus() {
//     final isLocationVerified =
//         _locationStatusColor == QuickAIColors.cyber.accent;

//     return ScaleTransition(
//       scale: CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.2, 0.6),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: [
//               _locationStatusColor.withOpacity(0.2),
//               _locationStatusColor.withOpacity(0.05),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: _locationStatusColor.withOpacity(0.4),
//             width: 2,
//           ),
//         ),
//         child: Row(
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 if (_checkingLocation || _aiAnalyzing)
//                   SizedBox(
//                     width: 32,
//                     height: 32,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 3,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         _locationStatusColor,
//                       ),
//                     ),
//                   ),
//                 if (!_checkingLocation && !_aiAnalyzing)
//                   Container(
//                     width: 32,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: _locationStatusColor.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: _locationStatusColor.withOpacity(0.6),
//                         width: 2,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: _locationStatusColor.withOpacity(0.3),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       isLocationVerified
//                           ? Icons.verified_rounded
//                           : Icons.warning_rounded,
//                       color: _locationStatusColor,
//                       size: 18,
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _locationStatus,
//                     style: TextStyle(
//                       color: _locationStatusColor.withOpacity(0.9),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 _buildActionButton(
//                   icon: Icons.refresh_rounded,
//                   onPressed: _checkingLocation ? null : _checkInitialLocation,
//                   color: _locationStatusColor,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required VoidCallback? onPressed,
//     required Color color,
//   }) {
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4)),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: IconButton(
//         icon: Icon(icon, size: 20),
//         onPressed: onPressed,
//         color: color,
//         padding: EdgeInsets.zero,
//       ),
//     );
//   }

//   Widget _buildEmailField(AppTheme theme, CommonState commonState) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       child: TextFormField(
//         controller: _emailController,
//         keyboardType: TextInputType.emailAddress,
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w500,
//           fontSize: 16,
//         ),
//         decoration: InputDecoration(
//           labelText: 'EMAIL',
//           labelStyle: TextStyle(
//             color: QuickAIColors.cyber.primary,
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 1.5,
//           ),
//           hintText: 'your.email@nutantek.com',
//           hintStyle: TextStyle(
//             color: Colors.white.withOpacity(0.5),
//             fontWeight: FontWeight.w400,
//           ),
//           prefixIcon: Container(
//             margin: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: QuickAIColors.cyber.primary.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.email_rounded,
//               color: QuickAIColors.cyber.primary,
//               size: 22,
//             ),
//           ),
//           suffixIcon: _emailController.text.isNotEmpty
//               ? IconButton(
//                   icon: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: QuickAIColors.cyber.primary.withOpacity(0.15),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.auto_awesome_rounded,
//                       color: QuickAIColors.cyber.primary,
//                       size: 18,
//                     ),
//                   ),
//                   onPressed: () {
//                     _analyzeEmailPattern(_emailController.text);
//                   },
//                 )
//               : null,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white.withOpacity(0.1),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 18,
//           ),
//         ),
//         validator: _validateEmail,
//         onChanged: (_) {
//           commonState.clearError();
//           if (_emailController.text.length > 3) {
//             _performRealTimeEmailAnalysis(_emailController.text);
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildPasswordField(AppTheme theme, CommonState commonState) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       child: TextFormField(
//         controller: _passwordController,
//         obscureText: _obscurePassword,
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w500,
//           fontSize: 16,
//         ),
//         decoration: InputDecoration(
//           labelText: 'PASSWORD',
//           labelStyle: TextStyle(
//             color: QuickAIColors.cyber.primary,
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 1.5,
//           ),
//           hintText: 'Enter your key',
//           hintStyle: TextStyle(
//             color: Colors.white.withOpacity(0.5),
//             fontWeight: FontWeight.w400,
//           ),
//           prefixIcon: Container(
//             margin: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: QuickAIColors.cyber.primary.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.lock_rounded,
//               color: QuickAIColors.cyber.primary,
//               size: 22,
//             ),
//           ),
//           suffixIcon: IconButton(
//             icon: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   _obscurePassword
//                       ? Icons.visibility_off_rounded
//                       : Icons.visibility_rounded,
//                   color: Colors.white.withOpacity(0.7),
//                   size: 22,
//                   key: ValueKey<bool>(_obscurePassword),
//                 ),
//               ),
//             ),
//             onPressed: () {
//               setState(() {
//                 _obscurePassword = !_obscurePassword;
//               });
//             },
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white.withOpacity(0.1),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 18,
//           ),
//         ),
//         validator: _validatePassword,
//         onChanged: (_) => commonState.clearError(),
//       ),
//     );
//   }

//   Widget _buildActionRow() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             child: TextButton(
//               onPressed: _triggerAIPasswordRecovery,
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.vpn_key_rounded,
//                     color: QuickAIColors.cyber.primary,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'FORGET YOUR PASSWORD',
//                     style: TextStyle(
//                       color: QuickAIColors.cyber.primary,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoginButton() {
//     return ScaleTransition(
//       scale: _bounceAnimation,
//       child: Stack(
//         children: [
//           Container(
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   QuickAIColors.cyber.primary,
//                   QuickAIColors.cyber.secondary,
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: QuickAIColors.cyber.primary.withOpacity(0.6),
//                   blurRadius: 30,
//                   offset: const Offset(0, 15),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: _handleLogin,
//                 borderRadius: BorderRadius.circular(20),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.psychology_rounded,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                       const SizedBox(width: 16),
//                       Text(
//                         'LOGIN',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           if (_aiAnalyzing)
//             Positioned(
//               right: 20,
//               top: 0,
//               bottom: 0,
//               child: Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   shape: BoxShape.circle,
//                 ),
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorSection(CommonState commonState) {
//     return ScaleTransition(
//       scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               QuickAIColors.cyber.error.withOpacity(0.2),
//               QuickAIColors.cyber.error.withOpacity(0.05),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: QuickAIColors.cyber.error.withOpacity(0.4)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: QuickAIColors.cyber.error.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.warning_amber_rounded,
//                 color: QuickAIColors.cyber.error,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'ALERT',
//                     style: TextStyle(
//                       color: QuickAIColors.cyber.error,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     commonState.errorMessage,
//                     style: TextStyle(
//                       color: QuickAIColors.cyber.error.withOpacity(0.9),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnalysisProgress() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             QuickAIColors.cyber.primary.withOpacity(0.15),
//             QuickAIColors.cyber.primary.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: QuickAIColors.cyber.primary.withOpacity(0.4)),
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 28,
//             height: 28,
//             child: CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 QuickAIColors.cyber.primary,
//               ),
//             ),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'ANALYSIS',
//                   style: TextStyle(
//                     color: QuickAIColors.cyber.primary,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Neural network analyzing security patterns...',
//                   style: TextStyle(
//                     color: QuickAIColors.cyber.primary.withOpacity(0.9),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // AI-Powered Methods
//   void _analyzeEmailPattern(String email) async {
//     final analysis = await _aiAuthService.analyzeEmailPattern(email);
//     if (analysis['suspicious'] as bool) {
//       _showAIEmailWarning(analysis['reason'] as String);
//     }
//   }

//   void _performRealTimeEmailAnalysis(String email) {
//     _aiAuthService.realTimeEmailAnalysis(email).then((analysis) {
//       if (mounted && analysis['insights'] != null) {
//         setState(() {
//           _aiInsights = (analysis['insights'] as List<String>?) ?? [];
//         });
//       }
//     });
//   }

//   void _showAIEmailWarning(String reason) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text('Detection: $reason', style: TextStyle(fontSize: 13)),
//             ),
//           ],
//         ),
//         backgroundColor: QuickAIColors.cyber.warning,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }

//   void _triggerAIPasswordRecovery() {
//     _aiAuthService.initiateSmartPasswordRecovery(_emailController.text.trim());
//   }

//   // Validation methods
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }

//     final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

//     if (!emailRegex.hasMatch(value)) {
//       return 'Please enter a valid email';
//     }

//     if (_aiAuthService.isSuspiciousEmail(value)) {
//       return 'Email pattern detected as suspicious';
//     }

//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }

//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }

//     if (value.length > 128) {
//       return 'Password must be less than 128 characters';
//     }

//     final strengthAnalysis = _aiAuthService.analyzePasswordStrength(value);
//     if (!(strengthAnalysis['strong'] as bool)) {
//       return 'Password too weak: ${strengthAnalysis['suggestion']}';
//     }

//     return null;
//   }
// }

// // Custom Painters (unchanged)
// class _OrbitalPainter extends CustomPainter {
//   final double animationValue;
//   _OrbitalPainter({required this.animationValue});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final paint = Paint()
//       ..color = QuickAIColors.cyber.primary.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     for (int i = 1; i <= 3; i++) {
//       final radius = (size.width / 2) * 0.3 * i;
//       final orbitalPaint = Paint()
//         ..color = QuickAIColors.cyber.primary.withOpacity(0.2 / i)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.0;

//       canvas.drawCircle(center, radius, orbitalPaint);

//       final dotAngle = animationValue * 2 * pi * (i % 2 == 0 ? 1 : -1);
//       final dotX = center.dx + cos(dotAngle) * radius;
//       final dotY = center.dy + sin(dotAngle) * radius;

//       final dotPaint = Paint()
//         ..color = QuickAIColors.cyber.accent
//         ..style = PaintingStyle.fill;

//       canvas.drawCircle(Offset(dotX, dotY), 3.0, dotPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class _CorePainter extends CustomPainter {
//   final double animationValue;
//   final double securityScore;
//   _CorePainter({required this.animationValue, required this.securityScore});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final maxRadius = size.width / 2 * 0.8;

//     for (int i = 0; i < 16; i++) {
//       final angle = (i / 16) * 2 * pi;
//       final x = center.dx + cos(angle) * maxRadius;
//       final y = center.dy + sin(angle) * maxRadius;

//       final nodePaint = Paint()
//         ..color = _getSecurityColor().withOpacity(0.9 * animationValue)
//         ..style = PaintingStyle.fill
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * animationValue);

//       final nodeSize = 3 + 3 * sin(animationValue * pi * 2 + i);
//       canvas.drawCircle(Offset(x, y), nodeSize, nodePaint);

//       for (int j = i + 1; j < 16; j += 2) {
//         final angle2 = (j / 16) * 2 * pi;
//         final x2 = center.dx + cos(angle2) * maxRadius;
//         final y2 = center.dy + sin(angle2) * maxRadius;

//         final distance = sqrt(pow(x2 - x, 2) + pow(y2 - y, 2));
//         final opacity = (1 - (distance / (maxRadius * 2))) * animationValue;

//         final connectionPaint = Paint()
//           ..color = _getColor(opacity)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 1.5
//           ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

//         canvas.drawLine(Offset(x, y), Offset(x2, y2), connectionPaint);
//       }
//     }
//   }

//   Color _getColor(double opacity) {
//     return QuickAIColors.cyber.primary.withOpacity(opacity * 0.6);
//   }

//   Color _getSecurityColor() {
//     if (securityScore >= 0.8) return QuickAIColors.cyber.accent;
//     if (securityScore >= 0.6) return QuickAIColors.cyber.warning;
//     return QuickAIColors.cyber.error;
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class _NeuralParticlePainter extends CustomPainter {
//   final List<Particle> particles;
//   final double animationValue;
//   _NeuralParticlePainter({
//     required this.particles,
//     required this.animationValue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (final particle in particles) {
//       final paint = Paint()
//         ..color = QuickAIColors.cyber.accent.withOpacity(
//           particle.opacity * animationValue * 0.5,
//         )
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

//       final x = particle.x * size.width;
//       final y =
//           (particle.y + animationValue * particle.speed) % 1.0 * size.height;

//       canvas.drawCircle(Offset(x, y), particle.size * animationValue, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class Particle {
//   double x = Random().nextDouble();
//   double y = Random().nextDouble();
//   double speed = 0.5 + Random().nextDouble() * 0.5;
//   double size = 2 + Random().nextDouble() * 4;
//   double opacity = 0.1 + Random().nextDouble() * 0.3;
// }

/* ################################################################################################################# 

**************************                A I S C R E E N C O D E                ***********************************

###################################################################################################################### */

// import 'package:attendanceapp/database/database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/view_models/theme_view_model.dart';
// import '../core/view_models/button_view_model.dart';
// import '../core/view_models/common_view_model.dart';
// import '../core/widgets/custom_buttons.dart';
// import '../view_models/auth_view_model.dart';
// import '../services/geofencing_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   bool _obscurePassword = true;
//   bool _checkingLocation = false;
//   String _locationStatus = 'Verifying your location...';
//   Color _locationStatusColor = AppColors.warning;
//   String? _currentCity;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _checkInitialLocation();
//     _testDatabase();
//   }

//   void _testDatabase() async {
//     final dbHelper = DatabaseHelper();
//     await dbHelper.printAllUsers();
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
//           ),
//         );

//     _controller.forward();
//   }

//   Future<void> _checkInitialLocation() async {
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     setState(() {
//       _checkingLocation = true;
//     });

//     try {
//       final geofencingService = GeofencingService();
//       final locationCheck = await geofencingService.checkAllowedLocation();

//       setState(() {
//         _checkingLocation = false;
//         if (locationCheck['allowed']) {
//           _locationStatus = '✓ Location verified: ${locationCheck['city']}';
//           _locationStatusColor = AppColors.success;
//           _currentCity = locationCheck['city'];
//         } else {
//           _locationStatus = '✗ ${locationCheck['message']}';
//           _locationStatusColor = AppColors.error;
//           _currentCity = null;
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _checkingLocation = false;
//         _locationStatus = '✗ Error checking location: ${e.toString()}';
//         _locationStatusColor = AppColors.error;
//       });
//       commonState.setError('Location service error: $e');
//     }
//   }

//   Future<void> _handleLogin() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     final buttonState = Provider.of<ButtonState>(context, listen: false);
//     final commonState = Provider.of<CommonState>(context, listen: false);

//     if (!_formKey.currentState!.validate()) return;

//     // Check location before login
//     if (_locationStatusColor != AppColors.success) {
//       commonState.setError('Please verify your location before logging in');
//       return;
//     }

//     buttonState.setLoading(true);
//     commonState.setLoading(true, text: 'Signing you in...');

//     try {
//       final success = await authViewModel.login(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       if (success && mounted) {
//         commonState.setLoading(false);
//         buttonState.setLoading(false);

//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Welcome back, ${authViewModel.currentUser!.name}!'),
//             backgroundColor: AppColors.success,
//             duration: const Duration(seconds: 2),
//           ),
//         );

//         // Navigate to appropriate dashboard based on user type
//         authViewModel.navigateToDashboard(context);
//       } else if (!success) {
//         commonState.setError(authViewModel.errorMessage);
//         buttonState.setLoading(false);
//       }
//     } catch (e) {
//       commonState.setError('Login failed: ${e.toString()}');
//       buttonState.setLoading(false);
//     }
//   }

//   void _showLocationHelpDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Location Requirements'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'For security purposes, login is only allowed from the following locations:',
//             ),
//             const SizedBox(height: 16),
//             ...GeofencingService.getAllowedCities().map(
//               (city) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Row(
//                   children: [
//                     Icon(Icons.location_on, size: 16, color: AppColors.primary),
//                     const SizedBox(width: 8),
//                     Text(
//                       city,
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Please ensure you are in one of these areas and that location services are enabled.',
//               style: TextStyle(
//                 color:
//                     Theme.of(
//                       context,
//                     ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
//                     AppColors.textSecondary,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           CustomTextButton(
//             text: 'UNDERSTOOD',
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final commonState = Provider.of<CommonState>(context);

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               AppColors.primary,
//               AppColors.secondary,
//               AppColors.primaryLight,
//             ],
//             stops: const [0.0, 0.6, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: SlideTransition(
//               position: _slideAnimation,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     // Header Section
//                     _buildHeaderSection(),

//                     const SizedBox(height: 40),

//                     // Login Card
//                     _buildLoginCard(theme, commonState),

//                     const SizedBox(height: 30),

//                     // Footer
//                     _buildFooter(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       children: [
//         // Back Button and Theme Toggle
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               onPressed: () {
//                 // Handle back navigation if needed
//               },
//               icon: Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: AppColors.white.withOpacity(0.8),
//                 size: 20,
//               ),
//             ),
//             Consumer<AppTheme>(
//               builder: (context, theme, child) {
//                 return IconButton(
//                   onPressed: theme.toggleTheme,
//                   icon: Icon(
//                     theme.themeMode == ThemeMode.dark
//                         ? Icons.light_mode_rounded
//                         : Icons.dark_mode_rounded,
//                     color: AppColors.white.withOpacity(0.8),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),

//         const SizedBox(height: 20),

//         // Logo
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.black.withOpacity(0.1),
//                 blurRadius: 15,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Image.asset(
//               'assets/images/nutantek_logo.png',
//               width: 50,
//               height: 50,
//               errorBuilder: (context, error, stackTrace) {
//                 return Icon(
//                   Icons.business_center_rounded,
//                   size: 35,
//                   color: AppColors.primary,
//                 );
//               },
//             ),
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Welcome Text
//         Text(
//           'Welcome Back',
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: AppColors.white,
//             letterSpacing: 0.5,
//           ),
//         ),

//         const SizedBox(height: 8),

//         Text(
//           'Sign in to continue to your workspace',
//           style: TextStyle(
//             fontSize: 16,
//             color: AppColors.white.withOpacity(0.8),
//             letterSpacing: 0.3,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoginCard(AppTheme theme, CommonState commonState) {
//     final isLocationVerified = _locationStatusColor == AppColors.success;

//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Container(
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           color: theme.themeMode == ThemeMode.dark
//               ? AppColors.grey800
//               : AppColors.white,
//         ),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Location Status
//               _buildLocationStatusSection(isLocationVerified),

//               const SizedBox(height: 24),

//               // Email Field
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Work Email',
//                   hintText: 'your.email@nutantek.com',
//                   prefixIcon: Icon(
//                     Icons.email_rounded,
//                     color: AppColors.primary,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: _validateEmail,
//                 onChanged: (_) => commonState.clearError(),
//               ),

//               const SizedBox(height: 20),

//               // Password Field
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   prefixIcon: Icon(
//                     Icons.lock_rounded,
//                     color: AppColors.primary,
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                       color: AppColors.grey500,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: _validatePassword,
//                 onChanged: (_) => commonState.clearError(),
//               ),

//               const SizedBox(height: 8),

//               // Forgot Password
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: CustomTextButton(
//                   text: 'Forgot Password?',
//                   onPressed: () {
//                     // Handle forgot password
//                   },
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Login Button
//               PrimaryButton(
//                 text: 'SIGN IN TO WORKSPACE',
//                 onPressed: _handleLogin,
//                 icon: Icons.login_rounded,
//               ),

//               if (commonState.hasError) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.error.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: AppColors.error.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         color: AppColors.error,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           commonState.errorMessage,
//                           style: TextStyle(
//                             color: AppColors.error,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Validation methods
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }

//     final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

//     if (!emailRegex.hasMatch(value)) {
//       return 'Please enter a valid email address';
//     }

//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }

//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }

//     if (value.length > 128) {
//       return 'Password must be less than 128 characters';
//     }

//     return null;
//   }

//   Widget _buildLocationStatusSection(bool isLocationVerified) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: _locationStatusColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: _locationStatusColor.withOpacity(0.3)),
//           ),
//           child: Row(
//             children: [
//               _checkingLocation
//                   ? SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           _locationStatusColor,
//                         ),
//                       ),
//                     )
//                   : Icon(
//                       isLocationVerified
//                           ? Icons.verified_rounded
//                           : Icons.error_rounded,
//                       color: _locationStatusColor,
//                       size: 16,
//                     ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       isLocationVerified
//                           ? 'Location Verified'
//                           : 'Location Required',
//                       style: TextStyle(
//                         color: _locationStatusColor,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       _locationStatus,
//                       style: TextStyle(
//                         color: _locationStatusColor,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.refresh_rounded, size: 16),
//                 onPressed: _checkingLocation ? null : _checkInitialLocation,
//                 color: _locationStatusColor,
//               ),
//               IconButton(
//                 icon: Icon(Icons.help_outline_rounded, size: 16),
//                 onPressed: _showLocationHelpDialog,
//                 color: _locationStatusColor,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFooter() {
//     return Column(
//       children: [
//         Text(
//           '© 2024 Nutantek. All rights reserved.',
//           style: TextStyle(
//             color: AppColors.white.withOpacity(0.6),
//             fontSize: 12,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'Secure Enterprise Platform • v1.0.0',
//           style: TextStyle(
//             color: AppColors.white.withOpacity(0.4),
//             fontSize: 10,
//           ),
//         ),
//       ],
//     );
//   }
// }
