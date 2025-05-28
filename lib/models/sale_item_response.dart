class SaleItemResponse {
  final String sku;
  final String nombre;
  final String marca;
  final int cantidad;
  final double precio;

  SaleItemResponse({
    required this.sku,
    required this.nombre,
    required this.marca,
    required this.cantidad,
    required this.precio,
  });

  factory SaleItemResponse.fromJson(Map<String, dynamic> json) {
    return SaleItemResponse(
      sku:      json['sku']      as String,
      nombre:   json['nombre']   as String,
      marca:    json['marca']    as String,
      cantidad: json['cantidad'] as int,
      precio:   (json['precio']  as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sku':      sku,
    'nombre':   nombre,
    'marca':    marca,
    'cantidad': cantidad,
    'precio':   precio,
  };
}
