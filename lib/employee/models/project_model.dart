class ProjectModel {
  final String id;
  final String name;
  final String site;
  final String shift;
  final String clientName;
  final String clientContact;
  final String managerName;
  final String managerEmail;
  final String managerContact;
  final String description;
  final String techStack;
  final DateTime assignedDate;

  ProjectModel({
    required this.id,
    required this.name,
    required this.site,
    required this.shift,
    required this.clientName,
    required this.clientContact,
    required this.managerName,
    required this.managerEmail,
    required this.managerContact,
    required this.description,
    required this.techStack,
    required this.assignedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'site': site,
    'shift': shift,
    'clientName': clientName,
    'clientContact': clientContact,
    'managerName': managerName,
    'managerEmail': managerEmail,
    'managerContact': managerContact,
    'description': description,
    'techStack': techStack,
    'assignedDate': assignedDate.toIso8601String(),
  };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    site: json['site'] ?? '',
    shift: json['shift'] ?? '',
    clientName: json['clientName'] ?? '',
    clientContact: json['clientContact'] ?? '',
    managerName: json['managerName'] ?? '',
    managerEmail: json['managerEmail'] ?? '',
    managerContact: json['managerContact'] ?? '',
    description: json['description'] ?? '',
    techStack: json['techStack'] ?? '',
    assignedDate: DateTime.tryParse(json['assignedDate'] ?? '') ?? DateTime.now(),
  );
}
