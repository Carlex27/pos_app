class Client{
  final int id;
  final String name;
  final String direction;
  final String phoneNumber;
  final double balance;
  final double creditLimit;

  Client({
    required this.id,
    required this.name,
    required this.direction,
    required this.phoneNumber,
    required this.balance,
    required this.creditLimit,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id:           json['id'] as int,
      name:         json['name'] as String,
      direction:    json['direction'] as String,
      phoneNumber:  json['phoneNumber'] as String,
      balance:      (json['balance'] as num).toDouble(),
      creditLimit:  (json['creditLimit'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':           id,
      'name':         name,
      'direction':    direction,
      'phoneNumber':  phoneNumber,
      'balance':      balance,
      'creditLimit':  creditLimit,
    };
  }
  static Client empty() {
    return Client(
      // fill with default/empty values
      id: 0,
      name: '',
      direction: '',
      phoneNumber: '',
      balance: 0.0,
      creditLimit: 0.0,
      // add other fields as needed
    );
  }
}
