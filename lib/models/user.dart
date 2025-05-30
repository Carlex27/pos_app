class User {
  final String id;
  final String name;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  // Constructor factory para crear desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}