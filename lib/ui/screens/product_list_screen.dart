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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Productos',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Lista de productos
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: service.fetchAll(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snap.hasError) {
                    debugPrint('ERROR EN PRODUCTS: ${snap.error}');
                    return Center(
                      child: Text(
                        'Error: ${snap.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final products = snap.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // deja espacio para botones flotantes
                    itemCount: products.length,
                    itemBuilder: (c, i) => ProductTile(product: products[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Botones flotantes
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50), // deja espacio arriba del bottom nav
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón Alta Mercancía
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  print('Alta Mercancía');
                },
                icon: Icon(Icons.fire_truck, size: 18, color: Colors.green.shade600),
                label: Text(
                  'Alta Mercancía',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.green.shade400),
                  ),
                ),
              ),
            ),

            // Botón Agregar
            ElevatedButton.icon(
              onPressed: () {
                print('Agregar producto');
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Agregar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
