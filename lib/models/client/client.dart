class Client{
  final int id;
  final String name;
  final String direction;
  final String phoneNumber;
  final double creditLimit;

  Client({
    required this.id,
    required this.name,
    required this.direction,
    required this.phoneNumber,
    required this.creditLimit,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id:           json['id'] as int,
      name:         json['name'] as String,
      direction:    json['direction'] as String,
      phoneNumber:  json['phoneNumber'] as String,
      creditLimit:  (json['creditLimit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':           id,
      'name':         name,
      'direction':    direction,
      'phoneNumber':  phoneNumber,
      'creditLimit':  creditLimit,
    };
  }
}