// import 'dart:async';
// import 'dart:math';
// import 'dart:ui';
// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/view_models/common_view_model.dart';
// import '../services/ai_auth_service.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _otpController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;

//   bool _isLoading = false;
//   bool _otpSent = false;
//   bool _passwordReset = false;
//   int _resendTimer = 60;
//   bool _canResend = false;
//   String _currentStep = 'email'; // 'email', 'otp', 'password'

//   // AI-Powered Security
//   final AIAuthService _aiAuthService = AIAuthService();
//   List<String> _aiInsights = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
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

//   Future<void> _sendOTP() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // AI-Powered Email Analysis
//       final emailAnalysis = await _aiAuthService.analyzeEmailPattern(
//         _emailController.text.trim(),
//       );

//       if (emailAnalysis['suspicious'] as bool) {
//         _showError('Security Alert: ${emailAnalysis['reason']}');
//         return;
//       }

//       // Simulate OTP sending
//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isLoading = false;
//         _otpSent = true;
//         _currentStep = 'otp';
//         _aiInsights = [
//           'OTP generated successfully',
//           'Security verification activated',
//           'Email pattern validated',
//         ];
//       });

//       _startResendTimer();

//       // Show success message
//       _showSuccess('OTP sent to your email');
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showError('Failed to send OTP: ${e.toString()}');
//     }
//   }

//   Future<void> _verifyOTP() async {
//     if (_otpController.text.isEmpty || _otpController.text.length != 6) {
//       _showError('Please enter a valid 6-digit OTP');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Simulate OTP verification
//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isLoading = false;
//         _currentStep = 'password';
//         _aiInsights.add('OTP verified successfully');
//         _aiInsights.add('Security clearance granted');
//       });

//       _showSuccess('OTP verified successfully');
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showError('Invalid OTP. Please try again.');
//     }
//   }

//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       _showError('Passwords do not match');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // AI-Powered Password Strength Analysis
//       final strengthAnalysis = _aiAuthService.analyzePasswordStrength(
//         _newPasswordController.text,
//       );

//       if (!(strengthAnalysis['strong'] as bool)) {
//         _showError('Password too weak: ${strengthAnalysis['suggestion']}');
//         return;
//       }

//       // Simulate password reset
//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isLoading = false;
//         _passwordReset = true;
//         _aiInsights.add('Password reset completed');
//         _aiInsights.add('Security protocols updated');
//       });

//       _showSuccess('Password reset successfully!');

//       // Navigate back after success
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showError('Failed to reset password: ${e.toString()}');
//     }
//   }

//   void _startResendTimer() {
//     setState(() {
//       _resendTimer = 60;
//       _canResend = false;
//     });

//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         setState(() {
//           _resendTimer--;
//         });
//       } else {
//         setState(() {
//           _canResend = true;
//         });
//         timer.cancel();
//       }
//     });
//   }

//   void _resendOTP() {
//     if (!_canResend) return;

//     _sendOTP();
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_rounded, color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.check_circle_rounded,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _goBack() {
//     if (_currentStep == 'otp') {
//       setState(() {
//         _currentStep = 'email';
//         _otpSent = false;
//         _otpController.clear();
//       });
//     } else if (_currentStep == 'password') {
//       setState(() {
//         _currentStep = 'otp';
//         _newPasswordController.clear();
//         _confirmPasswordController.clear();
//       });
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _otpController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       body: SafeArea(
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         // Header
//                         _buildAppleHeader(theme),
//                         const SizedBox(height: 32),
//                         // Main Card
//                         _buildAppleCard(theme),
//                         const SizedBox(height: 24),
//                         // AI Insights
//                         if (_aiInsights.isNotEmpty) _buildAIInsights(theme),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildAppleHeader(ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Back Button and Title
//         Row(
//           children: [
//             IconButton(
//               onPressed: _goBack,
//               icon: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.surface,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   Icons.arrow_back_rounded,
//                   color: theme.colorScheme.onSurface,
//                   size: 20,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _getStepTitle(),
//                     style: TextStyle(
//                       color: theme.colorScheme.onBackground,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _getStepSubtitle(),
//                     style: TextStyle(
//                       color: theme.colorScheme.onBackground.withOpacity(0.7),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Step Indicator
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 _getStepIndicator(),
//                 style: TextStyle(
//                   color: theme.colorScheme.primary,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   String _getStepTitle() {
//     switch (_currentStep) {
//       case 'email':
//         return 'Reset Password';
//       case 'otp':
//         return 'Verify Identity';
//       case 'password':
//         return 'New Password';
//       default:
//         return 'Password Recovery';
//     }
//   }

//   String _getStepSubtitle() {
//     switch (_currentStep) {
//       case 'email':
//         return 'Enter your email to begin recovery';
//       case 'otp':
//         return 'Enter the 6-digit code sent to your email';
//       case 'password':
//         return 'Create your new password';
//       default:
//         return 'Secure password recovery process';
//     }
//   }

//   String _getStepIndicator() {
//     switch (_currentStep) {
//       case 'email':
//         return 'Step 1/3';
//       case 'otp':
//         return 'Step 2/3';
//       case 'password':
//         return 'Step 3/3';
//       default:
//         return 'Step 1/3';
//     }
//   }

//   Widget _buildAppleCard(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           if (theme.brightness == Brightness.light)
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Security Info
//             _buildSecurityInfo(theme),
//             const SizedBox(height: 24),
//             // Current Step Content
//             _buildStepContent(theme),
//             const SizedBox(height: 24),
//             // Action Button
//             _buildActionButton(theme),
//             if (_currentStep == 'otp') ...[
//               const SizedBox(height: 16),
//               _buildResendOTP(theme),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSecurityInfo(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(_getSecurityIcon(), color: theme.colorScheme.primary, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _getSecurityTitle(),
//                   style: TextStyle(
//                     color: theme.colorScheme.primary,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   _getSecuritySubtitle(),
//                   style: TextStyle(
//                     color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getSecurityIcon() {
//     switch (_currentStep) {
//       case 'email':
//         return Icons.security_rounded;
//       case 'otp':
//         return Icons.verified_user_rounded;
//       case 'password':
//         return Icons.lock_reset_rounded;
//       default:
//         return Icons.security_rounded;
//     }
//   }

//   String _getSecurityTitle() {
//     switch (_currentStep) {
//       case 'email':
//         return 'Security Verification';
//       case 'otp':
//         return 'OTP Sent Successfully';
//       case 'password':
//         return 'Create New Password';
//       default:
//         return 'Security Check';
//     }
//   }

//   String _getSecuritySubtitle() {
//     switch (_currentStep) {
//       case 'email':
//         return 'AI-powered identity verification';
//       case 'otp':
//         return 'Check your email for the 6-digit code';
//       case 'password':
//         return 'Create a strong new password';
//       default:
//         return 'Secure verification process';
//     }
//   }

//   Widget _buildStepContent(ThemeData theme) {
//     switch (_currentStep) {
//       case 'email':
//         return _buildEmailStep(theme);
//       case 'otp':
//         return _buildOTPStep(theme);
//       case 'password':
//         return _buildPasswordStep(theme);
//       default:
//         return _buildEmailStep(theme);
//     }
//   }

//   Widget _buildEmailStep(ThemeData theme) {
//     return TextFormField(
//       controller: _emailController,
//       keyboardType: TextInputType.emailAddress,
//       style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
//       decoration: InputDecoration(
//         labelText: 'Email',
//         labelStyle: TextStyle(
//           color: theme.colorScheme.onSurface.withOpacity(0.7),
//         ),
//         hintText: 'your.email@nutantek.com',
//         hintStyle: TextStyle(
//           color: theme.colorScheme.onSurface.withOpacity(0.5),
//         ),
//         prefixIcon: Icon(Icons.email_rounded, color: theme.colorScheme.primary),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         filled: true,
//         fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Email is required';
//         }
//         final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
//         if (!emailRegex.hasMatch(value)) {
//           return 'Please enter a valid email';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildOTPStep(ThemeData theme) {
//     return TextFormField(
//       controller: _otpController,
//       keyboardType: TextInputType.number,
//       maxLength: 6,
//       style: TextStyle(
//         color: theme.colorScheme.onSurface,
//         fontSize: 18,
//         letterSpacing: 4,
//       ),
//       textAlign: TextAlign.center,
//       decoration: InputDecoration(
//         labelText: 'Enter 6-digit OTP',
//         labelStyle: TextStyle(
//           color: theme.colorScheme.onSurface.withOpacity(0.7),
//         ),
//         hintText: '••••••',
//         hintStyle: TextStyle(
//           color: theme.colorScheme.onSurface.withOpacity(0.3),
//           letterSpacing: 4,
//         ),
//         counterText: '',
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         filled: true,
//         fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
//       ),
//     );
//   }

//   Widget _buildPasswordStep(ThemeData theme) {
//     return Column(
//       children: [
//         // New Password
//         TextFormField(
//           controller: _newPasswordController,
//           obscureText: true,
//           style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
//           decoration: InputDecoration(
//             labelText: 'New Password',
//             labelStyle: TextStyle(
//               color: theme.colorScheme.onSurface.withOpacity(0.7),
//             ),
//             hintText: 'Enter new password',
//             hintStyle: TextStyle(
//               color: theme.colorScheme.onSurface.withOpacity(0.5),
//             ),
//             prefixIcon: Icon(
//               Icons.lock_rounded,
//               color: theme.colorScheme.primary,
//             ),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'New password is required';
//             }
//             if (value.length < 6) {
//               return 'Password must be at least 6 characters';
//             }
//             return null;
//           },
//         ),
//         const SizedBox(height: 16),
//         // Confirm Password
//         TextFormField(
//           controller: _confirmPasswordController,
//           obscureText: true,
//           style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
//           decoration: InputDecoration(
//             labelText: 'Confirm Password',
//             labelStyle: TextStyle(
//               color: theme.colorScheme.onSurface.withOpacity(0.7),
//             ),
//             hintText: 'Confirm new password',
//             hintStyle: TextStyle(
//               color: theme.colorScheme.onSurface.withOpacity(0.5),
//             ),
//             prefixIcon: Icon(
//               Icons.lock_rounded,
//               color: theme.colorScheme.primary,
//             ),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please confirm your password';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton(ThemeData theme) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _handleAction,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: theme.colorScheme.primary,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//         child: _isLoading
//             ? SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(_getActionIcon(), size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     _getActionText(),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   IconData _getActionIcon() {
//     switch (_currentStep) {
//       case 'email':
//         return Icons.send_rounded;
//       case 'otp':
//         return Icons.verified_rounded;
//       case 'password':
//         return Icons.lock_reset_rounded;
//       default:
//         return Icons.send_rounded;
//     }
//   }

//   String _getActionText() {
//     switch (_currentStep) {
//       case 'email':
//         return 'Send OTP';
//       case 'otp':
//         return 'Verify OTP';
//       case 'password':
//         return 'Reset Password';
//       default:
//         return 'Continue';
//     }
//   }

//   void _handleAction() {
//     switch (_currentStep) {
//       case 'email':
//         _sendOTP();
//         break;
//       case 'otp':
//         _verifyOTP();
//         break;
//       case 'password':
//         _resetPassword();
//         break;
//     }
//   }

//   Widget _buildResendOTP(ThemeData theme) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Didn\'t receive code? ',
//           style: TextStyle(
//             color: theme.colorScheme.onSurface.withOpacity(0.6),
//             fontSize: 14,
//           ),
//         ),
//         if (!_canResend)
//           Text(
//             'Resend in $_resendTimer s',
//             style: TextStyle(
//               color: theme.colorScheme.primary,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         if (_canResend)
//           TextButton(
//             onPressed: _resendOTP,
//             style: TextButton.styleFrom(
//               padding: EdgeInsets.zero,
//               minimumSize: Size.zero,
//             ),
//             child: Text(
//               'Resend OTP',
//               style: TextStyle(
//                 color: theme.colorScheme.primary,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAIInsights(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.info_rounded,
//                 color: theme.colorScheme.primary,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Security Insights',
//                 style: TextStyle(
//                   color: theme.colorScheme.onSurface,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ..._aiInsights.map(
//             (insight) => Padding(
//               padding: const EdgeInsets.only(bottom: 6),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.circle_rounded,
//                     size: 6,
//                     color: theme.colorScheme.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       insight,
//                       style: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.8),
//                         fontSize: 13,
//                       ),
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
// }

/*  ###############################################################################################################

***********************************         A I S C R E E N C O D E         **************************************

################################################################################################################## */

// import 'dart:async';
// import 'dart:math';
// import 'dart:ui';
// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/view_models/common_view_model.dart';
// import '../services/ai_auth_service.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _otpController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _neuralAnimation;

//   bool _isLoading = false;
//   bool _otpSent = false;
//   bool _passwordReset = false;
//   int _resendTimer = 60;
//   bool _canResend = false;
//   String _currentStep = 'email'; // 'email', 'otp', 'password'

//   // AI-Powered Security
//   final AIAuthService _aiAuthService = AIAuthService();
//   List<String> _aiInsights = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
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

//     _neuralAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
//       ),
//     );

//     _controller.forward();
//   }

//   Future<void> _sendOTP() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // AI-Powered Email Analysis
//       final emailAnalysis = await _aiAuthService.analyzeEmailPattern(
//         _emailController.text.trim(),
//       );

//       if (emailAnalysis['suspicious'] as bool) {
//         _showError('AI Security Alert: ${emailAnalysis['reason']}');
//         return;
//       }

//       // Simulate OTP sending
//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isLoading = false;
//         _otpSent = true;
//         _currentStep = 'otp';
//         _aiInsights = [
//           'Quantum OTP generated successfully',
//           'Neural security verification activated',
//           'Email pattern validated by AI',
//         ];
//       });

//       _startResendTimer();

//       // Show success message
//       _showSuccess('Quantum OTP sent to your email');
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showError('Failed to send OTP: ${e.toString()}');
//     }
//   }

//   Future<void> _verifyOTP() async {
//     if (_otpController.text.isEmpty || _otpController.text.length != 6) {
//       _showError('Please enter a valid 6-digit OTP');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Simulate OTP verification
//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isLoading = false;
//         _currentStep = 'password';
//         _aiInsights.add('OTP verified successfully');
//         _aiInsights.add('Quantum security clearance granted');
//       });

//       _showSuccess('OTP verified successfully');
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showError('Invalid OTP. Please try again.');
//     }
//   }

//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       _showError('Passwords do not match');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // AI-Powered Password Strength Analysis
//       final strengthAnalysis = _aiAuthService.analyzePasswordStrength(
//         _newPasswordController.text,
//       );

//       if (!(strengthAnalysis['strong'] as bool)) {
//         _showError('Password too weak: ${strengthAnalysis['suggestion']}');
//         return;
//       }

//       // Simulate password reset
//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isLoading = false;
//         _passwordReset = true;
//         _aiInsights.add('Quantum password reset completed');
//         _aiInsights.add('Neural security protocols updated');
//       });

//       _showSuccess('Password reset successfully!');

//       // Navigate back after success
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showError('Failed to reset password: ${e.toString()}');
//     }
//   }

//   void _startResendTimer() {
//     setState(() {
//       _resendTimer = 60;
//       _canResend = false;
//     });

//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         setState(() {
//           _resendTimer--;
//         });
//       } else {
//         setState(() {
//           _canResend = true;
//         });
//         timer.cancel();
//       }
//     });
//   }

//   void _resendOTP() {
//     if (!_canResend) return;

//     _sendOTP();
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_rounded, color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: QuickAIColors.cyber.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: QuickAIColors.cyber.accent,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _goBack() {
//     if (_currentStep == 'otp') {
//       setState(() {
//         _currentStep = 'email';
//         _otpSent = false;
//         _otpController.clear();
//       });
//     } else if (_currentStep == 'password') {
//       setState(() {
//         _currentStep = 'otp';
//         _newPasswordController.clear();
//         _confirmPasswordController.clear();
//       });
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _otpController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Background
//           _buildQuantumBackground(),

//           // Neural Animation
//           _buildNeuralAnimation(),

//           // Main Content
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
//                             // Header
//                             _buildHeader(),

//                             const SizedBox(height: 40),

//                             // Main Card
//                             _buildMainCard(),

//                             const SizedBox(height: 30),

//                             // AI Insights
//                             if (_aiInsights.isNotEmpty) _buildAIInsights(),

//                             const SizedBox(height: 20),
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

//   Widget _buildQuantumBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: RadialGradient(
//           center: Alignment.topLeft,
//           radius: 2.0,
//           colors: [
//             QuickAIColors.cyber.primary.withOpacity(0.2),
//             QuickAIColors.cyber.secondary.withOpacity(0.1),
//             Colors.black,
//           ],
//           stops: const [0.0, 0.5, 1.0],
//         ),
//       ),
//     );
//   }

//   Widget _buildNeuralAnimation() {
//     return AnimatedBuilder(
//       animation: _neuralAnimation,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: _ForgotPasswordNeuralPainter(
//             animationValue: _neuralAnimation.value,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         IconButton(
//           onPressed: _goBack,
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.arrow_back_rounded,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _getStepTitle(),
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 _getStepSubtitle(),
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.7),
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Step Indicator
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.white.withOpacity(0.2)),
//           ),
//           child: Text(
//             _getStepIndicator(),
//             style: TextStyle(
//               color: QuickAIColors.cyber.accent,
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.0,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _getStepTitle() {
//     switch (_currentStep) {
//       case 'email':
//         return 'QUANTUM RECOVERY';
//       case 'otp':
//         return 'VERIFY IDENTITY';
//       case 'password':
//         return 'NEW PASSWORD';
//       default:
//         return 'PASSWORD RECOVERY';
//     }
//   }

//   String _getStepSubtitle() {
//     switch (_currentStep) {
//       case 'email':
//         return 'Enter your quantum email to begin recovery';
//       case 'otp':
//         return 'Enter the 6-digit code sent to your email';
//       case 'password':
//         return 'Create your new quantum password';
//       default:
//         return 'Secure password recovery process';
//     }
//   }

//   String _getStepIndicator() {
//     switch (_currentStep) {
//       case 'email':
//         return 'STEP 1/3';
//       case 'otp':
//         return 'STEP 2/3';
//       case 'password':
//         return 'STEP 3/3';
//       default:
//         return 'STEP 1/3';
//     }
//   }

//   Widget _buildMainCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 40,
//             offset: const Offset(0, 20),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(28),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
//           child: Container(
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.15),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.5,
//               ),
//               borderRadius: BorderRadius.circular(28),
//             ),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // Current Step Content
//                   _buildStepContent(),

//                   const SizedBox(height: 32),

//                   // Action Button
//                   _buildActionButton(),

//                   if (_currentStep == 'otp') ...[
//                     const SizedBox(height: 20),
//                     _buildResendOTP(),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStepContent() {
//     switch (_currentStep) {
//       case 'email':
//         return _buildEmailStep();
//       case 'otp':
//         return _buildOTPStep();
//       case 'password':
//         return _buildPasswordStep();
//       default:
//         return _buildEmailStep();
//     }
//   }

//   Widget _buildEmailStep() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: QuickAIColors.cyber.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: QuickAIColors.cyber.primary.withOpacity(0.3),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.security_rounded,
//                 color: QuickAIColors.cyber.accent,
//                 size: 24,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'QUANTUM SECURITY',
//                       style: TextStyle(
//                         color: QuickAIColors.cyber.accent,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 1.0,
//                       ),
//                     ),
//                     Text(
//                       'AI-powered identity verification',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 24),
//         TextFormField(
//           controller: _emailController,
//           keyboardType: TextInputType.emailAddress,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             labelText: 'QUANTUM EMAIL',
//             labelStyle: TextStyle(
//               color: QuickAIColors.cyber.primary,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.5,
//             ),
//             hintText: 'your.email@nutantek.com',
//             hintStyle: TextStyle(
//               color: Colors.white.withOpacity(0.5),
//               fontWeight: FontWeight.w400,
//             ),
//             prefixIcon: Container(
//               margin: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: QuickAIColors.cyber.primary.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.email_rounded,
//                 color: QuickAIColors.cyber.primary,
//                 size: 22,
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.1),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 18,
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Quantum email is required';
//             }
//             final emailRegex = RegExp(
//               r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
//             );
//             if (!emailRegex.hasMatch(value)) {
//               return 'Please enter a valid quantum email';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildOTPStep() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: QuickAIColors.cyber.accent.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: QuickAIColors.cyber.accent.withOpacity(0.3),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.verified_user_rounded,
//                 color: QuickAIColors.cyber.accent,
//                 size: 24,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'OTP SENT SUCCESSFULLY',
//                       style: TextStyle(
//                         color: QuickAIColors.cyber.accent,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 1.0,
//                       ),
//                     ),
//                     Text(
//                       'Check your email for the 6-digit code',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 24),
//         TextFormField(
//           controller: _otpController,
//           keyboardType: TextInputType.number,
//           maxLength: 6,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//             fontSize: 18,
//             letterSpacing: 4,
//           ),
//           textAlign: TextAlign.center,
//           decoration: InputDecoration(
//             labelText: 'ENTER 6-DIGIT OTP',
//             labelStyle: TextStyle(
//               color: QuickAIColors.cyber.primary,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.5,
//             ),
//             hintText: '••••••',
//             hintStyle: TextStyle(
//               color: Colors.white.withOpacity(0.3),
//               fontWeight: FontWeight.w400,
//               letterSpacing: 4,
//             ),
//             counterText: '',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.1),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 18,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPasswordStep() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: QuickAIColors.cyber.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: QuickAIColors.cyber.primary.withOpacity(0.3),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.lock_reset_rounded,
//                 color: QuickAIColors.cyber.accent,
//                 size: 24,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'QUANTUM PASSWORD',
//                       style: TextStyle(
//                         color: QuickAIColors.cyber.accent,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 1.0,
//                       ),
//                     ),
//                     Text(
//                       'Create a strong new password',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 24),
//         // New Password
//         TextFormField(
//           controller: _newPasswordController,
//           obscureText: true,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             labelText: 'NEW QUANTUM PASSWORD',
//             labelStyle: TextStyle(
//               color: QuickAIColors.cyber.primary,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.5,
//             ),
//             hintText: 'Enter new password',
//             hintStyle: TextStyle(
//               color: Colors.white.withOpacity(0.5),
//               fontWeight: FontWeight.w400,
//             ),
//             prefixIcon: Container(
//               margin: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: QuickAIColors.cyber.primary.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.lock_rounded,
//                 color: QuickAIColors.cyber.primary,
//                 size: 22,
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.1),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 18,
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'New password is required';
//             }
//             if (value.length < 6) {
//               return 'Password must be at least 6 characters';
//             }
//             return null;
//           },
//         ),
//         const SizedBox(height: 20),
//         // Confirm Password
//         TextFormField(
//           controller: _confirmPasswordController,
//           obscureText: true,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             labelText: 'CONFIRM QUANTUM PASSWORD',
//             labelStyle: TextStyle(
//               color: QuickAIColors.cyber.primary,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.5,
//             ),
//             hintText: 'Confirm new password',
//             hintStyle: TextStyle(
//               color: Colors.white.withOpacity(0.5),
//               fontWeight: FontWeight.w400,
//             ),
//             prefixIcon: Container(
//               margin: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: QuickAIColors.cyber.primary.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.lock_rounded,
//                 color: QuickAIColors.cyber.primary,
//                 size: 22,
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.1),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 18,
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please confirm your password';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton() {
//     return Container(
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [QuickAIColors.cyber.primary, QuickAIColors.cyber.secondary],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: QuickAIColors.cyber.primary.withOpacity(0.6),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _isLoading ? null : _handleAction,
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(_getActionIcon(), color: Colors.white, size: 20),
//                     const SizedBox(width: 12),
//                     Text(
//                       _getActionText(),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (_isLoading)
//                 Positioned(
//                   right: 20,
//                   child: Container(
//                     width: 20,
//                     height: 20,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getActionIcon() {
//     switch (_currentStep) {
//       case 'email':
//         return Icons.send_rounded;
//       case 'otp':
//         return Icons.verified_rounded;
//       case 'password':
//         return Icons.lock_reset_rounded;
//       default:
//         return Icons.send_rounded;
//     }
//   }

//   String _getActionText() {
//     switch (_currentStep) {
//       case 'email':
//         return 'SEND QUANTUM OTP';
//       case 'otp':
//         return 'VERIFY IDENTITY';
//       case 'password':
//         return 'RESET PASSWORD';
//       default:
//         return 'CONTINUE';
//     }
//   }

//   void _handleAction() {
//     switch (_currentStep) {
//       case 'email':
//         _sendOTP();
//         break;
//       case 'otp':
//         _verifyOTP();
//         break;
//       case 'password':
//         _resetPassword();
//         break;
//     }
//   }

//   Widget _buildResendOTP() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Didn\'t receive code? ',
//           style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
//         ),
//         if (!_canResend)
//           Text(
//             'Resend in $_resendTimer s',
//             style: TextStyle(
//               color: QuickAIColors.cyber.accent,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         if (_canResend)
//           TextButton(
//             onPressed: _resendOTP,
//             style: TextButton.styleFrom(
//               padding: EdgeInsets.zero,
//               minimumSize: Size.zero,
//               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             ),
//             child: Text(
//               'RESEND OTP',
//               style: TextStyle(
//                 color: QuickAIColors.cyber.accent,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.8,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAIInsights() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.psychology_rounded,
//                 color: QuickAIColors.cyber.accent,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'NEURAL INSIGHTS',
//                 style: TextStyle(
//                   color: QuickAIColors.cyber.accent,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 1.0,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ..._aiInsights.map(
//             (insight) => Padding(
//               padding: const EdgeInsets.only(bottom: 6),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.fiber_manual_record_rounded,
//                     size: 8,
//                     color: QuickAIColors.cyber.accent,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       insight,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 13,
//                       ),
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
// }

// class _ForgotPasswordNeuralPainter extends CustomPainter {
//   final double animationValue;

//   _ForgotPasswordNeuralPainter({required this.animationValue});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final maxRadius = size.width * 0.3;

//     // Draw neural connections
//     for (int i = 0; i < 8; i++) {
//       final angle = (i / 8) * 2 * pi;
//       final x = center.dx + cos(angle) * maxRadius;
//       final y = center.dy + sin(angle) * maxRadius;

//       // Create pulsating nodes
//       final nodePaint = Paint()
//         ..color = QuickAIColors.cyber.accent.withOpacity(0.6 * animationValue)
//         ..style = PaintingStyle.fill
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * animationValue);

//       final nodeSize = 2 + 2 * sin(animationValue * pi * 2 + i);
//       canvas.drawCircle(Offset(x, y), nodeSize, nodePaint);

//       // Draw connections to center
//       final connectionPaint = Paint()
//         ..color = QuickAIColors.cyber.primary.withOpacity(0.3 * animationValue)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.0
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

//       canvas.drawLine(center, Offset(x, y), connectionPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
