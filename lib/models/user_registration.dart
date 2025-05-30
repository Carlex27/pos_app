class UserRegistration {
  final String username;
  final String password;
  final String role;

  UserRegistration({
    required this.username,
    required this.password,
    required this.role,
  });

  // Constructor factory para crear desde JSON
  factory UserRegistration.fromJson(Map<String, dynamic> json) {
    return UserRegistration(
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'role': role,
    };
  }
}