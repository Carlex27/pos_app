import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductTile({ required this.product, this.onTap, Key? key }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return ListTile(
      title: Text(product.nombre),
      subtitle: Text('${product.marca} • \$${product.precioNormal.toStringAsFixed(2)}'),
      trailing: Text('Stock: ${product.stock}'),
      onTap: onTap,
    );
  }
}