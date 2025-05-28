import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/product_service.dart';
import '../widgets/product_tile.dart';
import '../../models/product.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext ctx) {
    final service = Provider.of<ProductService>(ctx, listen: false);
    return FutureBuilder<List<Product>>(
      future: service.fetchAll(),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final products = snap.data!;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (c, i) => ProductTile(
            product: products[i],
            onTap: () { /* navegar a detalle */ },
          ),
        );
      },
    );
  }
}