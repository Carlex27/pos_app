// Si necesitas formateo de fecha específico para toJson, importa intl:
// import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Para @override y potentially required

class ProductInventoryEntry {
  final int id;
  final int cajasCompradas;
  final double precioPorCaja;
  final DateTime entryDate;

  ProductInventoryEntry({
    required this.id,
    required this.cajasCompradas,
    required this.precioPorCaja,
    required this.entryDate,
  });

  // Factory constructor para crear desde JSON
  factory ProductInventoryEntry.fromJson(Map<String, dynamic> json) {
    return ProductInventoryEntry(
      id:           json['id'] as int,
      cajasCompradas: json['cajasCompradas'] as int,
      precioPorCaja:  (json['precioPorCaja'] as num).toDouble(),
      entryDate: DateTime.parse(json['entryDate'] as String)
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cajasCompradas': cajasCompradas,
      'precioPorCaja': precioPorCaja,// Estándar para fechas en JSON
    };
  }

  // Método copyWith para crear una copia con algunos campos modificados
  ProductInventoryEntry copyWith({
    int? id,
    int? cajasCompradas,
    double? precioPorCaja,
    DateTime? entryDate,
  }) {
    return ProductInventoryEntry(
      id: id ?? this.id,
      cajasCompradas: cajasCompradas ?? this.cajasCompradas,
      precioPorCaja: precioPorCaja ?? this.precioPorCaja,
      entryDate: entryDate ?? this.entryDate,
    );
  }


}