import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import '../../widgets/date_time_utils.dart';
import 'edit_task_page.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get priorityColor {
    switch (widget.task.priority) {
      case TaskPriority.urgent:
        return AppColors.error;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.medium:
        return AppColors.info;
      case TaskPriority.normal:
        return AppColors.success;
    }
  }

  Color get statusColor {
    switch (widget.task.status) {
      case TaskStatus.open:
        return AppColors.info;
      case TaskStatus.assigned:
      case TaskStatus.pending:
        return AppColors.warning;
      case TaskStatus.resolved:
        return AppColors.success;
      case TaskStatus.closed:
        return AppColors.grey600;
    }
  }

  IconData get statusIcon {
    switch (widget.task.status) {
      case TaskStatus.open:
        return Icons.inbox;
      case TaskStatus.assigned:
        return Icons.assignment_ind;
      case TaskStatus.pending:
        return Icons.pending;
      case TaskStatus.resolved:
        return Icons.check_circle;
      case TaskStatus.closed:
        return Icons.lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 20),
                      _buildQuickStatsRow(),
                      const SizedBox(height: 24),
                      _buildTaskDetailsCard(),
                      const SizedBox(height: 20),
                      _buildTimelineCard(),
                      const SizedBox(height: 20),
                      if (widget.task.description.isNotEmpty) ...[
                        _buildDescriptionCard(),
                        const SizedBox(height: 20),
                      ],
                      if (widget.task.deliverables != null && widget.task.deliverables!.isNotEmpty) ...[
                        _buildDeliverablesCard(),
                        const SizedBox(height: 20),
                      ],
                      if (widget.task.taskHistory != null && widget.task.taskHistory!.isNotEmpty) ...[
                        _buildHistoryCard(),
                        const SizedBox(height: 20),
                      ],
                      if (widget.task.notes != null && widget.task.notes!.isNotEmpty) ...[
                        _buildNotesCard(),
                        const SizedBox(height: 20),
                      ],
                      if (widget.task.managerComments != null && widget.task.managerComments!.isNotEmpty) ...[
                        _buildCommentsCard(),
                        const SizedBox(height: 20),
                      ],
                      if (widget.task.attachedFiles != null && widget.task.attachedFiles!.isNotEmpty) ...[
                        _buildAttachmentsCard(),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingEditButton(),
    );
  }

  SliverAppBar _buildModernAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.task.projectName,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.grey200, height: 1),
      ),
    );
  }


  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [priorityColor, priorityColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // IMPORTANT: let inner Column size itself (shrink wrap)
      child: Column(
        mainAxisSize: MainAxisSize.min, // <- prevents flex-in-unbounded errors
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tag, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.task.taskId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(), // <-- If you must keep a Spacer in this row it's fine (row has bounded height)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.task.priority.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            widget.task.taskName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12), // <-- replaces the old Spacer which caused error

          // Status chip aligned to start
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  widget.task.status.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.category_outlined,
            label: 'Type',
            value: widget.task.type,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            label: 'Effort',
            value: '${widget.task.estEffortHrs}h',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: widget.task.billable ? Icons.attach_money : Icons.money_off,
            label: 'Billable',
            value: widget.task.billable ? 'Yes' : 'No',
            color: widget.task.billable ? AppColors.success : AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey600),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey600),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Project Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            icon: Icons.folder_outlined,
            label: 'Project ID',
            value: widget.task.projectId,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.work_outline,
            label: 'Project Name',
            value: widget.task.projectName,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey600),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Timeline & Effort',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            icon: Icons.calendar_today,
            label: 'Estimated End Date',
            value: DateFormattingUtils.formatDate(widget.task.estEndDate),
            color: AppColors.info,
          ),
          if (widget.task.actualEndDate != null) ...[
            const SizedBox(height: 16),
            _buildTimelineItem(
              icon: Icons.event_available,
              label: 'Actual End Date',
              value: DateFormattingUtils.formatDate(widget.task.actualEndDate!),
              color: AppColors.success,
            ),
          ],
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildEffortBox(
                  label: 'Estimated Efforts',
                  value: '${widget.task.estEffortHrs}h',
                  icon: Icons.access_time,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              if (widget.task.actualEffortHrs != null)
                Expanded(
                  child: _buildEffortBox(
                    label: 'Actual Efforts',
                    value: '${widget.task.actualEffortHrs}h',
                    icon: Icons.timer,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey600),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEffortBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return _buildContentCard(
      icon: Icons.description,
      title: 'Description',
      content: widget.task.description,
      color: AppColors.primaryBlue,
    );
  }

  Widget _buildDeliverablesCard() {
    return _buildContentCard(
      icon: Icons.checklist_rtl,
      title: 'Deliverables',
      content: widget.task.deliverables!,
      color: AppColors.success,
    );
  }

  Widget _buildHistoryCard() {
    return _buildContentCard(
      icon: Icons.history,
      title: 'Task History',
      content: widget.task.taskHistory!,
      color: AppColors.info,
    );
  }

  Widget _buildNotesCard() {
    return _buildContentCard(
      icon: Icons.note_alt_outlined,
      title: 'Notes',
      content: widget.task.notes!,
      color: AppColors.warning,
    );
  }

  Widget _buildCommentsCard() {
    return _buildContentCard(
      icon: Icons.chat_bubble_outline,
      title: 'Manager Comments',
      content: widget.task.managerComments!,
      color: AppColors.primaryBlue,
    );
  }

  Widget _buildContentCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey600),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey600),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_file, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.task.attachedFiles!.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.task.attachedFiles!.map((file) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      file.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          file.fileType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, size: 20),
                    color: AppColors.primaryBlue,
                    onPressed: () {
                      // TODO: Implement download
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }



  Widget _buildFloatingEditButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTaskPage(task: widget.task),
          ),
        );
      },
      backgroundColor: AppColors.primaryBlue,
      icon: const Icon(Icons.edit, size: 20),
      label: const Text(
        'Edit Task',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 4,
    );
  }
}