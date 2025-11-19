// models/projectmodels/project_analytics_model.dart
class ProjectAnalytics {
  final Map<String, List<double>> graphData;
  final List<String> labels;
  final int totalProjects;
  final int totalEmployees;
  final Map<String, double> statusDistribution;
  final Map<String, dynamic> additionalStats;

  ProjectAnalytics({
    required this.graphData,
    required this.labels,
    required this.totalProjects,
    required this.totalEmployees,
    required this.statusDistribution,
    this.additionalStats = const {},
  });

  factory ProjectAnalytics.empty() {
    return ProjectAnalytics(
      graphData: {'planning': [], 'active': [], 'completed': [], 'onHold': []},
      labels: [],
      totalProjects: 0,
      totalEmployees: 0,
      statusDistribution: {
        'planning': 0.0,
        'active': 0.0,
        'completed': 0.0,
        'onHold': 0.0,
      },
    );
  }

  factory ProjectAnalytics.fromJson(Map<String, dynamic> json) {
    return ProjectAnalytics(
      graphData: Map<String, List<double>>.from(json['graphData'] ?? {}),
      labels: List<String>.from(json['labels'] ?? []),
      totalProjects: json['totalProjects'] ?? 0,
      totalEmployees: json['totalEmployees'] ?? 0,
      statusDistribution: Map<String, double>.from(
        json['statusDistribution'] ?? {},
      ),
      additionalStats: Map<String, dynamic>.from(json['additionalStats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'graphData': graphData,
      'labels': labels,
      'totalProjects': totalProjects,
      'totalEmployees': totalEmployees,
      'statusDistribution': statusDistribution,
      'additionalStats': additionalStats,
    };
  }
}
