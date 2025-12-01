import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/timesheet_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';
import 'package:file_picker/file_picker.dart';

import '../../widgets/date_time_utils.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _typeController = TextEditingController();
  final _effortController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deliverablesController = TextEditingController();
  final _notesController = TextEditingController(); // NEW
  bool _billable = false;
  String? _selectedProjectId;
  TaskPriority _selectedPriority = TaskPriority.normal;
  TaskStatus _selectedStatus = TaskStatus.open;
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 7));
  List<AttachedFile> _attachedFiles = []; //
  @override
  void dispose() {
    _taskNameController.dispose();
    _typeController.dispose();
    _effortController.dispose();
    _descriptionController.dispose();
    _deliverablesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimesheetProvider>(
      builder: (context, provider, child) {
        final projects = provider.projects;
        _selectedProjectId ??= projects.isNotEmpty ? projects[0]['id'] : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Create New Task',
              style: AppStyles.headingMedium,
            ),
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
                  _buildInfoCard(
                    'Task ID (Auto-generated)',
                    provider.generateTaskId(),
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Project Selection
                  _buildProjectDropdown(projects),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Task Name
                  _buildTextField(
                    controller: _taskNameController,
                    label: 'Task Name',
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
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),

                  // Type
                  _buildTextField(
                    controller: _typeController,
                    label: 'Task Type',
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

                  // Effort Hours
                  _buildTextField(
                    controller: _effortController,
                    label: 'Est. Effort (Hours)',
                    hint: 'Enter estimated effort in hours',
                    icon: Icons.access_time,
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

                  // Billable Toggle (NEW)
                  _buildBillableToggle(),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Deliverables
                  _buildTextField(
                    controller: _deliverablesController,
                    label: 'Deliverables (Optional)',
                    hint: 'Enter expected deliverables',
                    icon: Icons.checklist,
                    maxLines: 3,
                  ),
// Notes (NEW)
                  const SizedBox(height: AppDimensions.marginLarge),

                  // File Attachments Section (NEW)
                  _buildFileAttachmentsSection(),

                  const SizedBox(height: AppDimensions.marginLarge),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes',
                    hint: 'Enter any additional notes',
                    icon: Icons.note,
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppDimensions.marginLarge),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => _submitTask(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Create Task',
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

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.labelMedium.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
          Text(
            value,
            style: AppStyles.headingSmall.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
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
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.label,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
        const Text(
          'Project',
          style: AppStyles.label,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedProjectId,
            decoration: AppStyles.getInputDecoration(
              hintText: 'Select project',
              prefixIcon: const Icon(Icons.work_outline, color: AppColors.primaryBlue),
            ),
            items: projects.map((project) {
              return DropdownMenuItem(
                value: project['id'],
                child: Text('${project['name']} (${project['id']})'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProjectId = value;
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
        const Text(
          'Priority',
          style: AppStyles.label,
        ),
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
        const Text(
          'Status',
          style: AppStyles.label,
        ),
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
              prefixIcon: const Icon(Icons.info_outline, color: AppColors.primaryBlue),
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
        const Text(
          'Est. End Date',
          style: AppStyles.label,
        ),
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
                  DateFormattingUtils.formatDate(_selectedEndDate), // Use utility
                  style: AppStyles.bodyMedium,
                ),
              ],
            ),
          ),
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
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachedFiles.addAll(
            result.files.map((file) => AttachedFile(
              fileName: file.name,
              filePath: file.path ?? '',
              fileType: file.extension ?? '',
            )),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} file(s) attached successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking files. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  void _submitTask(TimesheetProvider provider) {
    if (_formKey.currentState!.validate()) {
      final projectName = provider.projects
          .firstWhere((p) => p['id'] == _selectedProjectId)['name']!;

      final newTask = Task(
        taskId: provider.generateTaskId(),
        projectId: _selectedProjectId!,
        projectName: projectName,
        taskName: _taskNameController.text,
        type: _typeController.text,
        priority: _selectedPriority,
        estEndDate: _selectedEndDate,
        estEffortHrs: double.parse(_effortController.text),
        status: _selectedStatus,
        description: _descriptionController.text, // Required now
        deliverables: _deliverablesController.text.isEmpty
            ? null
            : _deliverablesController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text, // NEW
        billable: _billable, // NEW
      );

      provider.addTask(newTask);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }
}