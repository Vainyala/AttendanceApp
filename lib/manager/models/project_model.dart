class Project {
  final int? id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int teamSize;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.teamSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'team_size': teamSize,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      status: map['status'],
      teamSize: map['team_size'],
    );
  }
}
