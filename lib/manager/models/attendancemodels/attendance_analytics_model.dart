class AttendanceAnalytics {
  final String period;
  final Map<String, List<double>> graphData;
  final Map<String, Map<String, double>> individualData;
  final Map<String, dynamic> statistics;
  final List<String> labels;

  AttendanceAnalytics({
    required this.period,
    required this.graphData,
    required this.individualData,
    required this.statistics,
    required this.labels,
  });
}

class Insight {
  final String text;
  final String type;

  Insight({required this.text, required this.type});
}

class PerformanceMetric {
  final String title;
  final String value;
  final String subtitle;

  PerformanceMetric({
    required this.title,
    required this.value,
    required this.subtitle,
  });
}
