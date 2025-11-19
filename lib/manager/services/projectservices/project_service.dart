

import '../../models/project_model.dart' hide Project;
import '../../models/projectmodels/project_models.dart';
import '../../models/team_model.dart';

class ProjectService {
  List<Project> _projects = [];
  List<TeamMember> _availableTeam = [];

  ProjectService() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _availableTeam = [
      TeamMember(
        name: 'Raj Sharma',
        email: 'raj.sharma@nutantek.com',
        role: 'Senior Developer',
        status: 'active',
        phoneNumber: '+919876543210', // ✅ Add phone number
        joinDate: DateTime(2023, 1, 15), // ✅ Add required parameter
        department: 'Engineering', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Priya Singh',
        email: 'priya.singh@nutantek.com',
        role: 'UI/UX Designer',
        status: 'active',
        phoneNumber: '+919876543211', // ✅ Add phone number
        joinDate: DateTime(2023, 3, 20), // ✅ Add required parameter
        department: 'Design', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Amit Kumar',
        email: 'amit.kumar@nutantek.com',
        role: 'QA Engineer',
        status: 'active',
        phoneNumber: '+919876543212', // ✅ Add phone number
        joinDate: DateTime(2023, 2, 10), // ✅ Add required parameter
        department: 'Quality Assurance', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Neha Patel',
        email: 'neha.patel@nutantek.com',
        role: 'Project Manager',
        status: 'active',
        phoneNumber: '+919876543213', // ✅ Add phone number
        joinDate: DateTime(2022, 12, 1), // ✅ Add required parameter
        department: 'Management', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Suresh Verma',
        email: 'suresh.verma@nutantek.com',
        role: 'Backend Developer',
        status: 'active',
        phoneNumber: '+919876543214', // ✅ Add phone number
        joinDate: DateTime(2023, 4, 5), // ✅ Add required parameter
        department: 'Engineering', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Anjali Mehta',
        email: 'anjali.mehta@nutantek.com',
        role: 'Frontend Developer',
        status: 'active',
        phoneNumber: '+919876543215',
        joinDate: DateTime(2023, 5, 12), // ✅ Add required parameter
        department: 'Engineering', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Rohit Gupta',
        email: 'rohit.gupta@nutantek.com',
        role: 'DevOps Engineer',
        status: 'active',
        phoneNumber: '+919876543216',
        joinDate: DateTime(2023, 6, 8), // ✅ Add required parameter
        department: 'Operations', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Sneha Kapoor',
        email: 'sneha.kapoor@nutantek.com',
        role: 'Business Analyst',
        status: 'active',
        phoneNumber: '+919876543217',
        joinDate: DateTime(2023, 4, 25), // ✅ Add required parameter
        department: 'Business Analysis', // ✅ Add required parameter
      ),
    ];

    _projects = [
      Project(
        id: '1',
        name: 'E-Commerce Platform',
        description:
            'Development of new e-commerce platform with modern features',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 30),
        status: 'active',
        priority: 'high',
        progress: 65.0,
        budget: 500000.0,
        client: 'Fashion Store Inc.',
        assignedTeam: _availableTeam.sublist(0, 3),
        tasks: _generateSampleTasks(),
        createdAt: DateTime(2023, 12, 1),
      ),
      Project(
        id: '2',
        name: 'Mobile App Redesign',
        description: 'Redesign of customer mobile application with new UI/UX',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 5, 31),
        status: 'active',
        priority: 'medium',
        progress: 35.0,
        budget: 250000.0,
        client: 'Tech Solutions Ltd.',
        assignedTeam: _availableTeam.sublist(1, 4),
        tasks: _generateSampleTasks(),
        createdAt: DateTime(2024, 1, 15),
      ),
      Project(
        id: '3',
        name: 'Banking System Upgrade',
        description:
            'Modernization of legacy banking system with enhanced security',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 9, 30),
        status: 'active',
        priority: 'high',
        progress: 45.0,
        budget: 750000.0,
        client: 'Global Bank Corp.',
        assignedTeam: _availableTeam.sublist(2, 5),
        tasks: _generateBankingTasks(),
        createdAt: DateTime(2024, 2, 10),
      ),
      Project(
        id: '4',
        name: 'Healthcare Management System',
        description:
            'Comprehensive healthcare management platform for hospitals',
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 8, 31),
        status: 'active',
        priority: 'urgent',
        progress: 70.0,
        budget: 600000.0,
        client: 'MediCare Hospitals',
        assignedTeam: _availableTeam.sublist(0, 2) + [_availableTeam[4]],
        tasks: _generateHealthcareTasks(),
        createdAt: DateTime(2023, 12, 20),
      ),
      Project(
        id: '5',
        name: 'AI Chatbot Integration',
        description: 'Integration of AI-powered chatbot for customer support',
        startDate: DateTime(2024, 4, 1),
        endDate: DateTime(2024, 7, 15),
        status: 'planning',
        priority: 'medium',
        progress: 15.0,
        budget: 300000.0,
        client: 'CustomerFirst Inc.',
        assignedTeam: _availableTeam.sublist(3, 6),
        tasks: _generateAITasks(),
        createdAt: DateTime(2024, 3, 15),
      ),
      Project(
        id: '6',
        name: 'Inventory Management System',
        description: 'Real-time inventory tracking and management solution',
        startDate: DateTime(2024, 2, 20),
        endDate: DateTime(2024, 6, 30),
        status: 'active',
        priority: 'medium',
        progress: 55.0,
        budget: 400000.0,
        client: 'Retail Chain Stores',
        assignedTeam: _availableTeam.sublist(1, 3) + [_availableTeam[5]],
        tasks: _generateInventoryTasks(),
        createdAt: DateTime(2024, 1, 25),
      ),
      Project(
        id: '7',
        name: 'CRM Implementation',
        description: 'Custom CRM implementation for sales and marketing teams',
        startDate: DateTime(2024, 3, 10),
        endDate: DateTime(2024, 8, 20),
        status: 'active',
        priority: 'high',
        progress: 40.0,
        budget: 450000.0,
        client: 'SalesForce Pro',
        assignedTeam: _availableTeam.sublist(4, 7),
        tasks: _generateCRMTasks(),
        createdAt: DateTime(2024, 2, 28),
      ),
      Project(
        id: '8',
        name: 'Data Analytics Dashboard',
        description:
            'Interactive dashboard for business intelligence and analytics',
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 10, 31),
        status: 'planning',
        priority: 'medium',
        progress: 5.0,
        budget: 350000.0,
        client: 'Data Insights Ltd.',
        assignedTeam: _availableTeam.sublist(2, 4) + [_availableTeam[6]],
        tasks: _generateAnalyticsTasks(),
        createdAt: DateTime(2024, 4, 10),
      ),
    ];
  }

  List<ProjectTask> _generateSampleTasks() {
    return [
      ProjectTask(
        id: '1',
        title: 'Requirement Analysis',
        description: 'Gather and analyze project requirements',
        status: 'completed',
        priority: 'high',
        dueDate: DateTime(2024, 1, 15),
        assignedTo: ['raj.sharma@nutantek.com'],
        createdAt: DateTime(2024, 1, 1),
      ),
      ProjectTask(
        id: '2',
        title: 'UI/UX Design',
        description: 'Create wireframes and design mockups',
        status: 'in-progress',
        priority: 'medium',
        dueDate: DateTime(2024, 3, 1),
        assignedTo: ['priya.singh@nutantek.com'],
        createdAt: DateTime(2024, 1, 10),
      ),
      ProjectTask(
        id: '3',
        title: 'Backend Development',
        description: 'Develop server-side functionality',
        status: 'in-progress',
        priority: 'high',
        dueDate: DateTime(2024, 4, 15),
        assignedTo: ['raj.sharma@nutantek.com', 'suresh.verma@nutantek.com'],
        createdAt: DateTime(2024, 1, 20),
      ),
    ];
  }

  List<ProjectTask> _generateBankingTasks() {
    return [
      ProjectTask(
        id: 'b1',
        title: 'Security Audit',
        description: 'Conduct comprehensive security audit',
        status: 'completed',
        priority: 'high',
        dueDate: DateTime(2024, 3, 15),
        assignedTo: ['amit.kumar@nutantek.com'],
        createdAt: DateTime(2024, 3, 1),
      ),
      ProjectTask(
        id: 'b2',
        title: 'Database Migration',
        description: 'Migrate legacy database to new system',
        status: 'in-progress',
        priority: 'high',
        dueDate: DateTime(2024, 6, 30),
        assignedTo: ['suresh.verma@nutantek.com'],
        createdAt: DateTime(2024, 3, 10),
      ),
    ];
  }

  List<ProjectTask> _generateHealthcareTasks() {
    return [
      ProjectTask(
        id: 'h1',
        title: 'Patient Module',
        description: 'Develop patient management module',
        status: 'completed',
        priority: 'high',
        dueDate: DateTime(2024, 2, 28),
        assignedTo: ['raj.sharma@nutantek.com'],
        createdAt: DateTime(2024, 1, 15),
      ),
      ProjectTask(
        id: 'h2',
        title: 'Appointment System',
        description: 'Build appointment scheduling system',
        status: 'in-progress',
        priority: 'medium',
        dueDate: DateTime(2024, 5, 15),
        assignedTo: ['priya.singh@nutantek.com'],
        createdAt: DateTime(2024, 2, 1),
      ),
    ];
  }

  List<ProjectTask> _generateAITasks() {
    return [
      ProjectTask(
        id: 'ai1',
        title: 'AI Model Training',
        description: 'Train AI model with customer data',
        status: 'todo',
        priority: 'high',
        dueDate: DateTime(2024, 5, 30),
        assignedTo: ['anjali.mehta@nutantek.com'],
        createdAt: DateTime(2024, 4, 1),
      ),
    ];
  }

  List<ProjectTask> _generateInventoryTasks() {
    return [
      ProjectTask(
        id: 'i1',
        title: 'Barcode Integration',
        description: 'Integrate barcode scanning functionality',
        status: 'completed',
        priority: 'medium',
        dueDate: DateTime(2024, 3, 31),
        assignedTo: ['priya.singh@nutantek.com'],
        createdAt: DateTime(2024, 2, 20),
      ),
      ProjectTask(
        id: 'i2',
        title: 'Real-time Tracking',
        description: 'Implement real-time inventory tracking',
        status: 'in-progress',
        priority: 'high',
        dueDate: DateTime(2024, 5, 20),
        assignedTo: ['amit.kumar@nutantek.com'],
        createdAt: DateTime(2024, 3, 15),
      ),
    ];
  }

  List<ProjectTask> _generateCRMTasks() {
    return [
      ProjectTask(
        id: 'c1',
        title: 'Lead Management',
        description: 'Develop lead management module',
        status: 'in-progress',
        priority: 'high',
        dueDate: DateTime(2024, 5, 31),
        assignedTo: ['neha.patel@nutantek.com'],
        createdAt: DateTime(2024, 3, 10),
      ),
      ProjectTask(
        id: 'c2',
        title: 'Sales Pipeline',
        description: 'Build sales pipeline visualization',
        status: 'todo',
        priority: 'medium',
        dueDate: DateTime(2024, 6, 30),
        assignedTo: ['sneha.kapoor@nutantek.com'],
        createdAt: DateTime(2024, 4, 1),
      ),
    ];
  }

  List<ProjectTask> _generateAnalyticsTasks() {
    return [
      ProjectTask(
        id: 'a1',
        title: 'Data Collection',
        description: 'Set up data collection pipelines',
        status: 'todo',
        priority: 'medium',
        dueDate: DateTime(2024, 6, 15),
        assignedTo: ['rohit.gupta@nutantek.com'],
        createdAt: DateTime(2024, 5, 1),
      ),
    ];
  }

  Future<List<Project>> getProjects() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call
    return _projects;
  }

  // ✅ NEW METHOD ADDED - getProjectsSync
  List<Project> getProjectsSync() {
    return List<Project>.from(_projects); // Return a copy of the list
  }

  Future<List<TeamMember>> getAvailableTeam() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _availableTeam;
  }

  Future<void> createProject(ProjectFormData formData) async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate API call

    final assignedTeam = _availableTeam
        .where((member) => formData.assignedTeamIds.contains(member.email))
        .toList();

    final newProject = Project(
      id: (DateTime.now().millisecondsSinceEpoch).toString(),
      name: formData.name,
      description: formData.description,
      startDate: formData.startDate,
      endDate: formData.endDate,
      status: formData.status,
      priority: formData.priority,
      progress: 0.0,
      budget: formData.budget,
      client: formData.client,
      assignedTeam: assignedTeam,
      tasks: [],
      createdAt: DateTime.now(),
    );

    _projects.add(newProject);
  }

  Future<void> updateProject(String projectId, ProjectFormData formData) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex != -1) {
      final assignedTeam = _availableTeam
          .where((member) => formData.assignedTeamIds.contains(member.email))
          .toList();

      _projects[projectIndex] = Project(
        id: projectId,
        name: formData.name,
        description: formData.description,
        startDate: formData.startDate,
        endDate: formData.endDate,
        status: formData.status,
        priority: formData.priority,
        progress: _projects[projectIndex].progress,
        budget: formData.budget,
        client: formData.client,
        assignedTeam: assignedTeam,
        tasks: _projects[projectIndex].tasks,
        createdAt: _projects[projectIndex].createdAt,
      );
    }
  }

  Future<void> deleteProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _projects.removeWhere((p) => p.id == projectId);
  }
}

// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/models/team_model.dart';

// class ProjectService {
//   List<Project> _projects = [];
//   List<TeamMember> _availableTeam = [];

//   ProjectService() {
//     _initializeSampleData();
//   }

//   void _initializeSampleData() {
//     _availableTeam = [
//       TeamMember(
//         name: 'Raj Sharma',
//         email: 'raj.sharma@nutantek.com',
//         role: 'Senior Developer',
//         status: 'active',
//         phoneNumber: '+919876543210', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Priya Singh',
//         email: 'priya.singh@nutantek.com',
//         role: 'UI/UX Designer',
//         status: 'active',
//         phoneNumber: '+919876543211', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Amit Kumar',
//         email: 'amit.kumar@nutantek.com',
//         role: 'QA Engineer',
//         status: 'active',
//         phoneNumber: '+919876543212', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Neha Patel',
//         email: 'neha.patel@nutantek.com',
//         role: 'Project Manager',
//         status: 'active',
//         phoneNumber: '+919876543213', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Suresh Verma',
//         email: 'suresh.verma@nutantek.com',
//         role: 'Backend Developer',
//         status: 'active',
//         phoneNumber: '+919876543214', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Anjali Mehta',
//         email: 'anjali.mehta@nutantek.com',
//         role: 'Frontend Developer',
//         status: 'active',
//         phoneNumber: '+919876543215',
//       ),
//       TeamMember(
//         name: 'Rohit Gupta',
//         email: 'rohit.gupta@nutantek.com',
//         role: 'DevOps Engineer',
//         status: 'active',
//         phoneNumber: '+919876543216',
//       ),
//       TeamMember(
//         name: 'Sneha Kapoor',
//         email: 'sneha.kapoor@nutantek.com',
//         role: 'Business Analyst',
//         status: 'active',
//         phoneNumber: '+919876543217',
//       ),
//     ];

//     _projects = [
//       Project(
//         id: '1',
//         name: 'E-Commerce Platform',
//         description:
//             'Development of new e-commerce platform with modern features',
//         startDate: DateTime(2024, 1, 1),
//         endDate: DateTime(2024, 6, 30),
//         status: 'active',
//         priority: 'high',
//         progress: 65.0,
//         budget: 500000.0,
//         client: 'Fashion Store Inc.',
//         assignedTeam: _availableTeam.sublist(0, 3),
//         tasks: _generateSampleTasks(),
//         createdAt: DateTime(2023, 12, 1),
//       ),
//       Project(
//         id: '2',
//         name: 'Mobile App Redesign',
//         description: 'Redesign of customer mobile application with new UI/UX',
//         startDate: DateTime(2024, 2, 1),
//         endDate: DateTime(2024, 5, 31),
//         status: 'active',
//         priority: 'medium',
//         progress: 35.0,
//         budget: 250000.0,
//         client: 'Tech Solutions Ltd.',
//         assignedTeam: _availableTeam.sublist(1, 4),
//         tasks: _generateSampleTasks(),
//         createdAt: DateTime(2024, 1, 15),
//       ),
//       Project(
//         id: '3',
//         name: 'Banking System Upgrade',
//         description:
//             'Modernization of legacy banking system with enhanced security',
//         startDate: DateTime(2024, 3, 1),
//         endDate: DateTime(2024, 9, 30),
//         status: 'active',
//         priority: 'high',
//         progress: 45.0,
//         budget: 750000.0,
//         client: 'Global Bank Corp.',
//         assignedTeam: _availableTeam.sublist(2, 5),
//         tasks: _generateBankingTasks(),
//         createdAt: DateTime(2024, 2, 10),
//       ),
//       Project(
//         id: '4',
//         name: 'Healthcare Management System',
//         description:
//             'Comprehensive healthcare management platform for hospitals',
//         startDate: DateTime(2024, 1, 15),
//         endDate: DateTime(2024, 8, 31),
//         status: 'active',
//         priority: 'urgent',
//         progress: 70.0,
//         budget: 600000.0,
//         client: 'MediCare Hospitals',
//         assignedTeam: _availableTeam.sublist(0, 2) + [_availableTeam[4]],
//         tasks: _generateHealthcareTasks(),
//         createdAt: DateTime(2023, 12, 20),
//       ),
//       Project(
//         id: '5',
//         name: 'AI Chatbot Integration',
//         description: 'Integration of AI-powered chatbot for customer support',
//         startDate: DateTime(2024, 4, 1),
//         endDate: DateTime(2024, 7, 15),
//         status: 'planning',
//         priority: 'medium',
//         progress: 15.0,
//         budget: 300000.0,
//         client: 'CustomerFirst Inc.',
//         assignedTeam: _availableTeam.sublist(3, 6),
//         tasks: _generateAITasks(),
//         createdAt: DateTime(2024, 3, 15),
//       ),
//       Project(
//         id: '6',
//         name: 'Inventory Management System',
//         description: 'Real-time inventory tracking and management solution',
//         startDate: DateTime(2024, 2, 20),
//         endDate: DateTime(2024, 6, 30),
//         status: 'active',
//         priority: 'medium',
//         progress: 55.0,
//         budget: 400000.0,
//         client: 'Retail Chain Stores',
//         assignedTeam: _availableTeam.sublist(1, 3) + [_availableTeam[5]],
//         tasks: _generateInventoryTasks(),
//         createdAt: DateTime(2024, 1, 25),
//       ),
//       Project(
//         id: '7',
//         name: 'CRM Implementation',
//         description: 'Custom CRM implementation for sales and marketing teams',
//         startDate: DateTime(2024, 3, 10),
//         endDate: DateTime(2024, 8, 20),
//         status: 'active',
//         priority: 'high',
//         progress: 40.0,
//         budget: 450000.0,
//         client: 'SalesForce Pro',
//         assignedTeam: _availableTeam.sublist(4, 7),
//         tasks: _generateCRMTasks(),
//         createdAt: DateTime(2024, 2, 28),
//       ),
//       Project(
//         id: '8',
//         name: 'Data Analytics Dashboard',
//         description:
//             'Interactive dashboard for business intelligence and analytics',
//         startDate: DateTime(2024, 5, 1),
//         endDate: DateTime(2024, 10, 31),
//         status: 'planning',
//         priority: 'medium',
//         progress: 5.0,
//         budget: 350000.0,
//         client: 'Data Insights Ltd.',
//         assignedTeam: _availableTeam.sublist(2, 4) + [_availableTeam[6]],
//         tasks: _generateAnalyticsTasks(),
//         createdAt: DateTime(2024, 4, 10),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateSampleTasks() {
//     return [
//       ProjectTask(
//         id: '1',
//         title: 'Requirement Analysis',
//         description: 'Gather and analyze project requirements',
//         status: 'completed',
//         priority: 'high',
//         dueDate: DateTime(2024, 1, 15),
//         assignedTo: ['raj.sharma@nutantek.com'],
//         createdAt: DateTime(2024, 1, 1),
//       ),
//       ProjectTask(
//         id: '2',
//         title: 'UI/UX Design',
//         description: 'Create wireframes and design mockups',
//         status: 'in-progress',
//         priority: 'medium',
//         dueDate: DateTime(2024, 3, 1),
//         assignedTo: ['priya.singh@nutantek.com'],
//         createdAt: DateTime(2024, 1, 10),
//       ),
//       ProjectTask(
//         id: '3',
//         title: 'Backend Development',
//         description: 'Develop server-side functionality',
//         status: 'in-progress',
//         priority: 'high',
//         dueDate: DateTime(2024, 4, 15),
//         assignedTo: ['raj.sharma@nutantek.com', 'suresh.verma@nutantek.com'],
//         createdAt: DateTime(2024, 1, 20),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateBankingTasks() {
//     return [
//       ProjectTask(
//         id: 'b1',
//         title: 'Security Audit',
//         description: 'Conduct comprehensive security audit',
//         status: 'completed',
//         priority: 'high',
//         dueDate: DateTime(2024, 3, 15),
//         assignedTo: ['amit.kumar@nutantek.com'],
//         createdAt: DateTime(2024, 3, 1),
//       ),
//       ProjectTask(
//         id: 'b2',
//         title: 'Database Migration',
//         description: 'Migrate legacy database to new system',
//         status: 'in-progress',
//         priority: 'high',
//         dueDate: DateTime(2024, 6, 30),
//         assignedTo: ['suresh.verma@nutantek.com'],
//         createdAt: DateTime(2024, 3, 10),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateHealthcareTasks() {
//     return [
//       ProjectTask(
//         id: 'h1',
//         title: 'Patient Module',
//         description: 'Develop patient management module',
//         status: 'completed',
//         priority: 'high',
//         dueDate: DateTime(2024, 2, 28),
//         assignedTo: ['raj.sharma@nutantek.com'],
//         createdAt: DateTime(2024, 1, 15),
//       ),
//       ProjectTask(
//         id: 'h2',
//         title: 'Appointment System',
//         description: 'Build appointment scheduling system',
//         status: 'in-progress',
//         priority: 'medium',
//         dueDate: DateTime(2024, 5, 15),
//         assignedTo: ['priya.singh@nutantek.com'],
//         createdAt: DateTime(2024, 2, 1),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateAITasks() {
//     return [
//       ProjectTask(
//         id: 'ai1',
//         title: 'AI Model Training',
//         description: 'Train AI model with customer data',
//         status: 'todo',
//         priority: 'high',
//         dueDate: DateTime(2024, 5, 30),
//         assignedTo: ['anjali.mehta@nutantek.com'],
//         createdAt: DateTime(2024, 4, 1),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateInventoryTasks() {
//     return [
//       ProjectTask(
//         id: 'i1',
//         title: 'Barcode Integration',
//         description: 'Integrate barcode scanning functionality',
//         status: 'completed',
//         priority: 'medium',
//         dueDate: DateTime(2024, 3, 31),
//         assignedTo: ['priya.singh@nutantek.com'],
//         createdAt: DateTime(2024, 2, 20),
//       ),
//       ProjectTask(
//         id: 'i2',
//         title: 'Real-time Tracking',
//         description: 'Implement real-time inventory tracking',
//         status: 'in-progress',
//         priority: 'high',
//         dueDate: DateTime(2024, 5, 20),
//         assignedTo: ['amit.kumar@nutantek.com'],
//         createdAt: DateTime(2024, 3, 15),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateCRMTasks() {
//     return [
//       ProjectTask(
//         id: 'c1',
//         title: 'Lead Management',
//         description: 'Develop lead management module',
//         status: 'in-progress',
//         priority: 'high',
//         dueDate: DateTime(2024, 5, 31),
//         assignedTo: ['neha.patel@nutantek.com'],
//         createdAt: DateTime(2024, 3, 10),
//       ),
//       ProjectTask(
//         id: 'c2',
//         title: 'Sales Pipeline',
//         description: 'Build sales pipeline visualization',
//         status: 'todo',
//         priority: 'medium',
//         dueDate: DateTime(2024, 6, 30),
//         assignedTo: ['sneha.kapoor@nutantek.com'],
//         createdAt: DateTime(2024, 4, 1),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateAnalyticsTasks() {
//     return [
//       ProjectTask(
//         id: 'a1',
//         title: 'Data Collection',
//         description: 'Set up data collection pipelines',
//         status: 'todo',
//         priority: 'medium',
//         dueDate: DateTime(2024, 6, 15),
//         assignedTo: ['rohit.gupta@nutantek.com'],
//         createdAt: DateTime(2024, 5, 1),
//       ),
//     ];
//   }

//   Future<List<Project>> getProjects() async {
//     await Future.delayed(
//       const Duration(milliseconds: 500),
//     ); // Simulate API call
//     return _projects;
//   }

//   Future<List<TeamMember>> getAvailableTeam() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return _availableTeam;
//   }

//   Future<void> createProject(ProjectFormData formData) async {
//     await Future.delayed(
//       const Duration(milliseconds: 800),
//     ); // Simulate API call

//     final assignedTeam = _availableTeam
//         .where((member) => formData.assignedTeamIds.contains(member.email))
//         .toList();

//     final newProject = Project(
//       id: (DateTime.now().millisecondsSinceEpoch).toString(),
//       name: formData.name,
//       description: formData.description,
//       startDate: formData.startDate,
//       endDate: formData.endDate,
//       status: formData.status,
//       priority: formData.priority,
//       progress: 0.0,
//       budget: formData.budget,
//       client: formData.client,
//       assignedTeam: assignedTeam,
//       tasks: [],
//       createdAt: DateTime.now(),
//     );

//     _projects.add(newProject);
//   }

//   Future<void> updateProject(String projectId, ProjectFormData formData) async {
//     await Future.delayed(const Duration(milliseconds: 800));

//     final projectIndex = _projects.indexWhere((p) => p.id == projectId);
//     if (projectIndex != -1) {
//       final assignedTeam = _availableTeam
//           .where((member) => formData.assignedTeamIds.contains(member.email))
//           .toList();

//       _projects[projectIndex] = Project(
//         id: projectId,
//         name: formData.name,
//         description: formData.description,
//         startDate: formData.startDate,
//         endDate: formData.endDate,
//         status: formData.status,
//         priority: formData.priority,
//         progress: _projects[projectIndex].progress,
//         budget: formData.budget,
//         client: formData.client,
//         assignedTeam: assignedTeam,
//         tasks: _projects[projectIndex].tasks,
//         createdAt: _projects[projectIndex].createdAt,
//       );
//     }
//   }

//   Future<void> deleteProject(String projectId) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _projects.removeWhere((p) => p.id == projectId);
//   }
// }

// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/models/team_model.dart';

// class ProjectService {
//   List<Project> _projects = [];
//   List<TeamMember> _availableTeam = [];

//   ProjectService() {
//     _initializeSampleData();
//   }

//   void _initializeSampleData() {
//     _availableTeam = [
//       TeamMember(
//         name: 'Raj Sharma',
//         email: 'raj.sharma@nutantek.com',
//         role: 'Senior Developer',
//         status: 'active',
//         phoneNumber: '+919876543210', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Priya Singh',
//         email: 'priya.singh@nutantek.com',
//         role: 'UI/UX Designer',
//         status: 'active',
//         phoneNumber: '+919876543211', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Amit Kumar',
//         email: 'amit.kumar@nutantek.com',
//         role: 'QA Engineer',
//         status: 'active',
//         phoneNumber: '+919876543212', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Neha Patel',
//         email: 'neha.patel@nutantek.com',
//         role: 'Project Manager',
//         status: 'active',
//         phoneNumber: '+919876543213', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Suresh Verma',
//         email: 'suresh.verma@nutantek.com',
//         role: 'Backend Developer',
//         status: 'active',
//         phoneNumber: '+919876543214', // ✅ Add phone number
//       ),
//     ];

//     _projects = [
//       Project(
//         id: '1',
//         name: 'E-Commerce Platform',
//         description:
//             'Development of new e-commerce platform with modern features',
//         startDate: DateTime(2024, 1, 1),
//         endDate: DateTime(2024, 6, 30),
//         status: 'active',
//         priority: 'high',
//         progress: 65.0,
//         budget: 500000.0,
//         client: 'Fashion Store Inc.',
//         assignedTeam: _availableTeam.sublist(0, 3),
//         tasks: _generateSampleTasks(),
//         createdAt: DateTime(2023, 12, 1),
//       ),
//       Project(
//         id: '2',
//         name: 'Mobile App Redesign',
//         description: 'Redesign of customer mobile application with new UI/UX',
//         startDate: DateTime(2024, 2, 1),
//         endDate: DateTime(2024, 5, 31),
//         status: 'active',
//         priority: 'medium',
//         progress: 35.0,
//         budget: 250000.0,
//         client: 'Tech Solutions Ltd.',
//         assignedTeam: _availableTeam.sublist(1, 4),
//         tasks: _generateSampleTasks(),
//         createdAt: DateTime(2024, 1, 15),
//       ),
//     ];
//   }

//   List<ProjectTask> _generateSampleTasks() {
//     return [
//       ProjectTask(
//         id: '1',
//         title: 'Requirement Analysis',
//         description: 'Gather and analyze project requirements',
//         status: 'completed',
//         priority: 'high',
//         dueDate: DateTime(2024, 1, 15),
//         assignedTo: ['raj.sharma@nutantek.com'],
//         createdAt: DateTime(2024, 1, 1),
//       ),
//       ProjectTask(
//         id: '2',
//         title: 'UI/UX Design',
//         description: 'Create wireframes and design mockups',
//         status: 'in-progress',
//         priority: 'medium',
//         dueDate: DateTime(2024, 3, 1),
//         assignedTo: ['priya.singh@nutantek.com'],
//         createdAt: DateTime(2024, 1, 10),
//       ),
//       ProjectTask(
//         id: '3',
//         title: 'Backend Development',
//         description: 'Develop server-side functionality',
//         status: 'in-progress',
//         priority: 'high',
//         dueDate: DateTime(2024, 4, 15),
//         assignedTo: ['raj.sharma@nutantek.com', 'neha.gupta@nutantek.com'],
//         createdAt: DateTime(2024, 1, 20),
//       ),
//     ];
//   }

//   Future<List<Project>> getProjects() async {
//     await Future.delayed(
//       const Duration(milliseconds: 500),
//     ); // Simulate API call
//     return _projects;
//   }

//   Future<List<TeamMember>> getAvailableTeam() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return _availableTeam;
//   }

//   Future<void> createProject(ProjectFormData formData) async {
//     await Future.delayed(
//       const Duration(milliseconds: 800),
//     ); // Simulate API call

//     final assignedTeam = _availableTeam
//         .where((member) => formData.assignedTeamIds.contains(member.email))
//         .toList();

//     final newProject = Project(
//       id: (DateTime.now().millisecondsSinceEpoch).toString(),
//       name: formData.name,
//       description: formData.description,
//       startDate: formData.startDate,
//       endDate: formData.endDate,
//       status: formData.status,
//       priority: formData.priority,
//       progress: 0.0,
//       budget: formData.budget,
//       client: formData.client,
//       assignedTeam: assignedTeam,
//       tasks: [],
//       createdAt: DateTime.now(),
//     );

//     _projects.add(newProject);
//   }

//   Future<void> updateProject(String projectId, ProjectFormData formData) async {
//     await Future.delayed(const Duration(milliseconds: 800));

//     final projectIndex = _projects.indexWhere((p) => p.id == projectId);
//     if (projectIndex != -1) {
//       final assignedTeam = _availableTeam
//           .where((member) => formData.assignedTeamIds.contains(member.email))
//           .toList();

//       _projects[projectIndex] = Project(
//         id: projectId,
//         name: formData.name,
//         description: formData.description,
//         startDate: formData.startDate,
//         endDate: formData.endDate,
//         status: formData.status,
//         priority: formData.priority,
//         progress: _projects[projectIndex].progress,
//         budget: formData.budget,
//         client: formData.client,
//         assignedTeam: assignedTeam,
//         tasks: _projects[projectIndex].tasks,
//         createdAt: _projects[projectIndex].createdAt,
//       );
//     }
//   }

//   Future<void> deleteProject(String projectId) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _projects.removeWhere((p) => p.id == projectId);
//   }
// }
