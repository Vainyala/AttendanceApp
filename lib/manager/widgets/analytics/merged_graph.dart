import 'package:AttendanceApp/manager/models/attendancemodels/attendance_analytics_model.dart';
import 'package:AttendanceApp/manager/widgets/analytics/download_excel_sheet_merge.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:AttendanceApp/manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

class MergedGraph extends StatefulWidget {
  final AttendanceAnalyticsViewModel viewModel;

  const MergedGraph({super.key, required this.viewModel});

  @override
  State<MergedGraph> createState() => _MergedGraphState();
}

class _MergedGraphState extends State<MergedGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _barAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _barAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(MergedGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.analytics != widget.viewModel.analytics ||
        oldWidget.viewModel.selectedPeriod != widget.viewModel.selectedPeriod) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = widget.viewModel.analytics;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (analytics == null) {
      return _buildLoadingState(isDark);
    }

    return _buildGraphCard(analytics, isDark);
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'INITIALIZING ANALYTICS...',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard(AttendanceAnalytics analytics, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(isDark),
              const SizedBox(height: 10),
              _buildGraphSection(analytics, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Network Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.viewModel.getGraphSubtitle(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            TeamAttendanceExcelDownloadButton(
              viewModel: widget.viewModel,
              onDownloadComplete: () {
                print('Download completed successfully!');
              },
              onDownloadError: () {
                print('Download failed!');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberCountBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blue.shade800, Colors.purple.shade800]
              : [Colors.blue.shade100, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Text(
        '${widget.viewModel.teamMembers.length} NODES',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : Colors.grey.shade800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildGraphSection(AttendanceAnalytics analytics, bool isDark) {
    return SizedBox(height: 280, child: _buildFLChartGraph(analytics, isDark));
  }

  Widget _buildFLChartGraph(AttendanceAnalytics analytics, bool isDark) {
    final graphData = analytics.graphData;
    final labels = analytics.labels;

    if (labels.isEmpty) {
      return Center(
        child: Text(
          'NO DATA AVAILABLE',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxGraphValue(graphData),
            minY: 0,
            groupsSpace: _calculateGroupSpace(labels.length),
            barTouchData: BarTouchData(enabled: false),
            titlesData: _buildTitlesData(labels, isDark),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _getGridInterval(graphData),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            barGroups: _buildBarGroups(graphData, labels),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    Map<String, List<double>> graphData,
    List<String> labels,
  ) {
    return labels.asMap().entries.map((entry) {
      final index = entry.key;
      final present =
          (graphData['present']?[index] ?? 0.0) * _barAnimation.value;
      final late = (graphData['late']?[index] ?? 0.0) * _barAnimation.value;
      final absent = (graphData['absent']?[index] ?? 0.0) * _barAnimation.value;

      return BarChartGroupData(
        x: index,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            toY: present,
            color: Colors.green.shade400,
            width: _calculateBarWidth(labels.length),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: _glowAnimation.value > 0.5
                ? LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade400.withOpacity(0.7),
                    ],
                  )
                : null,
          ),
          BarChartRodData(
            toY: present + late,
            fromY: present,
            color: Colors.orange.shade400,
            width: _calculateBarWidth(labels.length),
            gradient: _glowAnimation.value > 0.5
                ? LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade400.withOpacity(0.7),
                    ],
                  )
                : null,
          ),
          BarChartRodData(
            toY: present + late + absent,
            fromY: present + late,
            color: Colors.red.shade400,
            width: _calculateBarWidth(labels.length),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            gradient: _glowAnimation.value > 0.5
                ? LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade400.withOpacity(0.7),
                    ],
                  )
                : null,
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData _buildTitlesData(List<String> labels, bool isDark) {
    return FlTitlesData(
      show: true,
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: _getLeftInterval(),
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < labels.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildLegendSection(AttendanceAnalytics analytics, bool isDark) {
    final percentages = _calculatePercentages(analytics);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 12,
        children: [
          _buildLegendItem(
            'Present',
            Colors.green.shade400,
            percentages['present'] ?? 0,
            isDark,
          ),
          _buildLegendItem(
            'Late',
            Colors.orange.shade400,
            percentages['late'] ?? 0,
            isDark,
          ),
          _buildLegendItem(
            'Absent',
            Colors.red.shade400,
            percentages['absent'] ?? 0,
            isDark,
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculatePercentages(AttendanceAnalytics analytics) {
    final graphData = analytics.graphData;
    final totalTeamMembers = widget.viewModel.teamMembers.length;

    if (totalTeamMembers == 0) return {'present': 0, 'late': 0, 'absent': 0};

    double totalPresent = 0;
    double totalLate = 0;
    double totalAbsent = 0;
    int dataPoints = 0;

    for (final values in graphData['present'] ?? []) {
      totalPresent += values;
      dataPoints++;
    }
    for (final values in graphData['late'] ?? []) {
      totalLate += values;
    }
    for (final values in graphData['absent'] ?? []) {
      totalAbsent += values;
    }

    if (dataPoints == 0) return {'present': 0, 'late': 0, 'absent': 0};

    return {
      'present': ((totalPresent / dataPoints) / totalTeamMembers * 100),
      'late': ((totalLate / dataPoints) / totalTeamMembers * 100),
      'absent': ((totalAbsent / dataPoints) / totalTeamMembers * 100),
    };
  }

  Widget _buildLegendItem(
    String text,
    Color color,
    double percentage,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.grey.shade800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxGraphValue(Map<String, List<double>> graphData) {
    double maxValue = 0.0;
    for (final values in graphData.values) {
      for (final value in values) {
        if (value > maxValue) maxValue = value;
      }
    }

    final teamSize = widget.viewModel.teamMembers.length;
    if (maxValue == 0) return teamSize.toDouble();

    final roundedMax = (maxValue / teamSize).ceil() * teamSize;
    return roundedMax.toDouble();
  }

  double _getGridInterval(Map<String, List<double>> graphData) {
    final maxValue = _getMaxGraphValue(graphData);
    final teamSize = widget.viewModel.teamMembers.length;

    if (teamSize <= 5) return 1;
    if (teamSize <= 10) return 2;
    return (maxValue / 4).roundToDouble();
  }

  double _getLeftInterval() {
    final teamSize = widget.viewModel.teamMembers.length;
    if (teamSize <= 5) return 1;
    if (teamSize <= 10) return 2;
    return (teamSize / 4).roundToDouble();
  }

  double _calculateGroupSpace(int labelCount) {
    if (labelCount <= 6) return 12;
    if (labelCount <= 12) return 8;
    return 4;
  }

  double _calculateBarWidth(int labelCount) {
    if (labelCount <= 6) return 16;
    if (labelCount <= 12) return 12;
    return 8;
  }
}

// import 'package:AttendanceApp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:AttendanceApp/widgets/analytics/download_excel_sheet_merge.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class MergedGraph extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const MergedGraph({super.key, required this.viewModel});

//   @override
//   State<MergedGraph> createState() => _MergedGraphState();
// }

// class _MergedGraphState extends State<MergedGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;
//   late Animation<double> _glowAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void didUpdateWidget(MergedGraph oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.viewModel.analytics != widget.viewModel.analytics ||
//         oldWidget.viewModel.selectedPeriod != widget.viewModel.selectedPeriod) {
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       height: 380,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.cyan, strokeWidth: 3),
//             SizedBox(height: 16),
//             Text(
//               'INITIALIZING ANALYTICS...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 1.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphCard(AttendanceAnalytics analytics) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.black26,
//         // gradient: LinearGradient(
//         //   begin: Alignment.topLeft,
//         //   end: Alignment.bottomRight,
//         //   colors: [
//         //     Colors.white.withOpacity(0.15),
//         //     Colors.white.withOpacity(0.05),
//         //   ],
//         // ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeaderSection(),
//               const SizedBox(height: 10),
//               _buildGraphSection(analytics),
//               // const SizedBox(height: 20),
//               // _buildLegendSection(analytics),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Text(
//                   //   'ATTENDANCE MATRIX',
//                   //   style: TextStyle(
//                   //     fontSize: 14,
//                   //     fontWeight: FontWeight.w800,
//                   //     color: Colors.white.withOpacity(0.9),
//                   //     letterSpacing: 1.2,
//                   //   ),
//                   // ),
//                   // const SizedBox(height: 4),
//                   Text(
//                     '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Network Data',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.viewModel.getGraphSubtitle(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // _buildMemberCountBadge(),

//             // Download Button Add Here
//             TeamAttendanceExcelDownloadButton(
//               viewModel: widget.viewModel,
//               onDownloadComplete: () {
//                 print('Download completed successfully!');
//               },
//               onDownloadError: () {
//                 print('Download failed!');
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMemberCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.cyan.shade400.withOpacity(0.3),
//             Colors.blue.shade400.withOpacity(0.2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//       ),
//       child: Text(
//         '${widget.viewModel.teamMembers.length} NODES',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w800,
//           color: Colors.white,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalytics analytics) {
//     return SizedBox(height: 280, child: _buildFLChartGraph(analytics));
//   }

//   Widget _buildFLChartGraph(AttendanceAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     if (labels.isEmpty) {
//       return Center(
//         child: Text(
//           'NO DATA AVAILABLE',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.7),
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.8,
//           ),
//         ),
//       );
//     }

//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: _getMaxGraphValue(graphData),
//             minY: 0,
//             groupsSpace: _calculateGroupSpace(labels.length),
//             barTouchData: BarTouchData(
//               enabled: false, // Tooltip disabled
//             ),
//             titlesData: _buildTitlesData(labels),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: _getGridInterval(graphData),
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: Colors.white.withOpacity(0.1),
//                   strokeWidth: 1,
//                   dashArray: [4, 4],
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             barGroups: _buildBarGroups(graphData, labels),
//           ),
//         );
//       },
//     );
//   }

//   List<BarChartGroupData> _buildBarGroups(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return labels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final present =
//           (graphData['present']?[index] ?? 0.0) * _barAnimation.value;
//       final late = (graphData['late']?[index] ?? 0.0) * _barAnimation.value;
//       final absent = (graphData['absent']?[index] ?? 0.0) * _barAnimation.value;

//       return BarChartGroupData(
//         x: index,
//         groupVertically: true,
//         barRods: [
//           BarChartRodData(
//             toY: present,
//             color: Colors.cyan.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//             gradient: _glowAnimation.value > 0.5
//                 ? LinearGradient(
//                     colors: [
//                       Colors.cyan.shade400,
//                       Colors.cyan.shade400.withOpacity(0.7),
//                     ],
//                   )
//                 : null,
//           ),
//           BarChartRodData(
//             toY: present + late,
//             fromY: present,
//             color: Colors.orange.shade400,
//             width: _calculateBarWidth(labels.length),
//             gradient: _glowAnimation.value > 0.5
//                 ? LinearGradient(
//                     colors: [
//                       Colors.orange.shade400,
//                       Colors.orange.shade400.withOpacity(0.7),
//                     ],
//                   )
//                 : null,
//           ),
//           BarChartRodData(
//             toY: present + late + absent,
//             fromY: present + late,
//             color: Colors.red.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(6),
//               bottomRight: Radius.circular(6),
//             ),
//             gradient: _glowAnimation.value > 0.5
//                 ? LinearGradient(
//                     colors: [
//                       Colors.red.shade400,
//                       Colors.red.shade400.withOpacity(0.7),
//                     ],
//                   )
//                 : null,
//           ),
//         ],
//       );
//     }).toList();
//   }

//   FlTitlesData _buildTitlesData(List<String> labels) {
//     return FlTitlesData(
//       show: true,
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 40,
//           interval: _getLeftInterval(),
//           getTitlesWidget: (value, meta) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Text(
//                 value.toInt().toString(),
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 32,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendSection(AttendanceAnalytics analytics) {
//     final percentages = _calculatePercentages(analytics);

//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 20,
//         runSpacing: 12,
//         children: [
//           _buildLegendItem(
//             'Present',
//             Colors.cyan.shade400,
//             percentages['present'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Late',
//             Colors.orange.shade400,
//             percentages['late'] ?? 0,
//           ),
//           _buildLegendItem(
//             'Absent',
//             Colors.red.shade400,
//             percentages['absent'] ?? 0,
//           ),
//         ],
//       ),
//     );
//   }

//   Map<String, double> _calculatePercentages(AttendanceAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final totalTeamMembers = widget.viewModel.teamMembers.length;

//     if (totalTeamMembers == 0) return {'present': 0, 'late': 0, 'absent': 0};

//     double totalPresent = 0;
//     double totalLate = 0;
//     double totalAbsent = 0;
//     int dataPoints = 0;

//     // Calculate averages across all data points
//     for (final values in graphData['present'] ?? []) {
//       totalPresent += values;
//       dataPoints++;
//     }
//     for (final values in graphData['late'] ?? []) {
//       totalLate += values;
//     }
//     for (final values in graphData['absent'] ?? []) {
//       totalAbsent += values;
//     }

//     if (dataPoints == 0) return {'present': 0, 'late': 0, 'absent': 0};

//     return {
//       'present': ((totalPresent / dataPoints) / totalTeamMembers * 100),
//       'late': ((totalLate / dataPoints) / totalTeamMembers * 100),
//       'absent': ((totalAbsent / dataPoints) / totalTeamMembers * 100),
//     };
//   }

//   Widget _buildLegendItem(String text, Color color, double percentage) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(3),
//                   boxShadow: [
//                     BoxShadow(
//                       color: color.withOpacity(0.6),
//                       blurRadius: 6,
//                       spreadRadius: 1,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${percentage.toStringAsFixed(1)}%',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }

//     final teamSize = widget.viewModel.teamMembers.length;
//     if (maxValue == 0) return teamSize.toDouble();

//     final roundedMax = (maxValue / teamSize).ceil() * teamSize;
//     return roundedMax.toDouble();
//   }

//   double _getGridInterval(Map<String, List<double>> graphData) {
//     final maxValue = _getMaxGraphValue(graphData);
//     final teamSize = widget.viewModel.teamMembers.length;

//     if (teamSize <= 5) return 1;
//     if (teamSize <= 10) return 2;
//     return (maxValue / 4).roundToDouble();
//   }

//   double _getLeftInterval() {
//     final teamSize = widget.viewModel.teamMembers.length;
//     if (teamSize <= 5) return 1;
//     if (teamSize <= 10) return 2;
//     return (teamSize / 4).roundToDouble();
//   }

//   double _calculateGroupSpace(int labelCount) {
//     if (labelCount <= 6) return 12;
//     if (labelCount <= 12) return 8;
//     return 4;
//   }

//   double _calculateBarWidth(int labelCount) {
//     if (labelCount <= 6) return 16;
//     if (labelCount <= 12) return 12;
//     return 8;
//   }
// }

// import 'package:AttendanceApp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:AttendanceApp/widgets/analytics/download_excel_sheet_merge.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class MergedGraph extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const MergedGraph({super.key, required this.viewModel});

//   @override
//   State<MergedGraph> createState() => _MergedGraphState();
// }

// class _MergedGraphState extends State<MergedGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;
//   late Animation<double> _glowAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void didUpdateWidget(MergedGraph oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.viewModel.analytics != widget.viewModel.analytics ||
//         oldWidget.viewModel.selectedPeriod != widget.viewModel.selectedPeriod) {
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       height: 380,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.cyan, strokeWidth: 3),
//             SizedBox(height: 16),
//             Text(
//               'INITIALIZING ANALYTICS...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 1.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphCard(AttendanceAnalytics analytics) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.black26,
//         // gradient: LinearGradient(
//         //   begin: Alignment.topLeft,
//         //   end: Alignment.bottomRight,
//         //   colors: [
//         //     Colors.white.withOpacity(0.15),
//         //     Colors.white.withOpacity(0.05),
//         //   ],
//         // ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeaderSection(),
//               const SizedBox(height: 10),
//               _buildGraphSection(analytics),
//               // const SizedBox(height: 20),
//               // _buildLegendSection(analytics),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Text(
//                   //   'ATTENDANCE MATRIX',
//                   //   style: TextStyle(
//                   //     fontSize: 14,
//                   //     fontWeight: FontWeight.w800,
//                   //     color: Colors.white.withOpacity(0.9),
//                   //     letterSpacing: 1.2,
//                   //   ),
//                   // ),
//                   // const SizedBox(height: 4),
//                   Text(
//                     '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Network Data',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.viewModel.getGraphSubtitle(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // _buildMemberCountBadge(),

//             // Download Button Add Here
//             TeamAttendanceExcelDownloadButton(
//               viewModel: widget.viewModel,
//               onDownloadComplete: () {
//                 print('Download completed successfully!');
//               },
//               onDownloadError: () {
//                 print('Download failed!');
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMemberCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.cyan.shade400.withOpacity(0.3),
//             Colors.blue.shade400.withOpacity(0.2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//       ),
//       child: Text(
//         '${widget.viewModel.teamMembers.length} NODES',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w800,
//           color: Colors.white,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalytics analytics) {
//     return SizedBox(height: 280, child: _buildFLChartGraph(analytics));
//   }

//   Widget _buildFLChartGraph(AttendanceAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     if (labels.isEmpty) {
//       return Center(
//         child: Text(
//           'NO DATA AVAILABLE',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.7),
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.8,
//           ),
//         ),
//       );
//     }

//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: _getMaxGraphValue(graphData),
//             minY: 0,
//             groupsSpace: _calculateGroupSpace(labels.length),
//             barTouchData: BarTouchData(
//               enabled: false, // Tooltip disabled
//             ),
//             titlesData: _buildTitlesData(labels),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: _getGridInterval(graphData),
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: Colors.white.withOpacity(0.1),
//                   strokeWidth: 1,
//                   dashArray: [4, 4],
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             barGroups: _buildBarGroups(graphData, labels),
//           ),
//         );
//       },
//     );
//   }

//   List<BarChartGroupData> _buildBarGroups(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return labels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final present =
//           (graphData['present']?[index] ?? 0.0) * _barAnimation.value;
//       final late = (graphData['late']?[index] ?? 0.0) * _barAnimation.value;
//       final absent = (graphData['absent']?[index] ?? 0.0) * _barAnimation.value;

//       return BarChartGroupData(
//         x: index,
//         groupVertically: true,
//         barRods: [
//           BarChartRodData(
//             toY: present,
//             color: Colors.cyan.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//             gradient: _glowAnimation.value > 0.5
//                 ? LinearGradient(
//                     colors: [
//                       Colors.cyan.shade400,
//                       Colors.cyan.shade400.withOpacity(0.7),
//                     ],
//                   )
//                 : null,
//           ),
//           BarChartRodData(
//             toY: present + late,
//             fromY: present,
//             color: Colors.orange.shade400,
//             width: _calculateBarWidth(labels.length),
//             gradient: _glowAnimation.value > 0.5
//                 ? LinearGradient(
//                     colors: [
//                       Colors.orange.shade400,
//                       Colors.orange.shade400.withOpacity(0.7),
//                     ],
//                   )
//                 : null,
//           ),
//           BarChartRodData(
//             toY: present + late + absent,
//             fromY: present + late,
//             color: Colors.red.shade400,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(6),
//               bottomRight: Radius.circular(6),
//             ),
//             gradient: _glowAnimation.value > 0.5
//                 ? LinearGradient(
//                     colors: [
//                       Colors.red.shade400,
//                       Colors.red.shade400.withOpacity(0.7),
//                     ],
//                   )
//                 : null,
//           ),
//         ],
//       );
//     }).toList();
//   }

//   FlTitlesData _buildTitlesData(List<String> labels) {
//     return FlTitlesData(
//       show: true,
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 40,
//           interval: _getLeftInterval(),
//           getTitlesWidget: (value, meta) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Text(
//                 value.toInt().toString(),
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 32,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendSection(AttendanceAnalytics analytics) {
//     final percentages = _calculatePercentages(analytics);

//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 20,
//         runSpacing: 12,
//         children: [
//           _buildLegendItem(
//             'Present',
//             Colors.cyan.shade400,
//             percentages[''] ?? 0,
//           ),
//           _buildLegendItem(
//             'Leave',
//             Colors.orange.shade400,
//             percentages[''] ?? 0,
//           ),
//           _buildLegendItem('Absent', Colors.red.shade400, percentages[''] ?? 0),
//         ],
//       ),
//     );
//   }

//   Map<String, double> _calculatePercentages(AttendanceAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final totalTeamMembers = widget.viewModel.teamMembers.length;

//     if (totalTeamMembers == 0) return {'present': 0, 'late': 0, 'absent': 0};

//     double totalPresent = 0;
//     double totalLate = 0;
//     double totalAbsent = 0;
//     int dataPoints = 0;

//     // Calculate averages across all data points
//     for (final values in graphData['present'] ?? []) {
//       totalPresent += values;
//       dataPoints++;
//     }
//     for (final values in graphData['late'] ?? []) {
//       totalLate += values;
//     }
//     for (final values in graphData['absent'] ?? []) {
//       totalAbsent += values;
//     }

//     if (dataPoints == 0) return {'present': 0, 'late': 0, 'absent': 0};

//     return {
//       'present': ((totalPresent / dataPoints) / totalTeamMembers * 100),
//       'late': ((totalLate / dataPoints) / totalTeamMembers * 100),
//       'absent': ((totalAbsent / dataPoints) / totalTeamMembers * 100),
//     };
//   }

//   Widget _buildLegendItem(String text, Color color, double percentage) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(3),
//                   boxShadow: [
//                     BoxShadow(
//                       color: color.withOpacity(0.6),
//                       blurRadius: 6,
//                       spreadRadius: 1,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${percentage.toStringAsFixed(1)}%',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }

//     final teamSize = widget.viewModel.teamMembers.length;
//     if (maxValue == 0) return teamSize.toDouble();

//     final roundedMax = (maxValue / teamSize).ceil() * teamSize;
//     return roundedMax.toDouble();
//   }

//   double _getGridInterval(Map<String, List<double>> graphData) {
//     final maxValue = _getMaxGraphValue(graphData);
//     final teamSize = widget.viewModel.teamMembers.length;

//     if (teamSize <= 5) return 1;
//     if (teamSize <= 10) return 2;
//     return (maxValue / 4).roundToDouble();
//   }

//   double _getLeftInterval() {
//     final teamSize = widget.viewModel.teamMembers.length;
//     if (teamSize <= 5) return 1;
//     if (teamSize <= 10) return 2;
//     return (teamSize / 4).roundToDouble();
//   }

//   double _calculateGroupSpace(int labelCount) {
//     if (labelCount <= 6) return 12;
//     if (labelCount <= 12) return 8;
//     return 4;
//   }

//   double _calculateBarWidth(int labelCount) {
//     if (labelCount <= 6) return 16;
//     if (labelCount <= 12) return 12;
//     return 8;
//   }
// }

// import 'package:AttendanceApp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class MergedGraph extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const MergedGraph({super.key, required this.viewModel});

//   @override
//   State<MergedGraph> createState() => _MergedGraphState();
// }

// class _MergedGraphState extends State<MergedGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _animationController.forward();
//   }

//   @override
//   void didUpdateWidget(MergedGraph oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Restart animation when data changes
//     if (oldWidget.viewModel.analytics != widget.viewModel.analytics ||
//         oldWidget.viewModel.selectedPeriod != widget.viewModel.selectedPeriod) {
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         height: 320,
//         padding: const EdgeInsets.all(16),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Loading attendance data...'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphCard(AttendanceAnalytics analytics) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeaderSection(),
//             const SizedBox(height: 20),
//             _buildGraphSection(analytics),
//             const SizedBox(height: 20),
//             _buildLegendSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Attendance',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.viewModel.getGraphSubtitle(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildMemberCountBadge(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMemberCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//       ),
//       child: Text(
//         '${widget.viewModel.teamMembers.length} Members',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: AppColors.primary,
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalytics analytics) {
//     return SizedBox(height: 280, child: _buildFLChartGraph(analytics));
//   }

//   Widget _buildFLChartGraph(AttendanceAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     if (labels.isEmpty) {
//       return const Center(
//         child: Text(
//           'No data available for selected period',
//           style: TextStyle(color: AppColors.textSecondary),
//         ),
//       );
//     }

//     return AnimatedBuilder(
//       animation: _barAnimation,
//       builder: (context, child) {
//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: _getMaxGraphValue(graphData),
//             minY: 0,
//             groupsSpace: _calculateGroupSpace(labels.length),
//             barTouchData: BarTouchData(
//               enabled: true,
//               touchTooltipData: BarTouchTooltipData(
//                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                   final status = ['Present', 'Late', 'Absent'][rodIndex];
//                   final value =
//                       rod.toY -
//                       (rodIndex > 0
//                           ? _getPreviousRodValue(group, rodIndex)
//                           : 0);

//                   // Return null to use default tooltip styling
//                   // or create a custom tooltip item
//                   return BarTooltipItem(
//                     '$status\n${value.toInt()}',
//                     TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             titlesData: _buildTitlesData(labels),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: _getGridInterval(graphData),
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: AppColors.grey300.withOpacity(0.3),
//                   strokeWidth: 1,
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(
//                 color: AppColors.grey300.withOpacity(0.5),
//                 width: 1,
//               ),
//             ),
//             barGroups: _buildBarGroups(graphData, labels),
//           ),
//         );
//       },
//     );
//   }

//   double _getPreviousRodValue(BarChartGroupData group, int currentRodIndex) {
//     double previousValue = 0;
//     for (int i = 0; i < currentRodIndex; i++) {
//       previousValue += group.barRods[i].toY;
//     }
//     return previousValue;
//   }

//   List<BarChartGroupData> _buildBarGroups(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return labels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final present =
//           (graphData['present']?[index] ?? 0.0) * _barAnimation.value;
//       final late = (graphData['late']?[index] ?? 0.0) * _barAnimation.value;
//       final absent = (graphData['absent']?[index] ?? 0.0) * _barAnimation.value;

//       return BarChartGroupData(
//         x: index,
//         groupVertically: true,
//         barRods: [
//           BarChartRodData(
//             toY: present,
//             color: AppColors.success,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(4),
//               topRight: Radius.circular(4),
//             ),
//           ),
//           BarChartRodData(
//             toY: present + late,
//             fromY: present,
//             color: AppColors.warning,
//             width: _calculateBarWidth(labels.length),
//           ),
//           BarChartRodData(
//             toY: present + late + absent,
//             fromY: present + late,
//             color: AppColors.error,
//             width: _calculateBarWidth(labels.length),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(4),
//               bottomRight: Radius.circular(4),
//             ),
//           ),
//         ],
//         showingTooltipIndicators: [0, 1, 2],
//       );
//     }).toList();
//   }

//   FlTitlesData _buildTitlesData(List<String> labels) {
//     return FlTitlesData(
//       show: true,
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 40,
//           interval: _getLeftInterval(),
//           getTitlesWidget: (value, meta) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Text(
//                 value.toInt().toString(),
//                 style: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 32,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendSection() {
//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 20,
//         runSpacing: 8,
//         children: [
//           _buildLegendItem('Present', AppColors.success),
//           _buildLegendItem('Late', AppColors.warning),
//           _buildLegendItem('Absent', AppColors.error),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegendItem(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }

//     final teamSize = widget.viewModel.teamMembers.length;
//     if (maxValue == 0) return teamSize.toDouble();

//     // Round up to next multiple of team size for better grid
//     final roundedMax = (maxValue / teamSize).ceil() * teamSize;
//     return roundedMax.toDouble();
//   }

//   double _getGridInterval(Map<String, List<double>> graphData) {
//     final maxValue = _getMaxGraphValue(graphData);
//     final teamSize = widget.viewModel.teamMembers.length;

//     if (teamSize <= 5) return 1;
//     if (teamSize <= 10) return 2;
//     return (maxValue / 4).roundToDouble();
//   }

//   double _getLeftInterval() {
//     final teamSize = widget.viewModel.teamMembers.length;
//     if (teamSize <= 5) return 1;
//     if (teamSize <= 10) return 2;
//     return (teamSize / 4).roundToDouble();
//   }

//   double _calculateGroupSpace(int labelCount) {
//     // Adjust spacing based on number of bars for better visibility
//     if (labelCount <= 6) return 12;
//     if (labelCount <= 12) return 8;
//     return 4;
//   }

//   double _calculateBarWidth(int labelCount) {
//     // Adjust bar width based on number of bars
//     if (labelCount <= 6) return 16;
//     if (labelCount <= 12) return 12;
//     return 8;
//   }
// }

// import 'package:AttendanceApp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class MergedGraph extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const MergedGraph({super.key, required this.viewModel});

//   @override
//   State<MergedGraph> createState() => _MergedGraphState();
// }

// class _MergedGraphState extends State<MergedGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _animationController.forward();
//   }

//   @override
//   void didUpdateWidget(MergedGraph oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.viewModel.analytics != widget.viewModel.analytics) {
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         height: 320,
//         padding: const EdgeInsets.all(16),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Loading attendance data...'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphCard(AttendanceAnalytics analytics) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeaderSection(),
//             const SizedBox(height: 20),
//             _buildGraphSection(analytics),
//             const SizedBox(height: 20),
//             _buildLegendSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Attendance Overview',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             _buildMemberCountBadge(),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           widget.viewModel.getGraphSubtitle(),
//           style: TextStyle(
//             fontSize: 14,
//             color: AppColors.textSecondary,
//             height: 1.4,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMemberCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//       ),
//       child: Text(
//         '${widget.viewModel.teamMembers.length} Members',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: AppColors.primary,
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalytics analytics) {
//     return SizedBox(height: 280, child: _buildFLChartGraph(analytics));
//   }

//   Widget _buildFLChartGraph(AttendanceAnalytics analytics) {
//     final graphData = analytics.graphData;
//     final labels = analytics.labels;

//     if (labels.isEmpty) {
//       return const Center(
//         child: Text(
//           'No data available for selected period',
//           style: TextStyle(color: AppColors.textSecondary),
//         ),
//       );
//     }

//     return AnimatedBuilder(
//       animation: _barAnimation,
//       builder: (context, child) {
//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: _getMaxGraphValue(graphData),
//             minY: 0,
//             groupsSpace: 12,
//             barTouchData: BarTouchData(
//               enabled: true,
//               touchTooltipData: BarTouchTooltipData(
//                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                   return null;

//                   //final status = ['Present', 'Late', 'Absent'][rodIndex];
//                   // final value =
//                   //     rod.toY -
//                   //     (rodIndex > 0
//                   //         ? _getPreviousRodValue(group, rodIndex)
//                   //         : 0);
//                   // return BarTooltipItem(
//                   //'$status: ${value.toInt()}\n',
//                   //   const TextStyle(
//                   //     color: Colors.white,
//                   //     fontWeight: FontWeight.w600,
//                   //   ),
//                   // );
//                 },
//               ),
//             ),
//             titlesData: _buildTitlesData(labels),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: _getGridInterval(graphData),
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: AppColors.grey300.withOpacity(0.3),
//                   strokeWidth: 1,
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(
//                 color: AppColors.grey300.withOpacity(0.5),
//                 width: 1,
//               ),
//             ),
//             barGroups: _buildBarGroups(graphData, labels),
//           ),
//         );
//       },
//     );
//   }

//   double _getPreviousRodValue(BarChartGroupData group, int currentRodIndex) {
//     double previousValue = 0;
//     for (int i = 0; i < currentRodIndex; i++) {
//       previousValue += group.barRods[i].toY;
//     }
//     return previousValue;
//   }

//   List<BarChartGroupData> _buildBarGroups(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//   ) {
//     return labels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final present =
//           (graphData['present']?[index] ?? 0.0) * _barAnimation.value;
//       final late = (graphData['late']?[index] ?? 0.0) * _barAnimation.value;
//       final absent = (graphData['absent']?[index] ?? 0.0) * _barAnimation.value;

//       return BarChartGroupData(
//         x: index,
//         groupVertically: true,
//         barRods: [
//           BarChartRodData(
//             toY: present,
//             color: AppColors.success,
//             width: 16,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(4),
//               topRight: Radius.circular(4),
//             ),
//           ),
//           BarChartRodData(
//             toY: present + late,
//             fromY: present,
//             color: AppColors.warning,
//             width: 16,
//           ),
//           BarChartRodData(
//             toY: present + late + absent,
//             fromY: present + late,
//             color: AppColors.error,
//             width: 16,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(4),
//               bottomRight: Radius.circular(4),
//             ),
//           ),
//         ],
//         showingTooltipIndicators: [0, 1, 2],
//       );
//     }).toList();
//   }

//   FlTitlesData _buildTitlesData(List<String> labels) {
//     return FlTitlesData(
//       show: true,
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 40,
//           interval: _getLeftInterval(),
//           getTitlesWidget: (value, meta) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Text(
//                 value.toInt().toString(),
//                 style: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendSection() {
//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 20,
//         runSpacing: 8,
//         children: [
//           _buildLegendItem('Present', AppColors.success),
//           _buildLegendItem('Late', AppColors.warning),
//           _buildLegendItem('Absent', AppColors.error),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegendItem(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }
//     // Round up to nearest multiple of team size for better grid
//     final teamSize = widget.viewModel.teamMembers.length;
//     if (maxValue == 0) return teamSize.toDouble();

//     final roundedMax = (maxValue / teamSize).ceil() * teamSize;
//     return roundedMax.toDouble();
//   }

//   double _getGridInterval(Map<String, List<double>> graphData) {
//     final maxValue = _getMaxGraphValue(graphData);
//     if (maxValue <= 5) return 1;
//     if (maxValue <= 10) return 2;
//     if (maxValue <= 20) return 5;
//     return (maxValue / 5).roundToDouble();
//   }

//   double _getLeftInterval() {
//     final teamSize = widget.viewModel.teamMembers.length;
//     if (teamSize <= 5) return 1;
//     if (teamSize <= 10) return 2;
//     return (teamSize / 5).roundToDouble();
//   }
// }
// import 'package:AttendanceApp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:flutter/material.dart';
// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';

// class MergedGraph extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const MergedGraph({super.key, required this.viewModel});

//   @override
//   State<MergedGraph> createState() => _MergedGraphState();
// }

// class _MergedGraphState extends State<MergedGraph>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _barAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _barAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analytics = widget.viewModel.analytics;

//     if (analytics == null) {
//       return _buildLoadingState();
//     }

//     return _buildGraphCard(analytics);
//   }

//   Widget _buildLoadingState() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         height: 300,
//         padding: const EdgeInsets.all(16),
//         child: const Center(child: CircularProgressIndicator()),
//       ),
//     );
//   }

//   Widget _buildGraphCard(AttendanceAnalytics analytics) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeaderSection(),
//             const SizedBox(height: 16),
//             _buildGraphSection(analytics),
//             const SizedBox(height: 20),
//             _buildLegendSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 '${widget.viewModel.getPeriodDisplayName(widget.viewModel.selectedPeriod)} Overview',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             _buildMemberCountBadge(),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           widget.viewModel.getGraphSubtitle(),
//           style: TextStyle(
//             fontSize: 14,
//             color: AppColors.textSecondary,
//             height: 1.4,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMemberCountBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//       ),
//       child: Text(
//         '${widget.viewModel.teamMembers.length} Members',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: AppColors.primary,
//         ),
//       ),
//     );
//   }

//   Widget _buildGraphSection(AttendanceAnalytics analytics) {
//     return SizedBox(
//       height: 240,
//       child: _buildResponsiveGraph(analytics.graphData),
//     );
//   }

//   Widget _buildResponsiveGraph(Map<String, List<double>> graphData) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final labels = _getGraphLabels();
//         final barWidth = _calculateBarWidth(
//           constraints.maxWidth,
//           labels.length,
//         );
//         final spacing = _calculateSpacing(
//           constraints.maxWidth,
//           labels.length,
//           barWidth,
//         );

//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           child: Container(
//             constraints: BoxConstraints(minWidth: constraints.maxWidth),
//             child: Stack(
//               children: [
//                 _buildGridLines(),
//                 _buildBars(graphData, labels, barWidth, spacing),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGridLines() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: List.generate(4, (index) => _buildGridLine()),
//     );
//   }

//   Widget _buildGridLine() {
//     return Container(height: 1, color: AppColors.grey300.withOpacity(0.3));
//   }

//   Widget _buildBars(
//     Map<String, List<double>> graphData,
//     List<String> labels,
//     double barWidth,
//     double spacing,
//   ) {
//     return AnimatedBuilder(
//       animation: _barAnimation,
//       builder: (context, child) {
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: labels.asMap().entries.map((entry) {
//             final index = entry.key;
//             return _buildBarColumn(
//               graphData,
//               index,
//               entry.value,
//               barWidth,
//               spacing,
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildBarColumn(
//     Map<String, List<double>> graphData,
//     int index,
//     String label,
//     double barWidth,
//     double spacing,
//   ) {
//     final presentData = graphData['present']?[index] ?? 0.0;
//     final lateData = graphData['late']?[index] ?? 0.0;
//     final absentData = graphData['absent']?[index] ?? 0.0;

//     final totalValue = presentData + lateData + absentData;
//     final maxValue = _getMaxGraphValue(graphData);
//     final scaleFactor = maxValue > 0 ? 160.0 / maxValue : 0.0;
//     final animationValue = _barAnimation.value;

//     return Container(
//       width: barWidth,
//       margin: EdgeInsets.symmetric(horizontal: spacing / 2),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           _buildValueLabel(totalValue),
//           const SizedBox(height: 6),
//           _buildStackedBar(
//             presentData,
//             lateData,
//             absentData,
//             scaleFactor,
//             animationValue,
//           ),
//           const SizedBox(height: 12),
//           _buildTimeLabel(label),
//         ],
//       ),
//     );
//   }

//   Widget _buildValueLabel(double value) {
//     return Text(
//       value.toInt().toString(),
//       style: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w700,
//         color: AppColors.textPrimary,
//       ),
//     );
//   }

//   Widget _buildStackedBar(
//     double presentData,
//     double lateData,
//     double absentData,
//     double scaleFactor,
//     double animationValue,
//   ) {
//     final presentHeight = presentData * scaleFactor * animationValue;
//     final lateHeight = lateData * scaleFactor * animationValue;
//     final absentHeight = absentData * scaleFactor * animationValue;

//     return SizedBox(
//       width: double.infinity,
//       height: presentHeight + lateHeight + absentHeight,
//       child: Stack(
//         children: [
//           _buildBarSegment(absentHeight, AppColors.error, true, false),
//           Positioned(
//             bottom: absentHeight,
//             child: _buildBarSegment(
//               lateHeight,
//               AppColors.warning,
//               false,
//               false,
//             ),
//           ),
//           Positioned(
//             bottom: absentHeight + lateHeight,
//             child: _buildBarSegment(
//               presentHeight,
//               AppColors.success,
//               false,
//               true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBarSegment(
//     double height,
//     Color color,
//     bool isTopRounded,
//     bool isBottomRounded,
//   ) {
//     return Container(
//       width: double.infinity,
//       height: height,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.vertical(
//           top: isTopRounded ? const Radius.circular(4) : Radius.zero,
//           bottom: isBottomRounded ? const Radius.circular(4) : Radius.zero,
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeLabel(String label) {
//     return SizedBox(
//       height: 32,
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w500,
//           color: AppColors.textSecondary,
//         ),
//         textAlign: TextAlign.center,
//         maxLines: 2,
//       ),
//     );
//   }

//   Widget _buildLegendSection() {
//     return Center(
//       child: Wrap(
//         alignment: WrapAlignment.center,
//         spacing: 20,
//         runSpacing: 8,
//         children: [
//           _buildLegendItem('Present', AppColors.success),
//           _buildLegendItem('Late', AppColors.warning),
//           _buildLegendItem('Absent', AppColors.error),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegendItem(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Utility methods
//   double _calculateBarWidth(double availableWidth, int itemCount) {
//     if (itemCount <= 6) return 36.0;
//     if (itemCount <= 12) return 28.0;
//     return 22.0;
//   }

//   double _calculateSpacing(
//     double availableWidth,
//     int itemCount,
//     double barWidth,
//   ) {
//     final totalBarsWidth = barWidth * itemCount;
//     final remainingSpace = availableWidth - totalBarsWidth;
//     return remainingSpace > 0 ? remainingSpace / (itemCount + 1) : 12.0;
//   }

//   List<String> _getGraphLabels() {
//     const periodLabels = {
//       'daily': ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'],
//       'weekly': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
//       'monthly': ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'],
//       'yearly': [
//         'Jan',
//         'Feb',
//         'Mar',
//         'Apr',
//         'May',
//         'Jun',
//         'Jul',
//         'Aug',
//         'Sep',
//         'Oct',
//         'Nov',
//         'Dec',
//       ],
//     };

//     return periodLabels[widget.viewModel.selectedPeriod] ??
//         periodLabels['daily']!;
//   }

//   double _getMaxGraphValue(Map<String, List<double>> graphData) {
//     double maxValue = 0.0;
//     for (final values in graphData.values) {
//       for (final value in values) {
//         if (value > maxValue) maxValue = value;
//       }
//     }
//     return maxValue;
//   }
// }
