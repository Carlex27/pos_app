class Department{
  final int id;
  final String name;
  final bool isActive;

  Department({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id:        json['id'] as int,
      name:      json['name'] as String,
      isActive:  json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':        id,
      'name':      name,
      'isActive':  isActive,
    };
  }
}