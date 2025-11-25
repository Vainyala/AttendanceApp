import 'package:AttendanceApp/manager/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/view_models/common_view_model.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
    _debugDatabase();
  }

  void _debugDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.debugPrintUsers();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  void _initializeApp() async {
    try {
      final commonState = Provider.of<CommonState>(context, listen: false);
      await Future.delayed(const Duration(milliseconds: 2000));
      await _loadAppData();
      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  Future<void> _loadAppData() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final bool isDarkMode = theme.isDarkMode;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Safe colors for both themes
    final backgroundColor = isDarkMode
        ? Colors.black
        : AppColors.backgroundLight;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : AppColors.textSecondary;
    final subtleTextColor = isDarkMode
        ? Colors.white.withOpacity(0.5)
        : AppColors.textDisabled;
    final chipColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : AppColors.grey100;
    final chipBorderColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : AppColors.grey300;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
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
          child: Stack(
            children: [
              // Main content
              _buildMainContent(
                screenHeight,
                screenWidth,
                isLandscape,
                textColor,
                secondaryTextColor,
                chipColor,
                chipBorderColor,
              ),

              // Bottom copyright
              _buildCopyright(screenHeight, isLandscape, subtleTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    double screenHeight,
    double screenWidth,
    bool isLandscape,
    Color textColor,
    Color secondaryTextColor,
    Color chipColor,
    Color chipBorderColor,
  ) {
    return SingleChildScrollView(
      child: Container(
        width: screenWidth,
        height: isLandscape ? null : screenHeight,
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? screenWidth * 0.1 : 24.0,
          vertical: isLandscape ? 40.0 : 0.0,
        ),
        child: Column(
          mainAxisAlignment: isLandscape
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLandscape) SizedBox(height: screenHeight * 0.05),

            // Logo with scale animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildLogo(isLandscape, screenWidth),
            ),

            SizedBox(height: isLandscape ? 20 : 40),

            // App name with slide and fade animation
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildAppName(isLandscape, screenWidth, textColor),
              ),
            ),

            SizedBox(height: isLandscape ? 10 : 20),

            // Tagline with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTagline(
                isLandscape,
                screenWidth,
                secondaryTextColor,
                chipColor,
                chipBorderColor,
              ),
            ),

            SizedBox(height: isLandscape ? 30 : 60),

            if (isLandscape) SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isLandscape, double screenWidth) {
    final logoSize = isLandscape ? screenWidth * 0.12 : 100.0;

    return Container(
      width: logoSize,
      height: logoSize,
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
            width: logoSize * 0.6,
            height: logoSize * 0.6,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: logoSize * 0.6,
                height: logoSize * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_center_rounded,
                  size: logoSize * 0.4,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppName(bool isLandscape, double screenWidth, Color textColor) {
    final appNameFontSize = isLandscape ? screenWidth * 0.05 : 36.0;
    final proFontSize = isLandscape ? screenWidth * 0.018 : 14.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Nutantek',
          style: TextStyle(
            fontSize: appNameFontSize,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: isLandscape ? 4 : 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            'ATTENDANCE PRO',
            style: TextStyle(
              fontSize: proFontSize,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagline(
    bool isLandscape,
    double screenWidth,
    Color textColor,
    Color chipColor,
    Color chipBorderColor,
  ) {
    final mainTaglineFontSize = isLandscape ? screenWidth * 0.016 : 14.0;
    final subTaglineFontSize = isLandscape ? screenWidth * 0.012 : 11.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enterprise Workforce Management',
          style: TextStyle(
            fontSize: mainTaglineFontSize,
            fontWeight: FontWeight.w500,
            color: textColor,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isLandscape ? 6 : 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _buildFeatureChip(
              'Real-time Tracking',
              Icons.track_changes_rounded,
              chipColor,
              chipBorderColor,
            ),
            _buildFeatureChip(
              'Smart Analytics',
              Icons.analytics_rounded,
              chipColor,
              chipBorderColor,
            ),
            _buildFeatureChip(
              'Secure',
              Icons.security_rounded,
              chipColor,
              chipBorderColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(
    String text,
    IconData icon,
    Color chipColor,
    Color chipBorderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright(
    double screenHeight,
    bool isLandscape,
    Color textColor,
  ) {
    return Positioned(
      bottom: isLandscape ? 15 : 20,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '© 2024 Nutantek. All rights reserved.',
              style: TextStyle(
                color: textColor,
                fontSize: isLandscape ? 8 : 10,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isLandscape ? 1 : 2),
            Text(
              'ENTERPRISE EDITION v1.0.0',
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: isLandscape ? 7 : 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:AttendanceApp/database/database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/view_models/theme_view_model.dart';
// import '../core/view_models/common_view_model.dart';
// import 'login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeApp();
//     _debugDatabase();
//   }

//   void _debugDatabase() async {
//     final dbHelper = DatabaseHelper();
//     await dbHelper.debugPrintUsers();
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.5,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _controller.forward();
//   }

//   void _initializeApp() async {
//     try {
//       final commonState = Provider.of<CommonState>(context, listen: false);
//       await Future.delayed(const Duration(milliseconds: 2000));
//       await _loadAppData();
//       if (mounted) {
//         _navigateToLogin();
//       }
//     } catch (e) {
//       await Future.delayed(const Duration(milliseconds: 2000));
//       if (mounted) {
//         _navigateToLogin();
//       }
//     }
//   }

//   Future<void> _loadAppData() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//   }

//   void _navigateToLogin() {
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//             const LoginScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(1.0, 0.0);
//           const end = Offset.zero;
//           const curve = Curves.easeInOut;

//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//           var offsetAnimation = animation.drive(tween);

//           return SlideTransition(
//             position: offsetAnimation,
//             child: FadeTransition(opacity: animation, child: child),
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 800),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final isLandscape = mediaQuery.orientation == Orientation.landscape;
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: RadialGradient(
//               center: Alignment.topLeft,
//               radius: 2.0,
//               colors: [
//                 AppColors.primary.withOpacity(0.15),
//                 AppColors.secondary.withOpacity(0.1),
//                 Colors.black,
//               ],
//               stops: const [0.0, 0.5, 1.0],
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Main content
//               _buildMainContent(screenHeight, screenWidth, isLandscape),

//               // Bottom copyright
//               _buildCopyright(screenHeight, isLandscape),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent(
//     double screenHeight,
//     double screenWidth,
//     bool isLandscape,
//   ) {
//     return SingleChildScrollView(
//       child: Container(
//         width: screenWidth,
//         height: isLandscape ? null : screenHeight,
//         padding: EdgeInsets.symmetric(
//           horizontal: isLandscape ? screenWidth * 0.1 : 24.0,
//           vertical: isLandscape ? 40.0 : 0.0,
//         ),
//         child: Column(
//           mainAxisAlignment: isLandscape
//               ? MainAxisAlignment.start
//               : MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isLandscape) SizedBox(height: screenHeight * 0.05),

//             // Logo with scale animation
//             ScaleTransition(
//               scale: _scaleAnimation,
//               child: _buildLogo(isLandscape, screenWidth),
//             ),

//             SizedBox(height: isLandscape ? 20 : 40),

//             // App name with slide and fade animation
//             SlideTransition(
//               position: _slideAnimation,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: _buildAppName(isLandscape, screenWidth),
//               ),
//             ),

//             SizedBox(height: isLandscape ? 10 : 20),

//             // Tagline with fade animation
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildTagline(isLandscape, screenWidth),
//             ),

//             SizedBox(height: isLandscape ? 30 : 60),

//             if (isLandscape) SizedBox(height: screenHeight * 0.05),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLogo(bool isLandscape, double screenWidth) {
//     final logoSize = isLandscape ? screenWidth * 0.12 : 100.0;

//     return Container(
//       width: logoSize,
//       height: logoSize,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primary, AppColors.primaryLight],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.4),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Center(
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Image.asset(
//             'assets/images/nutantek_logo.png',
//             width: logoSize * 0.6,
//             height: logoSize * 0.6,
//             fit: BoxFit.contain,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 width: logoSize * 0.6,
//                 height: logoSize * 0.6,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.business_center_rounded,
//                   size: logoSize * 0.4,
//                   color: AppColors.primary,
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppName(bool isLandscape, double screenWidth) {
//     final appNameFontSize = isLandscape ? screenWidth * 0.05 : 36.0;
//     final proFontSize = isLandscape ? screenWidth * 0.018 : 14.0;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           'Nutantek',
//           style: TextStyle(
//             fontSize: appNameFontSize,
//             fontWeight: FontWeight.w800,
//             color: Colors.white,
//             letterSpacing: 1.5,
//           ),
//         ),
//         SizedBox(height: isLandscape ? 4 : 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//           ),
//           child: Text(
//             'ATTENDANCE PRO',
//             style: TextStyle(
//               fontSize: proFontSize,
//               fontWeight: FontWeight.w600,
//               color: Colors.white.withOpacity(0.9),
//               letterSpacing: 1.5,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTagline(bool isLandscape, double screenWidth) {
//     final mainTaglineFontSize = isLandscape ? screenWidth * 0.016 : 14.0;
//     final subTaglineFontSize = isLandscape ? screenWidth * 0.012 : 11.0;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           'Enterprise Workforce Management',
//           style: TextStyle(
//             fontSize: mainTaglineFontSize,
//             fontWeight: FontWeight.w500,
//             color: Colors.white.withOpacity(0.9),
//             letterSpacing: 0.8,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: isLandscape ? 6 : 10),
//         Wrap(
//           spacing: 8,
//           runSpacing: 4,
//           alignment: WrapAlignment.center,
//           children: [
//             _buildFeatureChip(
//               'Real-time Tracking',
//               Icons.track_changes_rounded,
//             ),
//             _buildFeatureChip('Smart Analytics', Icons.analytics_rounded),
//             _buildFeatureChip('Secure', Icons.security_rounded),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureChip(String text, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 10, color: AppColors.accent),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 9,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCopyright(double screenHeight, bool isLandscape) {
//     return Positioned(
//       bottom: isLandscape ? 15 : 20,
//       left: 0,
//       right: 0,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               '© 2024 Nutantek. All rights reserved.',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.5),
//                 fontSize: isLandscape ? 8 : 10,
//                 letterSpacing: 0.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: isLandscape ? 1 : 2),
//             Text(
//               'ENTERPRISE EDITION v1.0.0',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.4),
//                 fontSize: isLandscape ? 7 : 9,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* *************************************************************************************** */

// ##################           A I S C R E E N C O D E                 #####################

/* *************************************************************************************** */

// import 'dart:math';

// import 'package:AttendanceApp/database/database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/view_models/theme_view_model.dart';
// import '../core/view_models/common_view_model.dart';
// import 'login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<Color?> _colorAnimation;
//   late Animation<double> _neuralAnimation;
//   late Animation<double> _particleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeApp();
//     _debugDatabase();
//   }

//   void _debugDatabase() async {
//     final dbHelper = DatabaseHelper();
//     await dbHelper.debugPrintUsers();
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3000),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
//       ),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.3, 0.9, curve: Curves.easeInOut),
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
//           ),
//         );

//     _colorAnimation =
//         ColorTween(
//           begin: Colors.transparent,
//           end: QuickAIColors.cyber.primary.withOpacity(0.1),
//         ).animate(
//           CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0)),
//         );

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

//   void _initializeApp() async {
//     try {
//       final commonState = Provider.of<CommonState>(context, listen: false);
//       await Future.delayed(const Duration(milliseconds: 2500));
//       await _loadAppData();
//       if (mounted) {
//         _navigateToLogin();
//       }
//     } catch (e) {
//       await Future.delayed(const Duration(milliseconds: 2500));
//       if (mounted) {
//         _navigateToLogin();
//       }
//     }
//   }

//   Future<void> _loadAppData() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//   }

//   void _navigateToLogin() {
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//             const LoginScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(1.0, 0.0);
//           const end = Offset.zero;
//           const curve = Curves.easeInOut;

//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//           var offsetAnimation = animation.drive(tween);

//           return SlideTransition(
//             position: offsetAnimation,
//             child: FadeTransition(opacity: animation, child: child),
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 1000),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final theme = Provider.of<AppTheme>(context);
//     final mediaQuery = MediaQuery.of(context);
//     final isLandscape = mediaQuery.orientation == Orientation.landscape;
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       // backgroundColor: theme.themeMode == ThemeMode.dark
//       //     ? AppColors.backgroundDark
//       //     : AppColors.backgroundLight,
//       body: SafeArea(
//         // ✅ Added SafeArea to prevent system UI overlap
//         child: Stack(
//           children: [
//             // Background
//             _buildBackground(),

//             // Neural Network Animation - with proper constraints
//             _buildNeuralNetworkAnimation(),

//             // Floating Particles - with proper constraints
//             _buildFloatingParticles(),

//             // Main content
//             _buildMainContent(screenHeight, screenWidth, isLandscape),

//             // Bottom copyright
//             _buildCopyright(screenHeight, isLandscape),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent(
//     double screenHeight,
//     double screenWidth,
//     bool isLandscape,
//   ) {
//     return SingleChildScrollView(
//       // ✅ Always use SingleChildScrollView for safety
//       child: Container(
//         width: screenWidth,
//         height: isLandscape ? null : screenHeight,
//         padding: EdgeInsets.symmetric(
//           horizontal: isLandscape ? screenWidth * 0.1 : 24.0,
//           vertical: isLandscape ? 40.0 : 0.0,
//         ),
//         child: Column(
//           mainAxisAlignment: isLandscape
//               ? MainAxisAlignment.start
//               : MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
//           children: [
//             if (isLandscape) SizedBox(height: screenHeight * 0.05),

//             // Logo with scale animation
//             ScaleTransition(
//               scale: _scaleAnimation,
//               child: _buildLogo(isLandscape, screenWidth),
//             ),

//             SizedBox(height: isLandscape ? 20 : 40),

//             // App name with slide and fade animation
//             SlideTransition(
//               position: _slideAnimation,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: _buildAppName(isLandscape, screenWidth),
//               ),
//             ),

//             SizedBox(height: isLandscape ? 10 : 20),

//             // Tagline with fade animation
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildTagline(isLandscape, screenWidth),
//             ),

//             SizedBox(height: isLandscape ? 30 : 60),

//             if (isLandscape) SizedBox(height: screenHeight * 0.05),
//           ],
//         ),
//       ),
//     );
//   }

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

//   Widget _buildNeuralNetworkAnimation() {
//     return Positioned.fill(
//       // ✅ Use Positioned.fill for proper sizing
//       child: IgnorePointer(
//         // ✅ Ignore touch events
//         child: AnimatedBuilder(
//           animation: _neuralAnimation,
//           builder: (context, child) {
//             return CustomPaint(
//               painter: _NeuralNetworkPainter(
//                 animationValue: _neuralAnimation.value,
//               ),
//               size: MediaQuery.of(context).size, // ✅ Provide explicit size
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingParticles() {
//     return Positioned.fill(
//       // ✅ Use Positioned.fill for proper sizing
//       child: IgnorePointer(
//         // ✅ Ignore touch events
//         child: AnimatedBuilder(
//           animation: _particleAnimation,
//           builder: (context, child) {
//             return CustomPaint(
//               painter: _ParticlePainter(
//                 animationValue: _particleAnimation.value,
//               ),
//               size: MediaQuery.of(context).size, // ✅ Provide explicit size
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLogo(bool isLandscape, double screenWidth) {
//     final logoSize = isLandscape
//         ? screenWidth * 0.12
//         : 120.0; // ✅ Slightly reduced

//     return Container(
//       width: logoSize * 1.8, // ✅ Fixed container size
//       height: logoSize * 1.8,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Orbital Rings
//           AnimatedBuilder(
//             animation: _neuralAnimation,
//             builder: (context, child) {
//               return CustomPaint(
//                 painter: _OrbitalPainter(
//                   animationValue: _neuralAnimation.value,
//                   size: logoSize * 1.5,
//                 ),
//                 size: Size(logoSize * 1.8, logoSize * 1.8), // ✅ Fixed size
//               );
//             },
//           ),

//           // Main Logo Container
//           Container(
//             width: logoSize,
//             height: logoSize,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   QuickAIColors.cyber.primary,
//                   QuickAIColors.cyber.secondary,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(logoSize * 0.25),
//               boxShadow: [
//                 BoxShadow(
//                   color: QuickAIColors.cyber.primary.withOpacity(0.6),
//                   blurRadius: 30,
//                   offset: const Offset(0, 15),
//                   spreadRadius: 3,
//                 ),
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 // Core Glow
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(logoSize * 0.25),
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

//                 // Logo
//                 Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(logoSize * 0.18),
//                     child: Image.asset(
//                       'assets/images/nutantek_logo.png',
//                       width: logoSize * 0.64,
//                       height: logoSize * 0.64,
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: logoSize * 0.64,
//                           height: logoSize * 0.64,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(logoSize * 0.1),
//                           ),
//                           child: Icon(
//                             Icons.business_center_rounded,
//                             size: logoSize * 0.43,
//                             color: QuickAIColors.cyber.primary,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppName(bool isLandscape, double screenWidth) {
//     final appNameFontSize = isLandscape
//         ? screenWidth * 0.05
//         : 42.0; // ✅ Reduced
//     final proFontSize = isLandscape ? screenWidth * 0.018 : 16.0; // ✅ Reduced

//     return Column(
//       mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
//       children: [
//         ShaderMask(
//           shaderCallback: (bounds) {
//             return LinearGradient(
//               colors: [
//                 QuickAIColors.cyber.primary,
//                 QuickAIColors.cyber.accent,
//                 QuickAIColors.cyber.secondary,
//               ],
//             ).createShader(bounds);
//           },
//           child: Text(
//             'Nutantek',
//             style: TextStyle(
//               fontSize: appNameFontSize,
//               fontWeight: FontWeight.w900,
//               color: Colors.white,
//               letterSpacing: 2.0, // ✅ Reduced
//             ),
//           ),
//         ),
//         SizedBox(height: isLandscape ? 4 : 8),
//         Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 4,
//           ), // ✅ Reduced
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 QuickAIColors.cyber.primary.withOpacity(0.3),
//                 QuickAIColors.cyber.secondary.withOpacity(0.2),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16), // ✅ Reduced
//             border: Border.all(
//               color: QuickAIColors.cyber.primary.withOpacity(0.4),
//             ),
//           ),
//           child: Text(
//             'ATTENDANCE PRO',
//             style: TextStyle(
//               fontSize: proFontSize,
//               fontWeight: FontWeight.w700,
//               color: Colors.white.withOpacity(0.9),
//               letterSpacing: 2.0, // ✅ Reduced
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTagline(bool isLandscape, double screenWidth) {
//     final mainTaglineFontSize = isLandscape
//         ? screenWidth * 0.016
//         : 14.0; // ✅ Reduced
//     final subTaglineFontSize = isLandscape
//         ? screenWidth * 0.012
//         : 11.0; // ✅ Reduced

//     return Column(
//       mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
//       children: [
//         Text(
//           'Enterprise Workforce Management',
//           style: TextStyle(
//             fontSize: mainTaglineFontSize,
//             fontWeight: FontWeight.w500,
//             color: Colors.white.withOpacity(0.9),
//             letterSpacing: 1.0, // ✅ Reduced
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: isLandscape ? 6 : 10), // ✅ Reduced
//         Wrap(
//           spacing: 8, // ✅ Reduced
//           runSpacing: 4, // ✅ Reduced
//           alignment: WrapAlignment.center,
//           children: [
//             _buildFeatureChip(
//               'Real-time Tracking',
//               Icons.track_changes_rounded,
//             ),
//             _buildFeatureChip('Smart Analytics', Icons.analytics_rounded),
//             _buildFeatureChip('Secure', Icons.security_rounded),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureChip(String text, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 4,
//       ), // ✅ Reduced
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16), // ✅ Reduced
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 10, color: QuickAIColors.cyber.accent), // ✅ Reduced
//           const SizedBox(width: 4), // ✅ Reduced
//           Text(
//             text,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 9, // ✅ Reduced
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCopyright(double screenHeight, bool isLandscape) {
//     return Positioned(
//       bottom: isLandscape ? 15 : 20, // ✅ Reduced
//       left: 0,
//       right: 0,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
//           children: [
//             Text(
//               '© 2024 Nutantek. All rights reserved.',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.5),
//                 fontSize: isLandscape ? 8 : 10, // ✅ Reduced
//                 letterSpacing: 0.5, // ✅ Reduced
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: isLandscape ? 1 : 2), // ✅ Reduced
//             Text(
//               'NEURAL SECURITY v1.0.0',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.4),
//                 fontSize: isLandscape ? 7 : 9, // ✅ Reduced
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5, // ✅ Reduced
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // CustomPainter classes remain the same...
// class _NeuralNetworkPainter extends CustomPainter {
//   final double animationValue;

//   _NeuralNetworkPainter({required this.animationValue});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final maxRadius =
//         min(size.width, size.height) * 0.3; // ✅ Use min to stay within bounds

//     // Draw neural network connections
//     for (int i = 0; i < 12; i++) {
//       final angle = (i / 12) * 2 * pi;
//       final x = center.dx + cos(angle) * maxRadius;
//       final y = center.dy + sin(angle) * maxRadius;

//       // Create pulsating nodes
//       final nodePaint = Paint()
//         ..color = QuickAIColors.cyber.accent.withOpacity(0.8 * animationValue)
//         ..style = PaintingStyle.fill
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * animationValue);

//       final nodeSize = 2 + 1.5 * sin(animationValue * pi * 2 + i); // ✅ Reduced
//       canvas.drawCircle(Offset(x, y), nodeSize, nodePaint);

//       // Draw connections to other nodes
//       for (int j = i + 1; j < 12; j += 3) {
//         final angle2 = (j / 12) * 2 * pi;
//         final x2 = center.dx + cos(angle2) * maxRadius;
//         final y2 = center.dy + sin(angle2) * maxRadius;

//         final distance = sqrt(pow(x2 - x, 2) + pow(y2 - y, 2));
//         final opacity = (1 - (distance / (maxRadius * 2))) * animationValue;

//         final connectionPaint = Paint()
//           ..color = QuickAIColors.cyber.primary
//               .withOpacity(opacity * 0.3) // ✅ Reduced
//           ..style = PaintingStyle.stroke
//           ..strokeWidth =
//               0.8 // ✅ Reduced
//           ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5); // ✅ Reduced

//         canvas.drawLine(Offset(x, y), Offset(x2, y2), connectionPaint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class _ParticlePainter extends CustomPainter {
//   final double animationValue;

//   _ParticlePainter({required this.animationValue});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final random = Random();

//     for (int i = 0; i < 12; i++) {
//       // ✅ Reduced particle count
//       final x = random.nextDouble() * size.width;
//       final y = random.nextDouble() * size.height;
//       final sizeParticle = 0.5 + random.nextDouble() * 2; // ✅ Reduced
//       final opacity = 0.1 + random.nextDouble() * 0.2; // ✅ Reduced

//       final paint = Paint()
//         ..color = QuickAIColors.cyber.accent.withOpacity(
//           opacity * animationValue,
//         )
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2); // ✅ Reduced

//       canvas.drawCircle(Offset(x, y), sizeParticle * animationValue, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class _OrbitalPainter extends CustomPainter {
//   final double animationValue;
//   final double size;

//   _OrbitalPainter({required this.animationValue, required this.size});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);

//     // Draw multiple orbital rings
//     for (int i = 1; i <= 2; i++) {
//       final radius = this.size * 0.25 * i; // ✅ Reduced radius
//       final orbitalPaint = Paint()
//         ..color = QuickAIColors.cyber.primary
//             .withOpacity(0.15 / i) // ✅ Reduced
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 0.8; // ✅ Reduced

//       canvas.drawCircle(center, radius, orbitalPaint);

//       // Draw rotating dots on orbitals
//       final dotAngle = animationValue * 2 * pi * (i % 2 == 0 ? 1 : -1);
//       final dotX = center.dx + cos(dotAngle) * radius;
//       final dotY = center.dy + sin(dotAngle) * radius;

//       final dotPaint = Paint()
//         ..color = QuickAIColors.cyber.accent
//         ..style = PaintingStyle.fill;

//       canvas.drawCircle(Offset(dotX, dotY), 2.0, dotPaint); // ✅ Reduced
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
