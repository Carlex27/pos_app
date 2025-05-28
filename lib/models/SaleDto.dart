import 'dart:convert';

/// DTO para la solicitud de creación/actualización de Venta
class SaleDto {
  final String clientName;
  final DateTime saleDate;
  final double total;
  final String state;
  final List<SaleItemDto> items;

  SaleDto({
    required this.clientName,
    required this.saleDate,
    required this.total,
    required this.state,
    required this.items,
  });

  factory SaleDto.fromJson(Map<String, dynamic> json) {
    return SaleDto(
      clientName: json['clientName'] as String,
      saleDate:   DateTime.parse(json['saleDate'] as String),
      total:      (json['total'] as num).toDouble(),
      state:      json['state'] as String,
      items:      (json['items'] as List)
          .map((e) => SaleItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'saleDate':   saleDate.toIso8601String(),
      'total':      total,
      'state':      state,
      'items':      items.map((e) => e.toJson()).toList(),
    };
  }
}

/// DTO para detalle de artículo en la venta
class SaleItemDto {
  final int productId;
  final String productName;
  final int quantity;
  final double price;

  SaleItemDto({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory SaleItemDto.fromJson(Map<String, dynamic> json) {
    return SaleItemDto(
      productId:   json['productId'] as int,
      productName: json['productName'] as String,
      quantity:    json['quantity'] as int,
      price:       (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId':   productId,
      'productName': productName,
      'quantity':    quantity,
      'price':       price,
    };
  }
}
