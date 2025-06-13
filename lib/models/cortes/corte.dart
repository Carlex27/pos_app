import 'package:pos_app/models/cortes/VentasPorDepartamento.dart';

class Corte{
  final double ventasEfectivo;
  final double pagoClientes;
  final double pagoProveedores;
  final List<VentasPorDepartamento> ventasPorDepartamento;
  final double dineroEnCaja;
  final double ventasTotales;
  final double gananciaDelDia;

  Corte({
    required this.ventasEfectivo,
    required this.pagoClientes,
    required this.pagoProveedores,
    required this.ventasPorDepartamento,
    required this.dineroEnCaja,
    required this.ventasTotales,
    required this.gananciaDelDia,
  });

  factory Corte.fromJson(Map<String, dynamic> json) {
    return Corte(
      ventasEfectivo: (json['ventasEfectivo'] as num).toDouble(),
      pagoClientes: (json['pagoClientes'] as num).toDouble(),
      pagoProveedores: (json['pagoProveedores'] as num).toDouble(),
      ventasPorDepartamento: List<VentasPorDepartamento>.from(
        json['ventasPorDepartamento'].map((x) => VentasPorDepartamento.fromJson(x)),
      ),
      dineroEnCaja: (json['dineroEnCaja'] as num).toDouble(),
      ventasTotales: (json['ventasTotales'] as num).toDouble(),
      gananciaDelDia: (json['gananciaDelDia'] as num?)?.toDouble() ?? 0.0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'ventasEfectivo': ventasEfectivo,
      'pagoClientes': pagoClientes,
      'pagoProveedores': pagoProveedores,
      'ventasPorDepartamento': List<dynamic>.from(ventasPorDepartamento.map((x) => x.toJson())),
      'dineroEnCaja': dineroEnCaja,
      'ventasTotales': ventasTotales,
      'gananciaDelDia': gananciaDelDia,
    };
  }
}