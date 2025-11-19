// import 'package:attendanceapp/models/regularisationmodels/regularisation_model.dart';
// import 'package:attendanceapp/view_models/regularisationviewmodel/regularisation_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';

// class RegularisationList extends StatelessWidget {
//   final List<RegularisationRequest> requests;
//   final RegularisationViewModel viewModel;
//   final Function(RegularisationRequest) onEdit;
//   final Function(String) onCancel;

//   const RegularisationList({
//     super.key,
//     required this.requests,
//     required this.viewModel,
//     required this.onEdit,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (requests.isEmpty) {
//       return _buildEmptyState();
//     }

//     return ListView.builder(
//       itemCount: requests.length,
//       itemBuilder: (context, index) {
//         final request = requests[index];
//         return _buildRequestCard(request, context);
//       },
//     );
//   }

//   Widget _buildRequestCard(
//     RegularisationRequest request,
//     BuildContext context,
//   ) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 1,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with Project and Status
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     viewModel.getProjectName(request.projectId),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 _buildStatusChip(request.status),
//               ],
//             ),
//             const SizedBox(height: 8),

//             // Date and Type
//             Row(
//               children: [
//                 Icon(Icons.calendar_today, size: 16, color: AppColors.grey600),
//                 const SizedBox(width: 4),
//                 Text(
//                   request.formattedDate,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(width: 16),
//                 Icon(Icons.access_time, size: 16, color: AppColors.grey600),
//                 const SizedBox(width: 4),
//                 Text(
//                   viewModel.getTypeText(request.type),
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             // Reason
//             Text(
//               request.reason,
//               style: const TextStyle(fontSize: 14, color: AppColors.grey700),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 12),

//             // Footer with Actions and Dates
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Requested Date
//                 Expanded(
//                   child: Text(
//                     'Requested: ${_formatDateTime(request.requestedDate)}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: AppColors.grey600,
//                     ),
//                   ),
//                 ),

//                 // Actions
//                 if (request.isPending) _buildPendingActions(request, context),
//                 if (request.isApproved) _buildApprovedInfo(request),
//                 if (request.isRejected) _buildRejectedInfo(request),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(RegularisationStatus status) {
//     return Chip(
//       label: Text(
//         viewModel.getStatusText(status).toUpperCase(),
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//       backgroundColor: viewModel.getStatusColor(status),
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//       visualDensity: VisualDensity.compact,
//     );
//   }

//   Widget _buildPendingActions(
//     RegularisationRequest request,
//     BuildContext context,
//   ) {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.edit, size: 18),
//           onPressed: () => onEdit(request),
//           color: AppColors.primary,
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//         ),
//         const SizedBox(width: 8),
//         IconButton(
//           icon: const Icon(Icons.cancel, size: 18),
//           onPressed: () => onCancel(request.id),
//           color: Colors.red,
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//         ),
//       ],
//     );
//   }

//   Widget _buildApprovedInfo(RegularisationRequest request) {
//     return Row(
//       children: [
//         Icon(Icons.verified, size: 16, color: Colors.green),
//         const SizedBox(width: 4),
//         Text(
//           'Approved',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.green[700],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         if (request.approvedDate != null) ...[
//           const SizedBox(width: 4),
//           Text(
//             _formatDateTime(request.approvedDate!),
//             style: const TextStyle(fontSize: 12, color: AppColors.grey600),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildRejectedInfo(RegularisationRequest request) {
//     return Row(
//       children: [
//         Icon(Icons.info, size: 16, color: Colors.red),
//         const SizedBox(width: 4),
//         Text(
//           'Rejected',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.red[700],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.pending_actions, size: 64, color: AppColors.grey400),
//           const SizedBox(height: 16),
//           Text(
//             _getEmptyStateMessage(),
//             style: const TextStyle(fontSize: 16, color: AppColors.grey600),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _getEmptyStateSubtitle(),
//             style: const TextStyle(fontSize: 14, color: AppColors.grey500),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   String _getEmptyStateMessage() {
//     switch (viewModel.currentFilter) {
//       case RegularisationFilter.pending:
//         return 'No pending requests';
//       case RegularisationFilter.approved:
//         return 'No approved requests';
//       case RegularisationFilter.rejected:
//         return 'No rejected requests';
//       case RegularisationFilter.all:
//       default:
//         return 'No regularisation requests';
//     }
//   }

//   String _getEmptyStateSubtitle() {
//     switch (viewModel.currentFilter) {
//       case RegularisationFilter.pending:
//         return 'All your requests have been processed';
//       case RegularisationFilter.approved:
//         return 'Your approved requests will appear here';
//       case RegularisationFilter.rejected:
//         return 'Your rejected requests will appear here';
//       case RegularisationFilter.all:
//       default:
//         return 'Create your first regularisation request';
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//   }
// }
