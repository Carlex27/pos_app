import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../widgets/product_tile.dart';

/// Pantalla de listado de productos
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ProductService>(context, listen: false);
    return FutureBuilder<List<Product>>(
      future: service.fetchAll(),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: \${snap.error}'));
        final products = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (c, i) => ProductTile(product: products[i]),
        );
      },
    );
  }
}
