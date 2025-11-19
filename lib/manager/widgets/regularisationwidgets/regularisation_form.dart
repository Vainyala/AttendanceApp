// // widgets/regularisation/regularisation_form.dart
// import 'package:attendanceapp/models/regularisationmodels/regularisation_model.dart';
// import 'package:attendanceapp/view_models/regularisationviewmodel/regularisation_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class RegularisationForm extends StatefulWidget {
//   final RegularisationRequest? request;
//   final Function(RegularisationFormData) onSubmit;

//   const RegularisationForm({super.key, this.request, required this.onSubmit});

//   @override
//   State<RegularisationForm> createState() => _RegularisationFormState();
// }

// class _RegularisationFormState extends State<RegularisationForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _reasonController = TextEditingController();

//   late RegularisationFormData _formData;

//   @override
//   void initState() {
//     super.initState();
//     _formData = widget.request != null
//         ? _convertRequestToFormData(widget.request!)
//         : RegularisationFormData();

//     _reasonController.text = _formData.reason;
//   }

//   RegularisationFormData _convertRequestToFormData(
//     RegularisationRequest request,
//   ) {
//     final formData = RegularisationFormData();
//     formData.projectId = request.projectId;
//     formData.date = request.date;
//     formData.type = request.type;
//     formData.reason = request.reason;
//     return formData;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.read<RegularisationViewModel>();

//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               widget.request == null
//                   ? 'New Regularisation Request'
//                   : 'Edit Request',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             // Project Dropdown
//             DropdownButtonFormField<String>(
//               initialValue: _formData.projectId.isEmpty
//                   ? null
//                   : _formData.projectId,
//               decoration: const InputDecoration(
//                 labelText: 'Project',
//                 border: OutlineInputBorder(),
//               ),
//               items: viewModel.userProjects.map((project) {
//                 return DropdownMenuItem(
//                   value: project.id,
//                   child: Text(project.name),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _formData.projectId = value!;
//                 });
//               },
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please select a project';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Date Picker
//             InkWell(
//               onTap: () => _selectDate(context),
//               child: InputDecorator(
//                 decoration: const InputDecoration(
//                   labelText: 'Date',
//                   border: OutlineInputBorder(),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(_formData.date.toString().split(' ')[0]),
//                     const Icon(Icons.calendar_today),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Type Selection
//             DropdownButtonFormField<RegularisationType>(
//               initialValue: _formData.type,
//               decoration: const InputDecoration(
//                 labelText: 'Regularisation Type',
//                 border: OutlineInputBorder(),
//               ),
//               items: RegularisationType.values.map((type) {
//                 return DropdownMenuItem(
//                   value: type,
//                   child: Text(viewModel.getTypeText(type)),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _formData.type = value!;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),

//             // Reason
//             TextFormField(
//               controller: _reasonController,
//               decoration: const InputDecoration(
//                 labelText: 'Reason',
//                 border: OutlineInputBorder(),
//                 hintText: 'Please provide a valid reason for regularisation...',
//               ),
//               maxLines: 3,
//               onChanged: (value) {
//                 _formData.reason = value;
//               },
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please provide a reason';
//                 }
//                 if (value.length < 10) {
//                   return 'Reason should be at least 10 characters';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 24),

//             // Submit Button
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   widget.onSubmit(_formData);
//                 }
//               },
//               child: Text(
//                 widget.request == null ? 'Submit Request' : 'Update Request',
//               ),
//             ),
//             const SizedBox(height: 8),

//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _formData.date,
//       firstDate: DateTime.now().subtract(const Duration(days: 30)),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null && picked != _formData.date) {
//       setState(() {
//         _formData.date = picked;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }
// }
