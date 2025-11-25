import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:attendanceapp/manager/models/projectmodels/project_models.dart';

class ProjectDetailListScreens extends StatelessWidget {
  final Project project;

  const ProjectDetailListScreens({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          project.name,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: _getStatusColor(project.status),
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Project Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _getStatusColor(project.status)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(project.status).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Project Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDarkMode
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: _getStatusColor(project.status),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Project Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? AppColors.textInverse
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildModernDetailRow(
                        'Client',
                        project.client,
                        isDarkMode,
                      ),
                      _buildModernDetailRow(
                        'Description',
                        project.description,
                        isDarkMode,
                      ),
                      _buildModernDetailRow(
                        'Est D. Start Date',
                        _formatDate(project.startDate),
                        isDarkMode,
                      ),
                      _buildModernDetailRow(
                        'Est D. End Date',
                        _formatDate(project.endDate),
                        isDarkMode,
                      ),
                      _buildModernDetailRow(
                        'Est D. Effort',
                        '765 Man days',
                        isDarkMode,
                      ),
                      _buildModernDetailRow(
                        'Est D. Cost',
                        '₹${project.budget.toStringAsFixed(2)}',
                        isDarkMode,
                      ),
                      _buildModernDetailRow(
                        'Priority',
                        _getPriorityText(project.priority),
                        isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Team Members Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDarkMode
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            color: _getStatusColor(project.status),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Team Members',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? AppColors.textInverse
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                project.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.teamSize.toString(),
                              style: TextStyle(
                                color: _getStatusColor(project.status),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...project.assignedTeam.map(
                        (member) => _buildModernTeamMemberCard(
                          member,
                          context,
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDetailRow(String label, String value, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceVariantDark : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.grey300 : AppColors.grey700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDarkMode
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTeamMemberCard(
    TeamMember member,
    BuildContext context,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceVariantDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Avatar with gradient
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor(project.status),
                  _getStatusColor(project.status).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                _getInitials(member.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDarkMode
                        ? AppColors.textInverse
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.grey400 : AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 12,
                      color: isDarkMode ? AppColors.grey400 : AppColors.grey500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      member.email,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.grey400
                            : AppColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Phone Call Button with WhatsApp option
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.green.withOpacity(0.2)
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.phone_rounded,
                color: Colors.green.shade600,
                size: 20,
              ),
              tooltip: 'Contact ${member.name}',
              onSelected: (value) {
                if (value == 'call') {
                  _makePhoneCall(member.phoneNumber);
                } else if (value == 'whatsapp') {
                  _openWhatsApp(member.phoneNumber, context);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        color: Colors.green.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Call',
                        style: TextStyle(
                          color: isDarkMode
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'whatsapp',
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_rounded,
                        color: Colors.green.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WhatsApp',
                        style: TextStyle(
                          color: isDarkMode
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WhatsApp Function with context parameter
  Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
    try {
      // Clean the phone number - remove all non-digit characters
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // Format for WhatsApp
      String formattedNumber = cleanedNumber;

      // Remove leading zeros and ensure proper format
      if (formattedNumber.startsWith('0')) {
        formattedNumber = formattedNumber.substring(1);
      }

      // Add country code if not present (assuming India +91)
      if (!formattedNumber.startsWith('+') && formattedNumber.length == 10) {
        formattedNumber = '91$formattedNumber';
      }

      // Remove + sign for WhatsApp URL
      final String whatsappNumber = formattedNumber.replaceAll('+', '');

      print('Attempting to open WhatsApp for number: $whatsappNumber');

      // Try multiple URL formats
      final List<Uri> urisToTry = [
        Uri.parse('whatsapp://send?phone=$whatsappNumber'),
        Uri.parse('https://wa.me/$whatsappNumber'),
        Uri.parse('https://api.whatsapp.com/send?phone=$whatsappNumber'),
        Uri.parse('https://web.whatsapp.com/send?phone=$whatsappNumber'),
      ];

      bool launchedSuccessfully = false;

      for (final uri in urisToTry) {
        print('Trying URI: $uri');

        final canLaunch = await canLaunchUrl(uri);
        print('Can launch $uri: $canLaunch');

        if (canLaunch) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            launchedSuccessfully = true;
            print('Successfully launched: $uri');
            break;
          } catch (e) {
            print('Failed to launch $uri: $e');
            continue;
          }
        }
      }

      if (!launchedSuccessfully) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp not found. Please install WhatsApp.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Phone Call Function
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'planning':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'on-hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'planning':
        return 'Planning';
      case 'completed':
        return 'Completed';
      case 'on-hold':
        return 'On Hold';
      default:
        return 'Unknown';
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
  }
}

class ProjectPhase {
  final String name;
  final double progress;

  ProjectPhase(this.name, this.progress);
}

// import 'package:attendanceapp/models/team_model.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:attendanceapp/models/projectmodels/project_models.dart';

// class ProjectDetailListScreens extends StatelessWidget {
//   final Project project;

//   const ProjectDetailListScreens({super.key, required this.project});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         title: Text(
//           project.name,
//           style: const TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: _getStatusColor(project.status),
//         elevation: 2,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             // Project Status Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: _getStatusColor(project.status),
//                 // gradient: LinearGradient(
//                 //   begin: Alignment.topLeft,
//                 //   end: Alignment.bottomRight,
//                 //   colors: [
//                 //     _getStatusColor(project.status),
//                 //     _getStatusColor(project.status).withOpacity(0.8),
//                 //   ],
//                 // ),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       _getStatusText(project.status).toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 12,
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     project.name,
//                     // '${project.progress.toInt()}% Complete',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   // const SizedBox(height: 5),
//                   // Text(
//                   //   '${project.daysRemaining} days remaining',
//                   //   style: TextStyle(
//                   //     color: Colors.white.withOpacity(0.9),
//                   //     fontSize: 14,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Project Info Card
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline_rounded,
//                             color: _getStatusColor(project.status),
//                             size: 24,
//                           ),
//                           const SizedBox(width: 10),
//                           const Text(
//                             'Project Information',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       //_buildModernDetailRow('Project Name', project.name),
//                       _buildModernDetailRow('Client', project.client),
//                       _buildModernDetailRow('Description', project.description),
//                       _buildModernDetailRow(
//                         'Est D. Start Date',
//                         _formatDate(project.startDate),
//                       ),
//                       _buildModernDetailRow(
//                         'Est D. End Date',
//                         _formatDate(project.endDate),
//                       ),
//                       _buildModernDetailRow(
//                         'Est D. Effort',
//                         '765 Man days',
//                         // '${project.daysRemaining} Mandays',
//                       ),

//                       _buildModernDetailRow(
//                         'Est D. Cost',
//                         '₹${project.budget.toStringAsFixed(2)}',
//                       ),
//                       _buildModernDetailRow(
//                         'Priority',
//                         _getPriorityText(project.priority),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Team Members Section
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.people_alt_rounded,
//                             color: _getStatusColor(project.status),
//                             size: 24,
//                           ),
//                           const SizedBox(width: 10),
//                           const Text(
//                             'Team Members',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _getStatusColor(
//                                 project.status,
//                               ).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               project.teamSize.toString(),
//                               style: TextStyle(
//                                 color: _getStatusColor(project.status),
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       ...project.assignedTeam.map(
//                         (member) => _buildModernTeamMemberCard(member, context),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernDetailRow(String label, String value) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade700,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernTeamMemberCard(TeamMember member, BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Avatar with gradient
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   _getStatusColor(project.status),
//                   _getStatusColor(project.status).withOpacity(0.7),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Center(
//               child: Text(
//                 _getInitials(member.name),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Member Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   member.name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   member.role,
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.email_rounded,
//                       size: 12,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       member.email,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Phone Call Button with WhatsApp option - Replaced status text
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: PopupMenuButton<String>(
//               icon: Icon(
//                 Icons.phone_rounded,
//                 color: Colors.green.shade600,
//                 size: 20,
//               ),
//               tooltip: 'Contact ${member.name}',
//               onSelected: (value) {
//                 if (value == 'call') {
//                   _makePhoneCall(member.phoneNumber);
//                 } else if (value == 'whatsapp') {
//                   _openWhatsApp(
//                     member.phoneNumber,
//                     context,
//                   ); // Context pass kiya
//                 }
//               },
//               itemBuilder: (BuildContext context) => [
//                 PopupMenuItem<String>(
//                   value: 'call',
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.phone_rounded,
//                         color: Colors.green.shade600,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text('Call'),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem<String>(
//                   value: 'whatsapp',
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.chat_rounded,
//                         color: Colors.green.shade600,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text('WhatsApp'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // WhatsApp Function with context parameter
//   // WhatsApp Function with context parameter
//   Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
//     try {
//       // Clean the phone number - remove all non-digit characters
//       final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

//       // Format for WhatsApp
//       String formattedNumber = cleanedNumber;

//       // Remove leading zeros and ensure proper format
//       if (formattedNumber.startsWith('0')) {
//         formattedNumber = formattedNumber.substring(1);
//       }

//       // Add country code if not present (assuming India +91)
//       if (!formattedNumber.startsWith('+') && formattedNumber.length == 10) {
//         formattedNumber = '91$formattedNumber';
//       }

//       // Remove + sign for WhatsApp URL
//       final String whatsappNumber = formattedNumber.replaceAll('+', '');

//       print('Attempting to open WhatsApp for number: $whatsappNumber');

//       // Try multiple URL formats
//       final List<Uri> urisToTry = [
//         Uri.parse('whatsapp://send?phone=$whatsappNumber'),
//         Uri.parse('https://wa.me/$whatsappNumber'),
//         Uri.parse('https://api.whatsapp.com/send?phone=$whatsappNumber'),
//         Uri.parse('https://web.whatsapp.com/send?phone=$whatsappNumber'),
//       ];

//       bool launchedSuccessfully = false;

//       for (final uri in urisToTry) {
//         print('Trying URI: $uri');

//         final canLaunch = await canLaunchUrl(uri);
//         print('Can launch $uri: $canLaunch');

//         if (canLaunch) {
//           try {
//             await launchUrl(uri, mode: LaunchMode.externalApplication);
//             launchedSuccessfully = true;
//             print('Successfully launched: $uri');
//             break;
//           } catch (e) {
//             print('Failed to launch $uri: $e');
//             continue;
//           }
//         }
//       }

//       if (!launchedSuccessfully) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('WhatsApp not found. Please install WhatsApp.'),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error opening WhatsApp: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//   // Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
//   //   try {
//   //     // Clean the phone number
//   //     final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

//   //     // Format for WhatsApp (with country code)
//   //     String formattedNumber = cleanedNumber;
//   //     if (formattedNumber.length == 10) {
//   //       formattedNumber = '91$formattedNumber'; // India country code
//   //     }

//   //     // Use WhatsApp URL
//   //     final String url = 'https://wa.me/$formattedNumber';
//   //     final Uri whatsappUri = Uri.parse(url);

//   //     if (await canLaunchUrl(whatsappUri)) {
//   //       await launchUrl(whatsappUri);
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('WhatsApp not installed'),
//   //           backgroundColor: Colors.orange,
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Could not open WhatsApp'),
//   //         backgroundColor: Colors.orange,
//   //       ),
//   //     );
//   //   }
//   // }

//   // // WhatsApp Function
//   // Future<void> _openWhatsApp(String phoneNumber) async {
//   //   // Remove any non-digit characters from phone number
//   //   final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

//   //   // Create WhatsApp URL
//   //   final Uri launchUri = Uri.parse('https://wa.me/$cleanedNumber');

//   //   if (await canLaunchUrl(launchUri)) {
//   //     await launchUrl(launchUri);
//   //   } else {
//   //     throw 'Could not launch $launchUri';
//   //   }
//   // }

//   // Widget _buildModernTeamMemberCard(TeamMember member, BuildContext context) {
//   //   return Container(
//   //     margin: const EdgeInsets.only(bottom: 12),
//   //     padding: const EdgeInsets.all(16),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(12),
//   //       border: Border.all(color: Colors.grey.shade200),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.grey.withOpacity(0.1),
//   //           blurRadius: 8,
//   //           offset: const Offset(0, 2),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         // Avatar with gradient
//   //         Container(
//   //           width: 50,
//   //           height: 50,
//   //           decoration: BoxDecoration(
//   //             gradient: LinearGradient(
//   //               begin: Alignment.topLeft,
//   //               end: Alignment.bottomRight,
//   //               colors: [
//   //                 _getStatusColor(project.status),
//   //                 _getStatusColor(project.status).withOpacity(0.7),
//   //               ],
//   //             ),
//   //             borderRadius: BorderRadius.circular(25),
//   //           ),
//   //           child: Center(
//   //             child: Text(
//   //               _getInitials(member.name),
//   //               style: const TextStyle(
//   //                 color: Colors.white,
//   //                 fontWeight: FontWeight.w700,
//   //                 fontSize: 16,
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //         const SizedBox(width: 12),

//   //         // Member Info
//   //         Expanded(
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 member.name,
//   //                 style: const TextStyle(
//   //                   fontWeight: FontWeight.w700,
//   //                   fontSize: 16,
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 4),
//   //               Text(
//   //                 member.role,
//   //                 style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//   //               ),
//   //               const SizedBox(height: 4),
//   //               Row(
//   //                 children: [
//   //                   Icon(
//   //                     Icons.email_rounded,
//   //                     size: 12,
//   //                     color: Colors.grey.shade500,
//   //                   ),
//   //                   const SizedBox(width: 4),
//   //                   Text(
//   //                     member.email,
//   //                     style: TextStyle(
//   //                       color: Colors.grey.shade600,
//   //                       fontSize: 12,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ],
//   //           ),
//   //         ),

//   //         // Phone Call Button - Replaced status text
//   //         Container(
//   //           width: 40,
//   //           height: 40,
//   //           decoration: BoxDecoration(
//   //             color: Colors.green.shade50,
//   //             borderRadius: BorderRadius.circular(20),
//   //           ),
//   //           child: IconButton(
//   //             icon: Icon(
//   //               Icons.phone_rounded,
//   //               color: Colors.green.shade600,
//   //               size: 20,
//   //             ),
//   //             onPressed: () => _makePhoneCall(member.phoneNumber),
//   //             tooltip: 'Call ${member.name}',
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Phone Call Function
//   Future<void> _makePhoneCall(String phoneNumber) async {
//     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(launchUri)) {
//       await launchUrl(launchUri);
//     } else {
//       throw 'Could not launch $launchUri';
//     }
//   }

//   // Helper methods
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'active':
//         return Colors.green;
//       case 'planning':
//         return Colors.blue;
//       case 'completed':
//         return Colors.purple;
//       case 'on-hold':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status) {
//       case 'active':
//         return 'Active';
//       case 'planning':
//         return 'Planning';
//       case 'completed':
//         return 'Completed';
//       case 'on-hold':
//         return 'On Hold';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _getPriorityText(String priority) {
//     switch (priority) {
//       case 'low':
//         return 'Low';
//       case 'medium':
//         return 'Medium';
//       case 'high':
//         return 'High';
//       case 'urgent':
//         return 'Urgent';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _getInitials(String name) {
//     return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
//   }
// }

// class ProjectPhase {
//   final String name;
//   final double progress;

//   ProjectPhase(this.name, this.progress);
// }

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';

// class ProjectDetailListScreens extends StatelessWidget {
//   final Project project;

//   const ProjectDetailListScreens({super.key, required this.project});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(project.name),
//         backgroundColor: _getStatusColor(project.status),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Project Basic Info Card
//             _buildInfoCard(context),
//             const SizedBox(height: 20),

//             // Progress Tracker Graph
//             // _buildProgressTracker(),
//             // const SizedBox(height: 20),

//             // Project Timeline
//             // _buildTimelineSection(),
//             // const SizedBox(height: 20),

//             // Allocated Employees
//             _buildEmployeesSection(),

//             const SizedBox(height: 20),

//             // Tasks Overview
//             // _buildTasksSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(BuildContext context) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Project Details',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(project.status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: _getStatusColor(project.status)),
//                   ),
//                   child: Text(
//                     _getStatusText(project.status),
//                     style: TextStyle(
//                       color: _getStatusColor(project.status),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildDetailRow('Project Name:', project.name),
//             _buildDetailRow('Client:', project.client),
//             _buildDetailRow('Description:', project.description),
//             _buildDetailRow(
//               'Technology:',
//               'Flutter, Node.js, MongoDB',
//             ), // You can add this field to your model
//             _buildDetailRow(
//               'Estd. Start Date:',
//               _formatDate(project.startDate),
//             ),
//             _buildDetailRow('Estd. End\nDate: ', _formatDate(project.endDate)),
//             _buildDetailRow(
//               'Estd. Main Days:',
//               '${project.daysRemaining}d remaining',
//             ),
//             _buildDetailRow(
//               'Estd. Cost:',
//               '₹${project.budget.toStringAsFixed(2)}',
//             ),
//             _buildDetailRow('Priority:', _getPriorityText(project.priority)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressTracker() {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Project Progress',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 Text(
//                   '${project.progress.toInt()}% Complete',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: _getStatusColor(project.status),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             LinearProgressIndicator(
//               value: project.progress / 100,
//               backgroundColor: Colors.grey.shade300,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 _getStatusColor(project.status),
//               ),
//               borderRadius: BorderRadius.circular(10),
//               minHeight: 12,
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: SfCartesianChart(
//                 primaryXAxis: CategoryAxis(),
//                 primaryYAxis: NumericAxis(maximum: 100),
//                 series: <ColumnSeries<ProjectPhase, String>>[
//                   ColumnSeries<ProjectPhase, String>(
//                     dataSource: [
//                       ProjectPhase('Planning', 35),
//                       ProjectPhase('Design', 75),
//                       ProjectPhase('Development', project.progress),
//                       ProjectPhase('Testing', 25),
//                       ProjectPhase('Deployment', 10),
//                     ],
//                     xValueMapper: (ProjectPhase phase, _) => phase.name,
//                     yValueMapper: (ProjectPhase phase, _) => phase.progress,
//                     color: _getStatusColor(project.status),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimelineSection() {
//     final now = DateTime.now();
//     final totalDays = project.endDate.difference(project.startDate).inDays;
//     final daysPassed = now.difference(project.startDate).inDays;
//     final percentage = (daysPassed / totalDays * 100).clamp(0, 100);

//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Project Timeline',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Start Date',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       Text(
//                         _formatDate(project.startDate),
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'End Date',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       Text(
//                         _formatDate(project.endDate),
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             LinearProgressIndicator(
//               value: percentage / 100,
//               backgroundColor: Colors.grey.shade300,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 project.isOverdue
//                     ? Colors.red
//                     : _getStatusColor(project.status),
//               ),
//               minHeight: 8,
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${daysPassed}d passed',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                 ),
//                 Text(
//                   project.isOverdue
//                       ? 'Overdue!'
//                       : '${project.daysRemaining}d remaining',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: project.isOverdue
//                         ? Colors.red
//                         : _getStatusColor(project.status),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmployeesSection() {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Team Members (${project.teamSize})',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Column(
//               children: project.assignedTeam
//                   .map(
//                     (member) => ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: _getStatusColor(
//                           project.status,
//                         ).withOpacity(0.2),
//                         child: Text(
//                           _getInitials(member.name),
//                           style: TextStyle(
//                             color: _getStatusColor(project.status),
//                           ),
//                         ),
//                       ),
//                       title: Text(member.name),
//                       subtitle: Text(member.role),
//                       trailing: Text(
//                         member.status,
//                         style: TextStyle(
//                           color: member.status == 'active'
//                               ? Colors.green
//                               : Colors.grey,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTasksSection() {
//     final completedTasks = project.completedTasks;
//     final totalTasks = project.totalTasks;

//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Tasks Overview',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 Text(
//                   '$completedTasks/$totalTasks completed',
//                   style: TextStyle(
//                     color: _getStatusColor(project.status),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             LinearProgressIndicator(
//               value: totalTasks > 0 ? completedTasks / totalTasks : 0,
//               backgroundColor: Colors.grey.shade300,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 _getStatusColor(project.status),
//               ),
//               minHeight: 8,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper methods
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'active':
//         return Colors.green;
//       case 'planning':
//         return Colors.blue;
//       case 'completed':
//         return Colors.purple;
//       case 'on-hold':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status) {
//       case 'active':
//         return 'Active';
//       case 'planning':
//         return 'Planning';
//       case 'completed':
//         return 'Completed';
//       case 'on-hold':
//         return 'On Hold';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _getPriorityText(String priority) {
//     switch (priority) {
//       case 'low':
//         return 'Low';
//       case 'medium':
//         return 'Medium';
//       case 'high':
//         return 'High';
//       case 'urgent':
//         return 'Urgent';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _getInitials(String name) {
//     return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
//   }
// }

// class ProjectPhase {
//   final String name;
//   final double progress;

//   ProjectPhase(this.name, this.progress);
// }
