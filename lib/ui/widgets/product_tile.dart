import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../config.dart';
import 'edit_product_form.dart';
import '../../services/product_service.dart';
import 'package:provider/provider.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({
    Key? key,
    required this.product,
  }) : super(key: key);

  Future<String> imageUrl(String? imagePath) async {
    final baseUrl = await getApiBaseUrl();
    if (imagePath == null || imagePath.isEmpty) {
      return '$baseUrl/images/default.png'; // o lo que corresponda
    }
    return '$baseUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen del producto desde el backend
          FutureBuilder<String>(
            future: imageUrl(product.imagePath), // función que incluye await getApiBaseUrl()
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _placeholder(); // puedes mostrar un spinner o una imagen de carga
              } else if (snapshot.hasError || !snapshot.hasData) {
                return _placeholder(); // error o sin datos
              } else {
                return Image.network(
                  snapshot.data!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                );
              }
            },
          ),

          const SizedBox(width: 16),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del producto
                Text(
                  product.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                // SKU
                Text(
                  'SKU: ${product.SKU}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                // Marca - Tamaño
                Text(
                  '${product.marca} - ${product.tamanio}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 8),

                // Precio y Stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.precioNormal.toStringAsFixed(2)} - ${product.precioMayoreo.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Botones de acción
          Column(
            children: [
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => EditProductForm(product: product),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showDeleteDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Estás seguro de que quieres eliminar "${product.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final productService = Provider.of<ProductService>(context, listen: false);
                await productService.delete(product.id); // ← Aquí usamos el ID del producto

                Navigator.of(context).pop(); // Cierra el diálogo de confirmación

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto "${product.nombre}" eliminado correctamente'),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar el producto: $e'),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
