class AltaProduct {
  final String sku;
  final double stock;
  final String nombre;
  int cantidad;
  double precioCosto;

  AltaProduct({
    required this.sku,
    required this.stock,
    required this.nombre,
    required this.cantidad,
    required this.precioCosto,
  });

  factory AltaProduct.fromJson(Map<String, dynamic> json) {
    return AltaProduct(
      sku:          json['sku']               as String,
      stock:        json['stock']             as double,
      nombre:       json['nombre']            as String,
      cantidad:     json['cantidad']          as int,
      precioCosto:  json['precioCosto']       as double,
    );
  }

  AltaProduct copyWith({
    String? sku,
    String? nombre,
    double? stock,
    int? cantidad,
    double? precioCosto,
  }) {
    return AltaProduct(
      sku: sku ?? this.sku,
      nombre: nombre ?? this.nombre,
      stock: stock ?? this.stock,
      cantidad: cantidad ?? this.cantidad,
      precioCosto: precioCosto ?? this.precioCosto,
    );
  }

  Map<String, dynamic> toJson() => {
    'sku':           sku,
    'stock':         stock,
    'nombre':        nombre,
    'cantidad':      cantidad,
    'precioCosto':   precioCosto,
  };
}
