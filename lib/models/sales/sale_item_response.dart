class SaleItemResponse {
  final String sku;
  final String nombre;
  final int cantidad;
  final double precio;

  SaleItemResponse({
    required this.sku,
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  factory SaleItemResponse.fromJson(Map<String, dynamic> json) {
    return SaleItemResponse(
      sku:      json['sku']      as String,
      nombre:   json['nombre']   as String,
      cantidad: json['cantidad'] as int,
      precio:   (json['precio']  as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sku':      sku,
    'nombre':   nombre,
    'cantidad': cantidad,
    'precio':   precio,
  };
}
