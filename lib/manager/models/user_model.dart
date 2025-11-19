class User {
  final int? id;
  final String email;
  final String password;
  final String userType;
  final String name;
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.userType,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'user_type': userType,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      userType: map['user_type'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  final Map<String, dynamic>? locationData;

  LoginResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.locationData,
  });
}
