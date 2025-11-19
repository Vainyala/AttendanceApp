// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/view_models/theme_view_model.dart';
// import '../../models/user_model.dart';
// import '../../view_models/auth_view_model.dart';

// class FinanceDashboardScreen extends StatelessWidget {
//   final User user;

//   const FinanceDashboardScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final authViewModel = Provider.of<AuthViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       appBar: AppBar(
//         title: const Text(
//           'Finance',
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: theme.colorScheme.surface,
//         elevation: 0,
//         scrolledUnderElevation: 1,
//         shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.notifications_outlined,
//               color: theme.colorScheme.onSurface,
//             ),
//             onPressed: () {
//               _showComingSoonSnackbar(context, 'Financial Alerts');
//             },
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'logout') {
//                 authViewModel.clearError();
//                 Navigator.pushReplacementNamed(context, '/login');
//               } else if (value == 'reports') {
//                 _showComingSoonSnackbar(context, 'Financial Reports');
//               }
//             },
//             icon: Icon(
//               Icons.more_vert_rounded,
//               color: theme.colorScheme.onSurface,
//             ),
//             itemBuilder: (BuildContext context) => [
//               PopupMenuItem<String>(
//                 value: 'reports',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.assessment_rounded,
//                       size: 20,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Reports',
//                       style: TextStyle(color: theme.colorScheme.onSurface),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.logout_rounded,
//                       size: 20,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Log Out',
//                       style: TextStyle(color: theme.colorScheme.onSurface),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // Welcome Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
//               child: _buildWelcomeSection(theme),
//             ),
//           ),

//           // Financial Overview Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Financial Overview',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildFinanceGrid(theme),
//             ),
//           ),

//           // Payroll Summary Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Payroll Summary',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildPayrollSummary(theme),
//             ),
//           ),

//           // Financial Tools Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Financial Tools',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildToolsGrid(context, theme),
//             ),
//           ),

//           // Recent Transactions Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Recent Transactions',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildRecentTransactions(theme),
//             ),
//           ),

//           // Financial Alerts Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Financial Alerts',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildFinancialAlerts(theme),
//             ),
//           ),

//           // Bottom Padding
//           const SliverToBoxAdapter(child: SizedBox(height: 20)),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showComingSoonSnackbar(context, 'New Transaction');
//         },
//         backgroundColor: theme.colorScheme.primary,
//         foregroundColor: Colors.white,
//         child: const Icon(Icons.add_chart_rounded),
//       ),
//     );
//   }

//   Widget _buildWelcomeSection(ThemeData theme) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary,
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   user.name[0].toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome back,',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     user.name,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     'Finance Manager',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     user.email,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Active',
//                 style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFinanceGrid(ThemeData theme) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       children: [
//         _buildFinanceCard(
//           theme,
//           'Monthly Budget',
//           '₹4,75,000',
//           Icons.account_balance_wallet_rounded,
//           theme.colorScheme.primary,
//         ),
//         _buildFinanceCard(
//           theme,
//           'Expenses',
//           '₹3,20,150',
//           Icons.trending_down_rounded,
//           Colors.red,
//         ),
//         _buildFinanceCard(
//           theme,
//           'Revenue',
//           '₹8,45,000',
//           Icons.trending_up_rounded,
//           Colors.green,
//         ),
//         _buildFinanceCard(
//           theme,
//           'Profit',
//           '₹1,24,850',
//           Icons.attach_money_rounded,
//           Colors.purple,
//         ),
//       ],
//     );
//   }

//   Widget _buildFinanceCard(
//     ThemeData theme,
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 28, color: color),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPayrollSummary(ThemeData theme) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'February 2024',
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildPayrollItem(
//               theme,
//               'Total Salary',
//               '₹3,85,000',
//               Icons.payment_rounded,
//               theme.colorScheme.primary,
//             ),
//             _buildPayrollItem(
//               theme,
//               'Tax Deductions',
//               '₹45,200',
//               Icons.receipt_rounded,
//               Colors.orange,
//             ),
//             _buildPayrollItem(
//               theme,
//               'Net Payable',
//               '₹3,39,800',
//               Icons.account_balance_rounded,
//               Colors.green,
//             ),
//             _buildPayrollItem(
//               theme,
//               'Processed',
//               '47/52',
//               Icons.check_circle_rounded,
//               Colors.blue,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPayrollItem(
//     ThemeData theme,
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 20, color: color),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToolsGrid(BuildContext context, ThemeData theme) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       children: [
//         _buildToolCard(
//           context,
//           theme,
//           'Process Payroll',
//           Icons.payment_rounded,
//           theme.colorScheme.primary,
//         ),
//         _buildToolCard(
//           context,
//           theme,
//           'Expense Reports',
//           Icons.assessment_rounded,
//           Colors.blue,
//         ),
//         _buildToolCard(
//           context,
//           theme,
//           'Budget Planning',
//           Icons.pie_chart_rounded,
//           Colors.green,
//         ),
//         _buildToolCard(
//           context,
//           theme,
//           'Tax Management',
//           Icons.calculate_rounded,
//           Colors.orange,
//         ),
//       ],
//     );
//   }

//   Widget _buildToolCard(
//     BuildContext context,
//     ThemeData theme,
//     String title,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Material(
//         color: theme.colorScheme.surface,
//         child: InkWell(
//           onTap: () {
//             _showComingSoonSnackbar(context, title);
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, size: 32, color: color),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentTransactions(ThemeData theme) {
//     final transactions = [
//       {
//         'title': 'Salary Transfer',
//         'subtitle': 'John Doe - ₹45,000',
//         'icon': Icons.arrow_forward_rounded,
//         'color': Colors.green,
//       },
//       {
//         'title': 'Office Supplies',
//         'subtitle': 'Stationery Purchase - ₹12,500',
//         'icon': Icons.arrow_back_rounded,
//         'color': Colors.red,
//       },
//       {
//         'title': 'Client Payment',
//         'subtitle': 'Project Alpha - ₹2,00,000',
//         'icon': Icons.arrow_forward_rounded,
//         'color': Colors.green,
//       },
//       {
//         'title': 'Software License',
//         'subtitle': 'Annual Renewal - ₹85,000',
//         'icon': Icons.arrow_back_rounded,
//         'color': Colors.red,
//       },
//     ];

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ...transactions.map(
//               (transaction) => _buildTransactionItem(
//                 theme,
//                 transaction['title'] as String,
//                 transaction['subtitle'] as String,
//                 transaction['icon'] as IconData,
//                 transaction['color'] as Color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionItem(
//     ThemeData theme,
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 20, color: color),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             'Today',
//             style: TextStyle(
//               fontSize: 13,
//               color: theme.colorScheme.onSurface.withOpacity(0.5),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFinancialAlerts(ThemeData theme) {
//     final alerts = [
//       {
//         'title': 'Budget Overrun',
//         'message': 'Marketing department exceeded budget by 15%',
//         'color': Colors.red,
//       },
//       {
//         'title': 'Tax Filing Due',
//         'message': 'Quarterly tax filing due in 5 days',
//         'color': Colors.orange,
//       },
//       {
//         'title': 'Salary Processing',
//         'message': 'February payroll ready for processing',
//         'color': Colors.blue,
//       },
//     ];

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ...alerts.map(
//               (alert) => _buildAlertItem(
//                 theme,
//                 alert['title'] as String,
//                 alert['message'] as String,
//                 alert['color'] as Color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAlertItem(
//     ThemeData theme,
//     String title,
//     String message,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             margin: const EdgeInsets.only(top: 6),
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   message,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showComingSoonSnackbar(BuildContext context, String featureName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$featureName - Coming Soon!'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }

/*  #####################################################################################################################

***************************************         A I S C R E E N C O D E             *****************************************

############################################################################################################################ */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/view_models/theme_view_model.dart';
import '../../models/user_model.dart';
import '../../view_models/auth_view_model.dart';

class FinanceDashboardScreen extends StatelessWidget {
  final User user;

  const FinanceDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: theme.themeMode == ThemeMode.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Finance Dashboard'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showComingSoonSnackbar(context, 'Financial Alerts');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authViewModel.clearError();
                Navigator.pushReplacementNamed(context, '/login');
              } else if (value == 'reports') {
                _showComingSoonSnackbar(context, 'Financial Reports');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'reports',
                child: Row(
                  children: [
                    Icon(Icons.assessment, size: 20),
                    SizedBox(width: 8),
                    Text('Reports'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      radius: 30,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user.name}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Finance Manager',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Financial Overview
            const Text(
              'Financial Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildFinanceCard(
                  'Monthly Budget',
                  '₹4,75,000',
                  Icons.account_balance_wallet,
                  AppColors.primary,
                ),
                _buildFinanceCard(
                  'Expenses',
                  '₹3,20,150',
                  Icons.trending_down,
                  AppColors.error,
                ),
                _buildFinanceCard(
                  'Revenue',
                  '₹8,45,000',
                  Icons.trending_up,
                  AppColors.success,
                ),
                _buildFinanceCard(
                  'Profit',
                  '₹1,24,850',
                  Icons.attach_money,
                  AppColors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Payroll Summary
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payroll Summary - February 2024',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPayrollItem(
                      'Total Salary',
                      '₹3,85,000',
                      Icons.payment,
                      AppColors.primary,
                    ),
                    _buildPayrollItem(
                      'Tax Deductions',
                      '₹45,200',
                      Icons.receipt,
                      AppColors.warning,
                    ),
                    _buildPayrollItem(
                      'Net Payable',
                      '₹3,39,800',
                      Icons.account_balance,
                      AppColors.success,
                    ),
                    _buildPayrollItem(
                      'Processed',
                      '47/52',
                      Icons.check_circle,
                      AppColors.info,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Financial Tools',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildActionCard(
                  'Process Payroll',
                  Icons.payment,
                  AppColors.primary,
                  () {
                    _showComingSoonSnackbar(context, 'Payroll Processing');
                  },
                ),
                _buildActionCard(
                  'Expense Reports',
                  Icons.assessment,
                  AppColors.info,
                  () {
                    _showComingSoonSnackbar(context, 'Expense Reports');
                  },
                ),
                _buildActionCard(
                  'Budget Planning',
                  Icons.pie_chart,
                  AppColors.success,
                  () {
                    _showComingSoonSnackbar(context, 'Budget Planning');
                  },
                ),
                _buildActionCard(
                  'Tax Management',
                  Icons.calculate,
                  AppColors.warning,
                  () {
                    _showComingSoonSnackbar(context, 'Tax Management');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionItem(
                      'Salary Transfer',
                      'John Doe - ₹45,000',
                      Icons.arrow_forward,
                      AppColors.success,
                    ),
                    _buildTransactionItem(
                      'Office Supplies',
                      'Stationery Purchase - ₹12,500',
                      Icons.arrow_back,
                      AppColors.error,
                    ),
                    _buildTransactionItem(
                      'Client Payment',
                      'Project Alpha - ₹2,00,000',
                      Icons.arrow_forward,
                      AppColors.success,
                    ),
                    _buildTransactionItem(
                      'Software License',
                      'Annual Renewal - ₹85,000',
                      Icons.arrow_back,
                      AppColors.error,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Financial Alerts
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning),
                        const SizedBox(width: 8),
                        const Text(
                          'Financial Alerts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAlertItem(
                      'Budget Overrun',
                      'Marketing department exceeded budget by 15%',
                      AppColors.error,
                    ),
                    _buildAlertItem(
                      'Tax Filing Due',
                      'Quarterly tax filing due in 5 days',
                      AppColors.warning,
                    ),
                    _buildAlertItem(
                      'Salary Processing',
                      'February payroll ready for processing',
                      AppColors.info,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showComingSoonSnackbar(context, 'New Transaction');
        },
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add_chart),
      ),
    );
  }

  Widget _buildFinanceCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Today',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Coming Soon!'),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
