import 'project_model.dart'; // make sure you import ProjectModel

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String department;
  final List<ProjectModel> projects;



  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.department,
    required this.projects,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'department' : department,
    'projects': projects.map((p) => p.toJson()).toList(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    role: json['role'] ?? '',
   department: json['department'] ?? '',
    projects: (json['projects'] as List<dynamic>? ?? [])
        .map((p) => ProjectModel.fromJson(p))
        .toList(),
  );
}
