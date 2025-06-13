class VentasPorDepartamento{
  final String nombreDepartamento;
  final double totalVentas;

  VentasPorDepartamento({required this.nombreDepartamento, required this.totalVentas});

  factory VentasPorDepartamento.fromJson(Map<String, dynamic> json) {
    return VentasPorDepartamento(
      nombreDepartamento: json['nombreDepartamento'] as String,
      totalVentas: (json['totalVentas'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departamento': nombreDepartamento,
      'ventas': totalVentas,
    };
  }
}