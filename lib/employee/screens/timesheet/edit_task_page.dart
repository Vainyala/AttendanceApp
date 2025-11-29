import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/timesheet_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import 'package:file_picker/file_picker.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late bool? readOnly ;
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
  List<AttachedFile> _attachedFiles = []; //
  late String _selectedProjectId;
  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  late DateTime _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task.taskName);
    _typeController = TextEditingController(text: widget.task.type);
    _effortController = TextEditingController(
      text: widget.task.estEffortHrs.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _deliverablesController = TextEditingController(
      text: widget.task.deliverables ?? '',
    );

    _selectedProjectId = widget.task.projectId;
    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;
    _selectedEndDate = widget.task.estEndDate;
    _actualEffortController = TextEditingController(
      text: widget.task.actualEffortHrs?.toString() ?? '',
    );
    _taskHistoryController = TextEditingController(
      text: widget.task.taskHistory ?? '',
    );
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _actualEndDate = widget.task.actualEndDate;
    _billable = widget.task.billable;
    _attachedFiles = widget.task.attachedFiles ?? [];
  }

  @override
  void dispose() {
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Edit Task', style: AppStyles.headingMedium),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textLight,
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task ID Display
                  _buildInfoCard('Task ID', widget.task.taskId),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Project Selection
                  _buildProjectDropdown(projects),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Task Name
                  _buildTextField(
                    controller: _taskNameController,
                    label: 'Task Name',
                    readOnly: true,
                    hint: 'Enter task name',
                    icon: Icons.task_alt,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),

                  // Description
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Task Description',
                    hint: 'Enter task description',
                    icon: Icons.description,
                    readOnly: true,
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Type
                  _buildTextField(
                    controller: _typeController,
                    label: 'Task Type',
                    readOnly: true,
                    hint: 'e.g., Design, Development, Testing',
                    icon: Icons.category,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task type';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Priority Dropdown
                  _buildPriorityDropdown(),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Status Dropdown
                  _buildStatusDropdown(),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // End Date Picker
                  _buildDatePicker(),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Actual End Date Picker (NEW)
                  _buildActualDatePicker(),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Effort Hours
                  _buildTextField(
                    controller: _effortController,
                    label: 'Est. Effort (Hours)',
                    hint: 'Enter estimated effort in hours',
                    icon: Icons.access_time,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter estimated effort';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),
                  // Actual Effort Hours (NEW)
                  _buildTextField(
                    controller: _actualEffortController,
                    label: 'Actual Effort (Hours)',
                    hint: 'Enter actual effort in hours',
                    icon: Icons.access_time_filled,
                    keyboardType: TextInputType.number, readOnly: false,
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Billable Toggle (NEW)
                  _buildBillableToggle(),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Task History (NEW)
                  _buildTextField(
                    controller: _taskHistoryController,
                    label: 'Task History',
                    hint: 'Enter task history',
                    icon: Icons.history,
                    maxLines: 3, readOnly: false,
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),
                  // Deliverables
                  _buildTextField(
                    controller: _deliverablesController,
                    label: 'Deliverables (Optional)',
                    hint: 'Enter expected deliverables',
                    icon: Icons.checklist,
                    maxLines: 3,
                    readOnly: false,
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // File Attachments Section (NEW)
                  _buildFileAttachmentsSection(),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Notes (NEW)
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    hint: 'Enter any additional notes',
                    icon: Icons.note,
                    readOnly: false,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => _updateTask(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Update Task',
                        style: AppStyles.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActualDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actual End Date', style: AppStyles.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _actualEndDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _actualEndDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  _actualEndDate != null
                      ? '${_actualEndDate!.day}/${_actualEndDate!.month}/${_actualEndDate!.year}'
                      : 'Select actual end date',
                  style: AppStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillableToggle() {
    return Row(
      children: [
        const Text('Billable', style: AppStyles.label),

        const Spacer(),
        Switch(
          value: _billable,
          onChanged: (value) {
            setState(() {
              _billable = value;
            });
          },
          activeColor: AppColors.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildFileAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Attachments', style: AppStyles.label),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.attach_file, size: 18),
              label: const Text('Browse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_attachedFiles.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.grey300),
            ),
            child: const Center(
              child: Text('No files attached', style: AppStyles.caption),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.grey300),
            ),
            child: Column(
              children: _attachedFiles.map((file) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        file.fileType == 'pdf'
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          file.fileName,
                          style: AppStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _attachedFiles.remove(file);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _pickFiles() async {
    // TODO: Implement file picker using file_picker package
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker implementation needed'),
        backgroundColor: AppColors.info,
      ),
    );

    // Example implementation would be:
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        _attachedFiles.addAll(result.files.map((file) => AttachedFile(
          fileName: file.name,
          filePath: file.path!,
          fileType: file.extension!,
        )));
      });
    }
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.labelMedium),
          Text(
            value,
            style: AppStyles.headingSmall.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool readOnly,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          decoration: AppStyles.getInputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildProjectDropdown(List<Map<String, String>> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Project', style: AppStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedProjectId,

            decoration:
                AppStyles.getInputDecoration(
                  hintText: 'Select project',
                  prefixIcon: const Icon(
                    Icons.work_outline,
                    color: AppColors.primaryBlue,
                  ),
                ).copyWith(
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primaryBlue,
                  ), // NEW
                ),
            items: projects.map((project) {
              return DropdownMenuItem(
                value: project['id'],
                child: Text('${project['name']} (${project['id']})'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProjectId = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a project';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority', style: AppStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: DropdownButtonFormField<TaskPriority>(
            value: _selectedPriority,
            decoration: AppStyles.getInputDecoration(
              hintText: 'Select priority',
              prefixIcon: const Icon(Icons.flag, color: AppColors.primaryBlue),
            ),
            items: TaskPriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: AppStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: DropdownButtonFormField<TaskStatus>(
            value: _selectedStatus,
            decoration: AppStyles.getInputDecoration(
              hintText: 'Select status',
              prefixIcon: const Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
              ),
            ),
            items: TaskStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Est. End Date', style: AppStyles.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedEndDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedEndDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  '${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year}',
                  style: AppStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
        description: _descriptionController.text, // Required
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
