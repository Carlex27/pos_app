class UserRegistration {
  final String userName;
  final String userPassword;
  final String userRole;

  UserRegistration({
    required this.userName,
    required this.userPassword,
    required this.userRole,
  });

  // Constructor factory para crear desde JSON
  factory UserRegistration.fromJson(Map<String, dynamic> json) {
    return UserRegistration(
      userName: json['userName'] as String,
      userPassword: json['userPassword'] as String,
      userRole: json['userRole'] as String,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userPassword': userPassword,
      'userRole': userRole,
    };
  }
}