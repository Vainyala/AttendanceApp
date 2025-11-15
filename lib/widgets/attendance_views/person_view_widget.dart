// widgets/attendance_views/person_view_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';
import '../../screens/attendance_detailed_screen.dart';

class PersonViewWidget extends StatefulWidget {
  const PersonViewWidget({Key? key}) : super(key: key);

  @override
  State<PersonViewWidget> createState() => _PersonViewWidgetState();
}

class _PersonViewWidgetState extends State<PersonViewWidget> {
  String _searchQuery = '';
  String _sortByName = 'A-Z';
  String _sortByProject = 'A-Z';
  Map<String, bool> _expandedCards = {};

  // Mock employee data - Replace with actual data from your provider
  final List<Map<String, dynamic>> _allEmployees = [
    {
      'id': 'EMP001',
      'name': 'Amit Kumar', // Current logged-in user
      'role': 'QA Engineer',
      'status': 'Present',
      'checkIn': '09:00 AM',
      'checkOut': '06:00 PM',
      'projectCount': 5,
      'periodType': 'Daily',
      'projects': ['E-Commerce Platform', 'Mobile App Redesign', 'Banking System Upgrade', 'Inventory Management', 'Data Analytics Dashboard'],
      'attendance': {
        'present': 18,
        'leave': 2,
        'absent': 1,
        'onTime': 16,
        'late': 3,
      },
    },
    {
      'id': 'EMP002',
      'name': 'Neha Patel',
      'role': 'Project Manager',
      'status': 'Present',
      'checkIn': '09:00 AM',
      'checkOut': '06:00 PM',
      'projectCount': 4,
      'periodType': 'Daily',
      'projects': ['Mobile App Redesign', 'Banking System Upgrade', 'AI Chatbot Integration', 'Data Analytics Dashboard'],
      'attendance': {
        'present': 20,
        'leave': 1,
        'absent': 0,
        'onTime': 18,
        'late': 2,
      },
    },
    {
      'id': 'EMP003',
      'name': 'Rahul Sharma',
      'role': 'Senior Developer',
      'status': 'Present',
      'checkIn': '09:15 AM',
      'checkOut': '06:30 PM',
      'projectCount': 3,
      'periodType': 'Daily',
      'projects': ['E-Commerce Platform', 'Banking System Upgrade', 'Inventory Management'],
      'attendance': {
        'present': 19,
        'leave': 1,
        'absent': 1,
        'onTime': 17,
        'late': 3,
      },
    },
    {
      'id': 'EMP004',
      'name': 'Priya Singh',
      'role': 'UI/UX Designer',
      'status': 'Present',
      'checkIn': '09:30 AM',
      'checkOut': '06:00 PM',
      'projectCount': 4,
      'periodType': 'Daily',
      'projects': ['Mobile App Redesign', 'E-Commerce Platform', 'AI Chatbot Integration', 'Data Analytics Dashboard'],
      'attendance': {
        'present': 17,
        'leave': 2,
        'absent': 2,
        'onTime': 15,
        'late': 4,
      },
    },
    {
      'id': 'EMP005',
      'name': 'Vikram Desai',
      'role': 'Backend Developer',
      'status': 'Present',
      'checkIn': '09:00 AM',
      'checkOut': '06:00 PM',
      'projectCount': 3,
      'periodType': 'Daily',
      'projects': ['Banking System Upgrade', 'E-Commerce Platform', 'Inventory Management'],
      'attendance': {
        'present': 21,
        'leave': 0,
        'absent': 0,
        'onTime': 20,
        'late': 1,
      },
    },
  ];

  List<Map<String, dynamic>> _getFilteredEmployees() {
    List<Map<String, dynamic>> filtered = List.from(_allEmployees);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((emp) {
        final name = emp['name'].toString().toLowerCase();
        final role = emp['role'].toString().toLowerCase();
        final projects = (emp['projects'] as List).join(' ').toLowerCase();
        return name.contains(_searchQuery) ||
            role.contains(_searchQuery) ||
            projects.contains(_searchQuery);
      }).toList();
    }

    // Apply name sorting
    if (_sortByName == 'A-Z') {
      filtered.sort((a, b) => a['name'].compareTo(b['name']));
    } else {
      filtered.sort((a, b) => b['name'].compareTo(a['name']));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final employees = _getFilteredEmployees();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(employees.length, provider),
              SizedBox(height: 16),
              _buildSearchBar(),
              SizedBox(height: 16),
              _buildSortOptions(),
              SizedBox(height: 16),
              ...employees.map((employee) => _buildEmployeeCard(employee, provider)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int count, AnalyticsProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.group, color: Colors.blue, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Overview - ${provider.getModeLabel()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Date: ${provider.getFormattedDateInfo()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Text(
              '$count Employees',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search employees by name, role, or ...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by Name',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: _sortByName,
                  isExpanded: true,
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                  items: ['A-Z', 'Z-A'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortByName = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by Project',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: _sortByProject,
                  isExpanded: true,
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                  items: ['A-Z', 'Z-A'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortByProject = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee, AnalyticsProvider provider) {
    final employeeId = employee['id'];
    final isExpanded = _expandedCards[employeeId] ?? false;
    final attendance = employee['attendance'] as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        // Navigate to details screen when clicking anywhere on the card
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceDetailsScreen(
              employeeId: employeeId,
              periodType: provider.getPeriodType(),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    employee['name'].toString().split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              employee['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  employee['status'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        employee['role'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Projects:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    ...((employee['projects'] as List).take(4).map((project) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 4),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          project.length > 15 ? '${project.substring(0, 12)}...' : project,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Text(
                  '${employee['checkIn']} - ${employee['checkOut']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.work_outline, size: 14, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Text(
                  '${employee['projectCount']} Projects',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Text(
                  employee['periodType'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Toggle expand/collapse - prevent navigation
                setState(() {
                  _expandedCards[employeeId] = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View ${provider.getModeLabel()} Attendance Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              SizedBox(height: 16),
              _buildAttendanceChart(attendance, provider, employeeId),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(Map<String, dynamic> attendance, AnalyticsProvider provider, String employeeId) {
    return GestureDetector(
      onTap: () {
        // Navigate to details when clicking on chart
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceDetailsScreen(
              employeeId: employeeId,
              periodType: provider.getPeriodType(),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${provider.getModeLabel().toUpperCase()} Attendance Distribution - ${_allEmployees.firstWhere((e) => e['id'] == employeeId)['name']}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Present', attendance['present'], Colors.green),
                _buildStatColumn('Leave', attendance['leave'], Colors.orange),
                _buildStatColumn('Absent', attendance['absent'], Colors.red),
                _buildStatColumn('OnTime', attendance['onTime'], Colors.blue),
                _buildStatColumn('Late', attendance['late'], Colors.purple),
              ],
            ),
            SizedBox(height: 16),
            _buildSimplePieChart(attendance),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimplePieChart(Map<String, dynamic> attendance) {
    final total = (attendance['present'] + attendance['leave'] + attendance['absent']).toDouble();
    final presentPercent = total > 0 ? (attendance['present'] / total * 100).round() : 0;

    return Container(
      height: 200,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: presentPercent / 100,
                strokeWidth: 30,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$presentPercent%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Present',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}