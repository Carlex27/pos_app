import 'dart:ffi';

class ClientAbonos{
  final int id;
  final DateTime fechaAbono;
  final double montoAbono;
  final bool active;

  ClientAbonos({
    required this.id,
    required this.fechaAbono,
    required this.montoAbono,
    required this.active
  });

  factory ClientAbonos.fromJson(Map<String, dynamic> json) {
    return ClientAbonos(
        id:           json['id'] as int,
        fechaAbono: DateTime.parse(json['fechaAbono'] as String),
        montoAbono:  (json['montoAbono'] as num).toDouble(),
        active:  json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':           id,
      'fechaAbono': fechaAbono.toString(),
      'montoAbono':  montoAbono,
      'active':  active,
    };
  }

}
