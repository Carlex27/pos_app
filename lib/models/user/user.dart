class User {
  final int id;
  final String username;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  // Constructor factory para crear desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'createdAt': createdAt.toString(),
    };
  }
}