import 'package:pos_app/models/sale_dashboard.dart';

class ResumeDashboard {
  final int totalProductos;
  final int totalVentas;
  final double totalIngresos;
  final int stockBajo;
  List<SaleDashboard> ventasRecientes;


  ResumeDashboard({
    required this.totalProductos,
    required this.totalVentas,
    required this.totalIngresos,
    required this.stockBajo,
    required this.ventasRecientes,
  });

  factory ResumeDashboard.fromJson(Map<String, dynamic> json) {
    return ResumeDashboard(
      totalProductos: json['totalProductos'] as int,
      totalVentas: json['totalVentas'] as int,
      totalIngresos: (json['totalIngresos'] as num).toDouble(),
      stockBajo: json['stockBajo'] as int,
      ventasRecientes: (json['ventasRecientes'] as List)
          .map((e) => SaleDashboard.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalProductos': totalProductos,
    'totalVentas': totalVentas,
    'totalIngresos': totalIngresos,
    'stockBajo': stockBajo,
    'ventasRecientes': ventasRecientes.map((e) => e.toJson()).toList(),
  };
}