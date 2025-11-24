import 'package:attendanceapp/manager/models/projectmodels/project_models.dart';
import 'package:attendanceapp/manager/view_models/projectviewmodels/project_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final ProjectFormData _formData = ProjectFormData();

  final List<String> _statusOptions = [
    'planning',
    'active',
    'completed',
    'on-hold',
  ];
  final List<String> _priorityOptions = ['low', 'medium', 'high', 'urgent'];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProjectViewModel>(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Project',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Project Name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project name';
                  }
                  return null;
                },
                onSaved: (value) => _formData.name = value!,
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_rounded),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project description';
                  }
                  return null;
                },
                onSaved: (value) => _formData.description = value!,
              ),

              const SizedBox(height: 16),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      readOnly: true,
                      onTap: () => _selectStartDate(context),
                      controller: TextEditingController(
                        text: _formatDate(_formData.startDate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_rounded),
                      ),
                      readOnly: true,
                      onTap: () => _selectEndDate(context),
                      controller: TextEditingController(
                        text: _formatDate(_formData.endDate),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status & Priority
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        //prefixIcon: Icon(Icons.status_rounded),
                      ),
                      initialValue: _formData.status,
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_capitalize(status)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _formData.status = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high_rounded),
                      ),
                      initialValue: _formData.priority,
                      items: _priorityOptions.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(_capitalize(priority)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _formData.priority = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Budget
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Budget (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _formData.budget = double.parse(value!),
              ),

              const SizedBox(height: 16),

              // Client
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
                onSaved: (value) => _formData.client = value!,
              ),

              const SizedBox(height: 20),

              // Team Assignment Section
              _buildTeamAssignmentSection(viewModel),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _createProject(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Create Project',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamAssignmentSection(ProjectViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign Team Members',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select team members to assign to this project',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // Team Members List
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.availableTeam.length,
            itemBuilder: (context, index) {
              final member = viewModel.availableTeam[index];
              final isSelected = _formData.assignedTeamIds.contains(
                member.email,
              );

              return CheckboxListTile(
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected!) {
                      _formData.assignedTeamIds.add(member.email);
                    } else {
                      _formData.assignedTeamIds.remove(member.email);
                    }
                  });
                },
                title: Text(member.name),
                subtitle: Text(member.role),
                secondary: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    member.name[0],
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formData.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _formData.startDate) {
      setState(() {
        _formData.startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formData.endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _formData.endDate) {
      setState(() {
        _formData.endDate = picked;
      });
    }
  }

  void _createProject(ProjectViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate end date is after start date
      if (_formData.endDate.isBefore(_formData.startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date must be after start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate team assignment
      if (_formData.assignedTeamIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please assign at least one team member'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await viewModel.createProject(_formData);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create project: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalize(String text) {
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
