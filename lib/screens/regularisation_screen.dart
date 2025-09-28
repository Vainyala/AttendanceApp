import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart' as charts;

import 'package:flutter/material.dart';
import '../services/custom_bottom_nav_bar.dart';
import '../services/storage_service.dart';
import '../models/attendance_model.dart';

class RegularisationScreen extends StatefulWidget {
  const RegularisationScreen({super.key});

  @override
  State<RegularisationScreen> createState() => _RegularisationScreenState();
}

class _RegularisationScreenState extends State<RegularisationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AttendanceModel> _attendance = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final data = await StorageService.getAttendanceHistory();
    setState(() {
      _attendance = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Regularisation'),
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "August"),
              Tab(text: "September"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent("August"),
            _buildTabContent("September"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String month) {
    // Filter attendance by month (dummy filter for now)
    final records = _attendance; // TODO: filter by month from date

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text("Avg Shortfall :- 01:30 Hrs - "),
                  Icon(Icons.thumb_down, color: Colors.orange),
                  Text(" YOU'R LAGGING",
                      style: TextStyle(color: Colors.orange)),
                ],
              ),
              Row(
                children: const [
                  Text("Avg Catch Up:- 5:30 Hrs - "),
                  Icon(Icons.thumb_up, color: Colors.green),
                  Text(" GREAT", style: TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar chart
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [BarChartRodData(toY: 2, color: Colors.deepOrange)],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [BarChartRodData(toY: 7, color: Colors.green)],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [BarChartRodData(toY: 1, color: Colors.orange)],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [BarChartRodData(toY: 2, color: Colors.red)],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return Text('Apply');
                          case 1: return Text('Approved');
                          case 2: return Text('Pending');
                          case 3: return Text('Rejected');
                        }
                        return Text('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Table header
          const Row(
            children: [
              Expanded(flex: 2, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Clock Hrs", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Shortfall", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Regularize", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(),

          // Records list
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Row(
                  children: [
                    Expanded(flex: 2, child: Text(r.date)), // ensure date is String
                    const Expanded(flex: 2, child: Text("08:00")), // replace with real clock hrs
                    const Expanded(flex: 2, child: Text("01:30")), // replace with real shortfall
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(r.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
