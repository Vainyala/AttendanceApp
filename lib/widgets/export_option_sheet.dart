

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'dart:ui';

// Export Options Sheet
class ExportOptionsSheet extends StatelessWidget {
  final Function(String) onExport;

  const ExportOptionsSheet({super.key, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.textHint.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Export Attendance Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildExportOption(
            context,
            icon: Icons.picture_as_pdf,
            title: 'Export as PDF',
            subtitle: 'Download attendance report',
            color: AppColors.error,
            format: 'PDF',
          ),
          _buildExportOption(
            context,
            icon: Icons.table_chart,
            title: 'Export as Excel',
            subtitle: 'Download .xlsx file',
            color: AppColors.success,
            format: 'Excel',
          ),
          _buildExportOption(
            context,
            icon: Icons.description,
            title: 'Export as CSV',
            subtitle: 'Download .csv file',
            color: Colors.blue,
            format: 'CSV',
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required String format,
      }) {
    return InkWell(
      onTap: () => onExport(format),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}