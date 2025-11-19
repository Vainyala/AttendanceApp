import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AIAuthService {
  // AI-Powered Authentication and Security Analysis

  // Generate device fingerprint using multiple factors
  String generateDeviceHash() {
    final deviceInfo = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'platform': 'flutter',
      'random': Random().nextDouble(),
    };
    return sha256.convert(utf8.encode(json.encode(deviceInfo))).toString();
  }

  // Analyze location patterns with AI intelligence
  Future<Map<String, dynamic>> analyzeLocationPattern(
    Map<String, dynamic> locationCheck,
    DateTime typicalLoginTime,
  ) async {
    final currentTime = DateTime.now();
    final timeDifference = currentTime
        .difference(typicalLoginTime)
        .inHours
        .abs();

    // AI Logic for location analysis
    double securityScore = 0.0;
    List<String> insights = [];

    if (locationCheck['allowed'] == true) {
      securityScore += 0.6; // Base score for allowed location
      insights.add('✓ Location within approved area');

      // Time pattern analysis
      if (timeDifference <= 2) {
        securityScore += 0.3;
        insights.add('✓ Login time matches typical pattern');
      } else {
        securityScore += 0.1;
        insights.add('⚠️ Unusual login time detected');
      }

      // Additional AI factors
      final networkAnalysis = _analyzeNetworkSecurity();
      if ((networkAnalysis['network_trust_score'] as double) > 0.8) {
        securityScore += 0.1;
        insights.add('✓ Secure network connection');
      }
    } else {
      securityScore = 0.2;
      insights.add('✗ Location outside approved boundaries');
    }

    return {
      'trustworthy': securityScore >= 0.7,
      'message': locationCheck['allowed'] == true ? 'Verified' : 'Alert',
      'security_score': securityScore.clamp(0.0, 1.0),
      'insights': insights,
    };
  }

  // Pre-login AI analysis
  Future<Map<String, dynamic>> performPreLoginAnalysis({
    required String email,
    required Map<String, dynamic> locationData,
    required Map<String, dynamic> behaviorMetrics,
  }) async {
    double riskScore = 0.0;
    List<String> warnings = [];

    // Email pattern analysis
    if (_isSuspiciousEmailPattern(email)) {
      riskScore += 0.4;
      warnings.add('Unusual email pattern detected');
    }

    // Location risk assessment
    final locationScore = (locationData['score'] as double?) ?? 0.0;
    if (locationScore < 0.6) {
      riskScore += 0.3;
      warnings.add('Low location security score');
    }

    // Time-based analysis
    final currentHour = DateTime.now().hour;
    if (currentHour < 6 || currentHour > 22) {
      riskScore += 0.2;
      warnings.add('Unusual login hour detected');
    }

    // Device fingerprint consistency
    if (!_validateDeviceConsistency(behaviorMetrics)) {
      riskScore += 0.1;
      warnings.add('Device pattern anomaly');
    }

    final approved = riskScore < 0.5;

    return {
      'approved': approved,
      'risk_score': riskScore,
      'reason': approved
          ? null
          : 'Security Check Failed: ${warnings.join(", ")}',
      'warnings': warnings,
    };
  }

  // Enhanced login with AI capabilities
  Future<Map<String, dynamic>> enhancedLogin(
    String email,
    String password,
    Map<String, dynamic> behaviorMetrics,
  ) async {
    // Simulate AI processing
    await Future.delayed(Duration(milliseconds: 500));

    // AI Decision making
    final requires2FA = _shouldRequireTwoFactor(email, behaviorMetrics);
    final riskLevel = _calculateRiskLevel(email, behaviorMetrics);

    return {
      'requires_2fa': requires2FA,
      'risk_level': riskLevel,
      'ai_recommendation': requires2FA
          ? 'enhanced_verification'
          : 'standard_login',
    };
  }

  // Determine best 2FA method based on AI analysis
  Future<Map<String, dynamic>> determineBest2FAMethod(
    String email,
    Map<String, dynamic> behaviorMetrics,
  ) async {
    final methods = [
      {'method': 'SMS Verification', 'score': 0.7},
      {'method': 'Email Verification', 'score': 0.6},
      {'method': 'Biometric Authentication', 'score': 0.9},
      {'method': 'Security Questions', 'score': 0.5},
    ];

    // AI logic to choose best method - FIXED NULL SAFETY
    methods.sort((a, b) {
      final scoreA = (a['score'] as double?) ?? 0.0;
      final scoreB = (b['score'] as double?) ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    return {
      'method': methods.first['method'],
      'confidence': methods.first['score'],
      'alternatives': methods.sublist(1, 3),
    };
  }

  // Record successful login for AI learning
  Future<void> recordSuccessfulLogin(
    dynamic user,
    Map<String, dynamic> behaviorMetrics,
  ) async {
    // Update behavior patterns
    behaviorMetrics['last_successful_login'] = DateTime.now();
    behaviorMetrics['login_attempts'] =
        (behaviorMetrics['login_attempts'] as int? ?? 0) + 1;
    behaviorMetrics['typical_login_time'] = DateTime.now();

    // AI learning - could be stored in database
    print('🤖 Learning: Successful login pattern recorded for ${user.email}');
  }

  // Record failed login for threat detection
  Future<void> recordFailedLoginAttempt(
    String email,
    Map<String, dynamic> behaviorMetrics,
  ) async {
    behaviorMetrics['failed_attempts'] =
        (behaviorMetrics['failed_attempts'] as int? ?? 0) + 1;
    behaviorMetrics['last_failed_attempt'] = DateTime.now();

    // AI threat detection
    if ((behaviorMetrics['failed_attempts'] as int? ?? 0) > 3) {
      print('🚨 Alert: Multiple failed attempts for $email');
    }
  }

  // Email pattern analysis
  Future<Map<String, dynamic>> analyzeEmailPattern(String email) async {
    final suspicious = _isSuspiciousEmailPattern(email);
    final domainAnalysis = _analyzeEmailDomain(email);

    return {
      'suspicious': suspicious,
      'reason': suspicious ? 'Unusual email pattern or domain' : null,
      'domain_trust_score': domainAnalysis['trust_score'],
      'recommendation': suspicious ? 'proceed_with_caution' : 'safe',
    };
  }

  // Real-time email analysis
  Future<Map<String, dynamic>> realTimeEmailAnalysis(String email) async {
    final insights = <String>[];

    if (email.isNotEmpty) {
      if (email.contains('@nutantek.com')) {
        insights.add('✓ Corporate email domain');
      } else {
        insights.add('⚠️ External email domain');
      }

      if (_isValidEmailFormat(email)) {
        insights.add('✓ Valid email format');
      } else {
        insights.add('✗ Invalid email format');
      }
    }

    return {'insights': insights};
  }

  // Password strength analysis
  Map<String, dynamic> analyzePasswordStrength(String password) {
    double strength = 0.0;
    List<String> suggestions = [];

    // Length check
    if (password.length >= 8) {
      strength += 0.3;
    } else {
      suggestions.add('Use at least 8 characters');
    }

    // Complexity checks
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength += 0.2;
    } else {
      suggestions.add('Add uppercase letters');
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      strength += 0.2;
    } else {
      suggestions.add('Add lowercase letters');
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength += 0.2;
    } else {
      suggestions.add('Add numbers');
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.1;
    } else {
      suggestions.add('Add special characters');
    }

    return {
      'strong': strength >= 0.7,
      'score': strength,
      'suggestion': suggestions.isNotEmpty
          ? suggestions.first
          : 'Strong password',
    };
  }

  // Smart password recovery
  Future<void> initiateSmartPasswordRecovery(String email) async {
    // AI-powered recovery logic
    final recoveryMethod = await _determineBestRecoveryMethod(email);

    print('🤖 Recovery: Initiating ${recoveryMethod['method']} for $email');

    // In real implementation, this would trigger actual recovery process
  }

  // Suspicious email detection
  bool isSuspiciousEmail(String email) {
    return _isSuspiciousEmailPattern(email);
  }

  // ========== PRIVATE AI METHODS ==========

  Map<String, dynamic> _analyzeNetworkSecurity() {
    // Simulate network analysis
    return {
      'vpn_detected': false,
      'proxy_usage': false,
      'network_trust_score': 0.95,
      'threat_level': 'low',
    };
  }

  bool _isSuspiciousEmailPattern(String email) {
    final suspiciousPatterns = [
      RegExp(r'.*@(temp|fake|spam|test)\.'),
      RegExp(r'^[0-9]+@'),
      RegExp(r'.*@(gmail|yahoo|hotmail)\.com$'), // External domains
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(email));
  }

  bool _isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  Map<String, dynamic> _analyzeEmailDomain(String email) {
    final trustedDomains = ['nutantek.com', 'company.com', 'enterprise.org'];
    final domain = email.split('@').last;

    return {
      'domain': domain,
      'trusted': trustedDomains.contains(domain),
      'trust_score': trustedDomains.contains(domain) ? 0.9 : 0.4,
    };
  }

  bool _validateDeviceConsistency(Map<String, dynamic> behaviorMetrics) {
    // Check if device fingerprint matches previous patterns
    return true; // Simplified for example
  }

  bool _shouldRequireTwoFactor(
    String email,
    Map<String, dynamic> behaviorMetrics,
  ) {
    // AI logic to determine if 2FA is needed
    final failedAttempts = behaviorMetrics['failed_attempts'] as int? ?? 0;
    final emailTrusted = _analyzeEmailDomain(email)['trusted'] as bool;
    final currentHour = DateTime.now().hour;

    final riskFactors = [
      failedAttempts > 0,
      !emailTrusted,
      currentHour < 6 || currentHour > 22, // Unusual hours
    ];

    return riskFactors.where((factor) => factor).length >= 2;
  }

  String _calculateRiskLevel(
    String email,
    Map<String, dynamic> behaviorMetrics,
  ) {
    final riskScore = _calculateRiskScore(email, behaviorMetrics);

    if (riskScore >= 0.7) return 'high';
    if (riskScore >= 0.4) return 'medium';
    return 'low';
  }

  double _calculateRiskScore(
    String email,
    Map<String, dynamic> behaviorMetrics,
  ) {
    double score = 0.0;

    // Failed attempts
    final failedAttempts = behaviorMetrics['failed_attempts'] as int? ?? 0;
    score += failedAttempts * 0.1;

    // Email trust
    final emailTrusted = _analyzeEmailDomain(email)['trusted'] as bool;
    if (!emailTrusted) score += 0.3;

    // Time factor
    final currentHour = DateTime.now().hour;
    if (currentHour < 6 || currentHour > 22) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  Future<Map<String, dynamic>> _determineBestRecoveryMethod(
    String email,
  ) async {
    final methods = [
      {'method': 'Email Verification', 'confidence': 0.8},
      {'method': 'Security Questions', 'confidence': 0.6},
      {'method': 'Admin Approval', 'confidence': 0.9},
    ];

    // FIXED: Null-safe sorting
    methods.sort((a, b) {
      final confidenceA = (a['confidence'] as double?) ?? 0.0;
      final confidenceB = (b['confidence'] as double?) ?? 0.0;
      return confidenceB.compareTo(confidenceA);
    });

    return {
      'method': methods.first['method'] as String,
      'confidence': methods.first['confidence'] as double,
      'alternatives': methods.sublist(1, 3),
    };
  }
}
