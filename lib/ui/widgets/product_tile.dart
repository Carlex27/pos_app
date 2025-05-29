import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({
    Key? key,
    required this.product,
  }) : super(key: key);

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
          // Imagen del producto (placeholder gris)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            // Aquí puedes agregar la imagen más adelante
            // child: ClipRRect(
            //   borderRadius: BorderRadius.circular(8),
            //   child: Image.network(
            //     product.imageUrl,
            //     fit: BoxFit.cover,
            //   ),
            // ),
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

                Text(
                  'SKU: ${product.SKU}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),

                // Marca - Tipo
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
                    // Precio
                    Text(
                      '\$${product.precioNormal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),

                    // Stock
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
              // Botón editar
              InkWell(
                onTap: () {
                  // Aquí puedes agregar la lógica para editar
                  print('Editar producto: ${product.nombre}');
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

              // Botón eliminar
              InkWell(
                onTap: () {
                  // Aquí puedes agregar la lógica para eliminar
                  _showDeleteDialog(context);
                },
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Estás seguro de que quieres eliminar "${product.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí agregas la lógica para eliminar el producto
                print('Producto eliminado: ${product.nombre}');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}