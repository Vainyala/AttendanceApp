import 'package:flutter/material.dart';

import '../../core/view_models/theme_view_model.dart';

class RegularisationStats extends StatelessWidget {
  final Map<String, int> stats;

  const RegularisationStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Request Overview',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  stats['total']?.toString() ?? '0',
                  Icons.list_alt,
                  AppColors.primary,
                ),
                _buildStatItem(
                  'Pending',
                  stats['pending']?.toString() ?? '0',
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Approved',
                  stats['approved']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Rejected',
                  stats['rejected']?.toString() ?? '0',
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey600),
        ),
      ],
    );
  }
}
