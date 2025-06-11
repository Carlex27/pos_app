class Client {
  final int id;
  final String name;
  final String direction;
  final String phoneNumber;
  final double balance;
  final double creditLimit; // Ya estaba bien, pero para mantener consistencia con lastAbonoDate si también puede ser null lógicamente
  final DateTime? lastAbonoDate; // Hacerla nullable

  Client({
    required this.id,
    required this.name,
    required this.direction,
    required this.phoneNumber,
    required this.balance,
    required this.creditLimit,
    this.lastAbonoDate, // Ya no es 'required' o puede ser null
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int,
      name: json['name'] as String,
      direction: json['direction'] as String,
      phoneNumber: json['phoneNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      creditLimit: (json['creditLimit'] as num? ?? 0.0).toDouble(), // Asegurar que el default sea double
      lastAbonoDate: json['lastAbonoDate'] == null
          ? null // Si es null en JSON, asigna null
          : DateTime.parse(json['lastAbonoDate'] as String), // Sino, parsea
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'direction': direction,
      'phoneNumber': phoneNumber,
      'balance': balance,
      'creditLimit': creditLimit,
      'lastAbonoDate': lastAbonoDate?.toIso8601String(), // Manejar null al convertir a JSON
    };
  }

  static Client empty() {
    return Client(
      id: 0,
      name: '',
      direction: '',
      phoneNumber: '',
      balance: 0.0,
      creditLimit: 0.0,
      lastAbonoDate: null, // Valor por defecto para nullable DateTime
    );
  }
}