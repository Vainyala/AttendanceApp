import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'employee/providers/splash_provider.dart';
import 'employee/utils/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  final List<RoleOption> _roles = [
    RoleOption(
      role: 'Manager',
      icon: Icons.business_center,
      color: Color(0xFF4A90E2),
      description: 'Manage teams and projects',
      route: '/manager',     // 👈 changed
    ),
    RoleOption(
      role: 'Employee',
      icon: Icons.person,
      color: Color(0xFF27AE60),
      description: 'Access your work dashboard',
      route: '/employee',    // 👈 changed
    ),
  ];

  Future<void> _proceedToDashboard() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isLoading = false);

      // Navigate based on selected role
      if (_selectedRole == 'Manager') {
        Navigator.pushReplacementNamed(context, '/manager');
      } else {
        Navigator.pushReplacementNamed(context, '/employee');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF5DADE2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Your Role',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the role that best describes you',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textLight.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Role Cards
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _roles.length,
                    itemBuilder: (context, index) {
                      final roleOption = _roles[index];
                      final isSelected = _selectedRole == roleOption.role;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                            setState(() {
                              _selectedRole = roleOption.role;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? roleOption.color.withOpacity(0.1)
                                  : AppColors.textLight,
                              border: Border.all(
                                color: isSelected
                                    ? roleOption.color
                                    : AppColors.textHint.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? roleOption.color.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: isSelected ? 12 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: roleOption.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      roleOption.icon,
                                      size: 32,
                                      color: roleOption.color,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          roleOption.role,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? roleOption.color
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          roleOption.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textHint.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Selection Indicator
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: roleOption.color,
                                      size: 28,
                                    )
                                  else
                                    Icon(
                                      Icons.circle_outlined,
                                      color: AppColors.textHint.shade400,
                                      size: 28,
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

              // Continue Button
              Container(
                color: AppColors.textLight,
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _proceedToDashboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: AppColors.textLight,
                      disabledBackgroundColor: AppColors.textHint.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.textLight,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
}

class RoleOption {
  final String role;
  final IconData icon;
  final Color color;
  final String description;
  final String route;

  RoleOption({
    required this.role,
    required this.icon,
    required this.color,
    required this.description,
    required this.route,
  });
}




// role based

//
//
// import 'package:flutter/material.dart';
// import 'employee/utils/app_colors.dart';
//
// class RoleSelectionScreen extends StatefulWidget {
//   const RoleSelectionScreen({super.key});
//
//   @override
//   State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
// }
//
// class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
//   String? _selectedRole;
//   bool _isLoading = false;
//
//   final List<RoleOption> _roles = [
//     RoleOption(
//       role: 'Manager',
//       icon: Icons.business_center,
//       color: Color(0xFF4A90E2),
//       description: 'Manage teams and projects',
//     ),
//     RoleOption(
//       role: 'Employee',
//       icon: Icons.person,
//       color: Color(0xFF27AE60),
//       description: 'Access your work dashboard',
//     ),
//   ];
//
//   Future<void> _proceedToDashboard() async {
//     if (_selectedRole == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a role to continue'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     if (mounted) {
//       setState(() => _isLoading = false);
//
//       // Navigate based on role
//       if (_selectedRole == 'Manager') {
//         // Go to MANAGER'S login screen
//         Navigator.pushReplacementNamed(context, '/manager/login');
//       } else {
//         // Go to EMPLOYEE'S splash → email → mpin → login flow
//         Navigator.pushReplacementNamed(context, '/employee/splash');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF87CEEB), Color(0xFF5DADE2)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     const Icon(Icons.account_circle, size: 80, color: AppColors.textLight),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Select Your Role',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textLight,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Choose the role that best describes you',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: AppColors.textLight.withOpacity(0.9),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Role Cards
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: AppColors.textLight,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(24),
//                     itemCount: _roles.length,
//                     itemBuilder: (context, index) {
//                       final roleOption = _roles[index];
//                       final isSelected = _selectedRole == roleOption.role;
//
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: GestureDetector(
//                           onTap: _isLoading
//                               ? null
//                               : () => setState(() => _selectedRole = roleOption.role),
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? roleOption.color.withOpacity(0.1)
//                                   : AppColors.textLight,
//                               border: Border.all(
//                                 color: isSelected
//                                     ? roleOption.color
//                                     : AppColors.textHint.shade300,
//                                 width: isSelected ? 2 : 1,
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: isSelected
//                                       ? roleOption.color.withOpacity(0.3)
//                                       : Colors.black.withOpacity(0.05),
//                                   blurRadius: isSelected ? 12 : 8,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(20),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: roleOption.color.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Icon(
//                                       roleOption.icon,
//                                       size: 32,
//                                       color: roleOption.color,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           roleOption.role,
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: isSelected
//                                                 ? roleOption.color
//                                                 : Colors.black87,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           roleOption.description,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: AppColors.textHint.shade600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Icon(
//                                     isSelected
//                                         ? Icons.check_circle
//                                         : Icons.circle_outlined,
//                                     color: isSelected
//                                         ? roleOption.color
//                                         : AppColors.textHint.shade400,
//                                     size: 28,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//
//               // Continue Button
//               Container(
//                 color: AppColors.textLight,
//                 padding: const EdgeInsets.all(24),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _proceedToDashboard,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4A90E2),
//                       foregroundColor: AppColors.textLight,
//                       disabledBackgroundColor: AppColors.textHint.shade400,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: AppColors.textLight,
//                         strokeWidth: 2,
//                       ),
//                     )
//                         : const Text(
//                       'Continue',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class RoleOption {
//   final String role;
//   final IconData icon;
//   final Color color;
//   final String description;
//
//   RoleOption({
//     required this.role,
//     required this.icon,
//     required this.color,
//     required this.description,
//   });
// }




//
// import 'package:flutter/material.dart';
// import 'manager_main.dart';
// import 'employee_main.dart';
//
// class RoleSelectionScreen extends StatefulWidget {
//   const RoleSelectionScreen({super.key});
//
//   @override
//   State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
// }
//
// class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
//   String? _selectedRole;
//   bool _isLoading = false;
//
//   final List<RoleOption> _roles = [
//     RoleOption(
//       role: 'Manager',
//       icon: Icons.business_center,
//       color: Color(0xFF4A90E2),
//       description: 'Manage teams and projects',
//     ),
//     RoleOption(
//       role: 'Employee',
//       icon: Icons.person,
//       color: Color(0xFF27AE60),
//       description: 'Access your work dashboard',
//     ),
//   ];
//
//   Future<void> _proceedToDashboard() async {
//     if (_selectedRole == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please select a role to continue'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     if (!mounted) return;
//
//     // ✅ Navigate to respective app
//     if (_selectedRole == 'Manager') {
//       debugPrint("🔵 Launching Manager App");
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const ManagerApp()),
//       );
//     } else if (_selectedRole == 'Employee') {
//       debugPrint("🟢 Launching Employee App");
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const EmployeeApp()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF87CEEB), Color(0xFF5DADE2)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.account_circle,
//                       size: 80,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Select Your Role',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Choose the role that best describes you',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Role Cards
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(24),
//                     itemCount: _roles.length,
//                     itemBuilder: (context, index) {
//                       final roleOption = _roles[index];
//                       final isSelected = _selectedRole == roleOption.role;
//
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: GestureDetector(
//                           onTap: _isLoading
//                               ? null
//                               : () => setState(() => _selectedRole = roleOption.role),
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? roleOption.color.withOpacity(0.1)
//                                   : Colors.white,
//                               border: Border.all(
//                                 color: isSelected
//                                     ? roleOption.color
//                                     : Colors.grey.shade300,
//                                 width: isSelected ? 2 : 1,
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: isSelected
//                                       ? roleOption.color.withOpacity(0.3)
//                                       : Colors.black.withOpacity(0.05),
//                                   blurRadius: isSelected ? 12 : 8,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(20),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: roleOption.color.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Icon(
//                                       roleOption.icon,
//                                       size: 32,
//                                       color: roleOption.color,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           roleOption.role,
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: isSelected
//                                                 ? roleOption.color
//                                                 : Colors.black87,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           roleOption.description,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Icon(
//                                     isSelected
//                                         ? Icons.check_circle
//                                         : Icons.circle_outlined,
//                                     color: isSelected
//                                         ? roleOption.color
//                                         : Colors.grey.shade400,
//                                     size: 28,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//
//               // Continue Button
//               Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(24),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _proceedToDashboard,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4A90E2),
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor: Colors.grey.shade400,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                         : const Text(
//                       'Continue',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class RoleOption {
//   final String role;
//   final IconData icon;
//   final Color color;
//   final String description;
//
//   RoleOption({
//     required this.role,
//     required this.icon,
//     required this.color,
//     required this.description,
//   });
// }