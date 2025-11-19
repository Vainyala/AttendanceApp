
import 'package:flutter/material.dart';

import '../../core/view_models/theme_view_model.dart';
import '../../view_models/regularisationviewmodel/regularisation_view_model.dart';

class RegularisationFilters extends StatelessWidget {
  final RegularisationFilter currentFilter;
  final Function(RegularisationFilter) onFilterChanged;

  const RegularisationFilters({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 4),
          _buildFilterChip('All', RegularisationFilter.all),
          _buildFilterChip('Pending', RegularisationFilter.pending),
          _buildFilterChip('Approved', RegularisationFilter.approved),
          _buildFilterChip('Rejected', RegularisationFilter.rejected),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, RegularisationFilter filter) {
    final isSelected = currentFilter == filter;

    Color getChipColor() {
      switch (filter) {
        case RegularisationFilter.pending:
          return Colors.orange;
        case RegularisationFilter.approved:
          return Colors.green;
        case RegularisationFilter.rejected:
          return Colors.red;
        case RegularisationFilter.all:
        default:
          return AppColors.primary;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.grey700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onFilterChanged(filter),
        backgroundColor: AppColors.grey100,
        selectedColor: getChipColor(),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        elevation: isSelected ? 1 : 0,
        shadowColor: Colors.transparent,
      ),
    );
  }
}
