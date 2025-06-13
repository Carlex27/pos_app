class Salidas {
  final int id;
  final String description;
  final double amount;
  final DateTime date;

  Salidas({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Salidas.fromJson(Map<String, dynamic> json) {
    return Salidas(
      id: json['id'] as int,
      description: json['description'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  Salidas copyWith({
    int? id,
    String? description,
    double? amount,
    DateTime? date,
  }) {
    return Salidas(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  static Salidas empty() {
    return Salidas(
      id: 0,
      description: '',
      amount: 0.0,
      date: DateTime.now(),
    );
  }
}