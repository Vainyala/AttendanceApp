
import 'package:flutter/material.dart';

import '../../core/view_models/theme_view_model.dart';
import '../../models/regularisationmodels/regularisation_model.dart';

class RegularisationHistory extends StatelessWidget {
  final List<RegularisationRequest> requests;
  final Function(RegularisationRequest) onItemTap;

  const RegularisationHistory({
    super.key,
    required this.requests,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildHistoryItem(request, context);
      },
    );
  }

  Widget _buildHistoryItem(
    RegularisationRequest request,
    BuildContext context,
  ) {
    return ListTile(
      leading: _buildStatusIcon(request.status),
      title: Text(
        request.formattedDate,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        request.reason,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _getStatusText(request.status),
        style: TextStyle(
          color: _getStatusColor(request.status),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => onItemTap(request),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildStatusIcon(RegularisationStatus status) {
    switch (status) {
      case RegularisationStatus.pending:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pending, color: Colors.orange, size: 20),
        );
      case RegularisationStatus.approved:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
        );
      case RegularisationStatus.rejected:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cancel, color: Colors.red, size: 20),
        );
      case RegularisationStatus.cancelled:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.grey400.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.cancel, color: AppColors.grey400, size: 20),
        );
    }
  }

  Color _getStatusColor(RegularisationStatus status) {
    switch (status) {
      case RegularisationStatus.pending:
        return Colors.orange;
      case RegularisationStatus.approved:
        return Colors.green;
      case RegularisationStatus.rejected:
        return Colors.red;
      case RegularisationStatus.cancelled:
        return AppColors.grey500;
    }
  }

  String _getStatusText(RegularisationStatus status) {
    switch (status) {
      case RegularisationStatus.pending:
        return 'Pending';
      case RegularisationStatus.approved:
        return 'Approved';
      case RegularisationStatus.rejected:
        return 'Rejected';
      case RegularisationStatus.cancelled:
        return 'Cancelled';
    }
  }
}
