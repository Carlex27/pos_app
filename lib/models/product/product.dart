class Product {
  final int id;
  final String SKU;
  final String nombre;
  final String departamento;
  final double precioCosto;
  final double precioVenta;
  final double precioMayoreo;
  final double precioUnidadVenta;
  final double precioUnidadMayoreo;
  final int unidadesPorPresentacion; // Por defecto, si no se especifica
  final double stock;
  final int stockPorUnidad;
  final int stockMinimo;
  final int minimoMayoreo;
  final String imagePath;

  Product({
    required this.id,
    required this.SKU,
    required this.nombre,
    required this.departamento,
    required this.precioCosto,
    required this.precioVenta,
    required this.precioMayoreo,
    required this.precioUnidadVenta,
    required this.precioUnidadMayoreo,
    required this.unidadesPorPresentacion, // Por defecto 1 unidad
    required this.stock,
    required this.stockMinimo,
    required this.stockPorUnidad,
    required this.minimoMayoreo,
    this.imagePath = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:              json['id'] as int,
      SKU:             json['sku'] as String,
      nombre:          json['nombre'] as String,
      departamento:    json['departamento'] as String,
      precioCosto:     (json['precioCosto'] as num).toDouble(),
      precioVenta:     (json['precioVenta'] as num).toDouble(),
      precioMayoreo:   (json['precioMayoreo'] as num).toDouble(),
      precioUnidadVenta: (json['precioUnidadVenta'] as num).toDouble(),
      precioUnidadMayoreo: (json['precioUnidadMayoreo'] as num).toDouble(),
      unidadesPorPresentacion: json['unidadesPorPresentacion'] as int? ?? 1,
      stock:           (json['stock'] as num).toDouble(),
      stockPorUnidad:  json['stockPorUnidad'] as int,
      stockMinimo:     json['stockMinimo'] as int,
      minimoMayoreo:   json['minimoMayoreo'] as int,
      imagePath:       json['imagePath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': SKU,
      'nombre': nombre,
      'departamento': departamento,
      'precioCosto': precioCosto,
      'precioVenta': precioVenta,
      'precioMayoreo': precioMayoreo,
      'precioUnidadVenta': precioUnidadVenta,
      'precioUnidadMayoreo': precioUnidadMayoreo,
      'unidadesPorPresentacion': unidadesPorPresentacion,
      'stock': stock,
      'stockPorUnidad': stockPorUnidad,
      'stockMinimo': stockMinimo,
      'minimoMayoreo': minimoMayoreo,
      'imagePath': imagePath,
    };
  }
}
