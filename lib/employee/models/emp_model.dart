class EmployeeModel {
  final String id;
  final String name;
  final String designation;
  final String email;
  final String phone;
  final String status;
  final String? avatarUrl;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.email,
    required this.phone,
    required this.status,
    this.avatarUrl,
  });
}