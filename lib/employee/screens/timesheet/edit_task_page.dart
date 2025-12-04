import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/task_model.dart';
import '../../providers/timesheet_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/timesheet_widgets/create_edit_widgets/billable_attatchments.dart';
import '../../widgets/timesheet_widgets/create_edit_widgets/date_pickers.dart';
import '../../widgets/timesheet_widgets/create_edit_widgets/project_dropdown.dart';
import '../../widgets/timesheet_widgets/create_edit_widgets/status_priority_selector.dart';
import '../../widgets/timesheet_widgets/create_edit_widgets/task_action_btn.dart';
import '../../widgets/timesheet_widgets/create_edit_widgets/task_id_card.dart';
import '../../widgets/timesheet_widgets/create_edit_widgets/text_fields.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

// FIXED: Added SingleTickerProviderStateMixin
class _EditTaskPageState extends State<EditTaskPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _taskNameController;
  late TextEditingController _typeController;
  late TextEditingController _effortController;
  late TextEditingController _descriptionController;
  late TextEditingController _deliverablesController;
  late TextEditingController _actualEffortController;
  late TextEditingController _taskHistoryController;
  late TextEditingController _notesController;
  late DateTime? _actualEndDate;
  late bool _billable;
  late List<AttachedFile> _attachedFiles;
  late String _selectedProjectId;
  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  late DateTime _selectedEndDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with task data
    _taskNameController = TextEditingController(text: widget.task.taskName);
    _typeController = TextEditingController(text: widget.task.type);
    _effortController = TextEditingController(text: widget.task.estEffortHrs.toString());
    _descriptionController = TextEditingController(text: widget.task.description);
    _deliverablesController = TextEditingController(text: widget.task.deliverables ?? '');
    _actualEffortController = TextEditingController(
        text: widget.task.actualEffortHrs?.toString() ?? ''
    );
    _taskHistoryController = TextEditingController(text: widget.task.taskHistory ?? '');
    _notesController = TextEditingController(text: widget.task.notes ?? '');

    _actualEndDate = widget.task.actualEndDate;
    _billable = widget.task.billable;
    _attachedFiles = widget.task.attachedFiles ?? [];
    _selectedProjectId = widget.task.projectId;
    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;
    _selectedEndDate = widget.task.estEndDate;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _taskNameController.dispose();
    _typeController.dispose();
    _effortController.dispose();
    _descriptionController.dispose();
    _deliverablesController.dispose();
    _actualEffortController.dispose();
    _taskHistoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimesheetProvider>(
      builder: (context, provider, child) {
        final projects = provider.projects;

        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: _buildModernAppBar(),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Using reusable widget
                    TaskIdCard(taskId: widget.task.taskId),

                    const SizedBox(height: 24),
                    const SectionTitle(
                      title: 'Task Information',
                      icon: Icons.info_outline,
                    ),
                    const SizedBox(height: 16),
                    ModernCard(
                      child: Column(
                        children: [
                          ProjectDropdown(
                            selectedProjectId: _selectedProjectId,
                            projects: projects,
                            onChanged: (value) {
                              setState(() {
                                _selectedProjectId = value!;
                              });
                            },
                            enabled: false, // Can't change project in edit mode
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            controller: _taskNameController,
                            label: 'Task Name',
                            hint: 'Enter a descriptive task name',
                            icon: Icons.task_alt,
                            readOnly: true, // Read-only in edit mode
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Task name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            controller: _descriptionController,
                            label: 'Task Description',
                            hint: 'What needs to be done?',
                            icon: Icons.description,
                            maxLines: 3,
                            readOnly: true, // Read-only in edit mode
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            controller: _typeController,
                            label: 'Task Type',
                            hint: 'e.g., Design, Development, Testing',
                            icon: Icons.category,
                            readOnly: true, // Read-only in edit mode
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Task type is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const SectionTitle(
                      title: 'Task Settings',
                      icon: Icons.settings_outlined,
                    ),
                    const SizedBox(height: 16),
                    ModernCard(
                      child: Column(
                        children: [
                          PrioritySelector(
                            selectedPriority: _selectedPriority,
                            onChanged: (priority) {
                              setState(() {
                                _selectedPriority = priority;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          StatusSelector(
                            selectedStatus: _selectedStatus,
                            onChanged: (status) {
                              setState(() {
                                _selectedStatus = status;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ModernDatePicker(
                            label: 'Estimated End Date',
                            selectedDate: _selectedEndDate,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedEndDate = date;
                              });
                            },
                            firstDate: DateTime.now(),
                          ),
                          const SizedBox(height: 20),
                          NullableDatePicker(
                            label: 'Actual End Date',
                            selectedDate: _actualEndDate,
                            onDateSelected: (date) {
                              setState(() {
                                _actualEndDate = date;
                              });
                            },
                            firstDate: DateTime(2020),
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            controller: _effortController,
                            label: 'Estimated Effort (Hours)',
                            hint: 'Enter hours',
                            icon: Icons.access_time,
                            keyboardType: TextInputType.number,
                            readOnly: true, // Read-only in edit mode
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Effort is required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            controller: _actualEffortController,
                            label: 'Actual Effort (Hours)',
                            hint: 'Enter actual effort in hours',
                            icon: Icons.access_time_filled,
                            keyboardType: TextInputType.number,
                            readOnly: false, // Editable
                          ),
                          const SizedBox(height: 20),
                          BillableSwitch(
                            billable: _billable,
                            onChanged: (value) {
                              setState(() {
                                _billable = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const SectionTitle(
                      title: 'Additional Details',
                      icon: Icons.add_circle_outline,
                    ),
                    const SizedBox(height: 16),
                    ModernCard(
                      child: Column(
                        children: [
                          ModernTextField(
                            controller: _taskHistoryController,
                            label: 'Task History',
                            hint: 'Enter task history',
                            icon: Icons.history,
                            maxLines: 3,
                            readOnly: false, // Editable
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            controller: _deliverablesController,
                            label: 'Deliverables',
                            hint: 'Expected deliverables (optional)',
                            icon: Icons.checklist,
                            maxLines: 3,
                            readOnly: false, // Editable
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            controller: _notesController,
                            label: 'Notes',
                            hint: 'Additional notes (optional)',
                            icon: Icons.note,
                            maxLines: 3,
                            readOnly: false, // Editable
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const SectionTitle(
                      title: 'Attachments',
                      icon: Icons.attach_file,
                    ),
                    const SizedBox(height: 16),
                    AttachmentsSection(
                      attachedFiles: _attachedFiles,
                      onAddFiles: _pickFiles,
                      onRemoveFile: (file) {
                        setState(() {
                          _attachedFiles.remove(file);
                        });
                      },
                    ),

                    const SizedBox(height: 32),
                    TaskActionButton(
                      label: 'Update Task',
                      onPressed: () => _updateTask(provider),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Edit Task',
        style: TextStyle(
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

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachedFiles.addAll(
            result.files.map(
                  (file) => AttachedFile(
                fileName: file.name,
                filePath: file.path ?? '',
                fileType: file.extension ?? '',
              ),
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.files.length} file(s) attached successfully',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking files. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateTask(TimesheetProvider provider) {
    if (_formKey.currentState!.validate()) {
      final projectName = provider.projects.firstWhere(
            (p) => p['id'] == _selectedProjectId,
      )['name']!;

      final updatedTask = Task(
        taskId: widget.task.taskId,
        projectId: _selectedProjectId,
        projectName: projectName,
        taskName: _taskNameController.text,
        type: _typeController.text,
        priority: _selectedPriority,
        estEndDate: _selectedEndDate,
        actualEndDate: _actualEndDate,
        estEffortHrs: double.parse(_effortController.text),
        actualEffortHrs: _actualEffortController.text.isEmpty
            ? null
            : double.parse(_actualEffortController.text),
        status: _selectedStatus,
        description: _descriptionController.text,
        deliverables: _deliverablesController.text.isEmpty
            ? null
            : _deliverablesController.text,
        taskHistory: _taskHistoryController.text.isEmpty
            ? null
            : _taskHistoryController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        billable: _billable,
        attachedFiles: _attachedFiles.isEmpty ? null : _attachedFiles,
      );

      provider.updateTask(widget.task.taskId, updatedTask);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }
}