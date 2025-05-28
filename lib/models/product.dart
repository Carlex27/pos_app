class Product {
  final int id;
  final String SKU;
  final String nombre;
  final String marca;
  final double gradosAlcohol;
  final String tamanio;
  final double precioNormal;
  final double precioMayoreo;
  final int stock;

  Product({
    required this.id,
    required this.SKU,
    required this.nombre,
    required this.marca,
    required this.gradosAlcohol,
    required this.tamanio,
    required this.precioNormal,
    required this.precioMayoreo,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:           json['id']                as int,
      SKU:          json['sku']               as String,
      nombre:       json['nombre']            as String,
      marca:        json['marca']             as String,
      gradosAlcohol: (json['grados_alcohol']  as num).toDouble(),
      tamanio:      json['tamanio']           as String,
      precioNormal: (json['precio_normal']    as num).toDouble(),
      precioMayoreo:(json['precio_mayoreo']   as num).toDouble(),
      stock:        json['stock']             as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'sku':           SKU,
    'nombre':        nombre,
    'marca':         marca,
    'grados_alcohol':gradosAlcohol,
    'tamanio':       tamanio,
    'precio_normal': precioNormal,
    'precio_mayoreo':precioMayoreo,
    'stock':         stock,
  };
}
