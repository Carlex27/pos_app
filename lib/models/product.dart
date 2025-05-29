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
      gradosAlcohol: (json['gradosAlcohol']  as num).toDouble(),
      tamanio:      json['tamanio']           as String,
      precioNormal: (json['precioNormal']    as num).toDouble(),
      precioMayoreo:(json['precioMayoreo']   as num).toDouble(),
      stock:        json['stock']             as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'sku':           SKU,
    'nombre':        nombre,
    'marca':         marca,
    'gradosAlcohol':gradosAlcohol,
    'tamanio':       tamanio,
    'precioNormal': precioNormal,
    'precioMayoreo':precioMayoreo,
    'stock':         stock,
  };
}
