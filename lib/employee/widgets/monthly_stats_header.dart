import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/regularisation_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class MonthlyStatsHeader extends StatelessWidget {
  final DateTime month;

  const MonthlyStatsHeader({
    super.key,
    required this.month,
  });

  void _handleDownload(BuildContext context) {
    // TODO: Implement download functionality
    // You can generate PDF/Excel report here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Downloading report...'),
        backgroundColor: AppColors.success.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RegularisationProvider>();
    final stats = provider.getMonthlyStatistics(month);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.textLight, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Monthly Overview',
                  style: AppStyles.headingLarge.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              // Download Icon Button
              Material(
                color: AppColors.textLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _handleDownload(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.download_rounded,
                      color: AppColors.textLight,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg. Shortfall',
                  stats['avgShortfall'] ?? '00:00',
                  Icons.trending_down,
                  AppColors.error.shade100,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Total Days',
                  '${stats['totalDays'] ?? 0}',
                  Icons.calendar_today,
                  AppColors.success.shade100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSmallStatCard(
                  'Apply',
                  stats['Apply'] ?? 0,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallStatCard(
                  'Pending',
                  stats['Pending'] ?? 0,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallStatCard(
                  'Approved',
                  stats['Approved'] ?? 0,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallStatCard(
                  'Rejected',
                  stats['Rejected'] ?? 0,
                  AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color bgColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppStyles.headingLarge.copyWith(
              fontSize: 20,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppStyles.text.copyWith(fontSize: 8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String label, int count, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppStyles.heading.copyWith(
              color: color.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.text.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}