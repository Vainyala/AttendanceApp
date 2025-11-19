class TeamMember {
  final int? id;
  final String name;
  final String email;
  final String role;
  final String? profilePhoto;
  final String status;
  final String phoneNumber;
  final DateTime joinDate; // ✅ Add this
  final String department; // ✅ Add this

  TeamMember({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhoto,
    required this.status,
    required this.phoneNumber,
    required this.joinDate, // ✅ Add this
    required this.department, // ✅ Add this
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_photo': profilePhoto,
      'status': status,
      'phone_number': phoneNumber,
      'join_date': joinDate.toIso8601String(), // ✅ Add this
      'department': department, // ✅ Add this
    };
  }

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      profilePhoto: map['profile_photo'],
      status: map['status'],
      phoneNumber: map['phone_number'] ?? '',
      joinDate: map['join_date'] != null
          ? DateTime.parse(map['join_date'])
          : DateTime.now(), // ✅ Add this
      department: map['department'] ?? 'General', // ✅ Add this
    );
  }
}

// class TeamMember {
//   final int? id;
//   final String name;
//   final String email;
//   final String role;
//   final String? profilePhoto;
//   final String status;
//   final String phoneNumber; // ✅ Add this field

//   TeamMember({
//     this.id,
//     required this.name,
//     required this.email,
//     required this.role,
//     this.profilePhoto,
//     required this.status,
//     required this.phoneNumber, // ✅ Add this
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'role': role,
//       'profile_photo': profilePhoto,
//       'status': status,
//       'phone_number': phoneNumber, // ✅ Add this
//     };
//   }

//   factory TeamMember.fromMap(Map<String, dynamic> map) {
//     return TeamMember(
//       id: map['id'],
//       name: map['name'],
//       email: map['email'],
//       role: map['role'],
//       profilePhoto: map['profile_photo'],
//       status: map['status'],
//       phoneNumber: map['phone_number'] ?? '+919876543210', // ✅ Add with default
//     );
//   }
// }

// // class TeamMember {
// //   final int? id;
// //   final String name;
// //   final String email;
// //   final String role;
// //   final String? profilePhoto;
// //   final String status;

// //   TeamMember({
// //     this.id,
// //     required this.name,
// //     required this.email,
// //     required this.role,
// //     this.profilePhoto,
// //     required this.status,
// //   });

// //   Map<String, dynamic> toMap() {
// //     return {
// //       'id': id,
// //       'name': name,
// //       'email': email,
// //       'role': role,
// //       'profile_photo': profilePhoto,
// //       'status': status,
// //     };
// //   }

// //   factory TeamMember.fromMap(Map<String, dynamic> map) {
// //     return TeamMember(
// //       id: map['id'],
// //       name: map['name'],
// //       email: map['email'],
// //       role: map['role'],
// //       profilePhoto: map['profile_photo'],
// //       status: map['status'],
// //     );
// //   }
// // }
