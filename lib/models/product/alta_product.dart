class AltaProduct {
  final String sku;
  final double stock;
  final String nombre;
  int cantidad;

  AltaProduct({
    required this.sku,
    required this.stock,
    required this.nombre,
    this.cantidad = 1,
  });

  factory AltaProduct.fromJson(Map<String, dynamic> json) {
    return AltaProduct(
      sku:          json['sku']               as String,
      stock:        json['stock']             as double,
      nombre:       json['nombre']            as String,
      cantidad:     json['cantidad']          as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'sku':           sku,
    'stock':         stock,
    'nombre':        nombre,
    'cantidad':      cantidad,
  };
}
