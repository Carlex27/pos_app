class SaleDashboard {
  final String nombreCliente;
  final DateTime fechaVenta;
  final double totalVenta;
  final int cantidadProductos;


  SaleDashboard({
    required this.nombreCliente,
    required this.fechaVenta,
    required this.totalVenta,
    required this.cantidadProductos,
  });

  factory SaleDashboard.fromJson(Map<String, dynamic> json) {
    return SaleDashboard(
      nombreCliente: json['nombreCliente'] as String,
      fechaVenta: DateTime.parse(json['fechaVenta'] as String),
      totalVenta: (json['totalVenta'] as num).toDouble(),
      cantidadProductos: json['cantidadProductos'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombreCliente': nombreCliente,
    'fechaVenta': fechaVenta.toString(),
    'totalVenta': totalVenta,
    'cantidadProductos': cantidadProductos,
  };
}