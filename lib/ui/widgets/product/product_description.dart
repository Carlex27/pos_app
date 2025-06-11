import 'package:flutter/material.dart';
import '../../../models/product/product.dart';
import '../../../config.dart';
import 'edit_product_form.dart';
import '../../../services/product_service.dart';
import 'package:provider/provider.dart';

// Puede ser útil tener un enum para los resultados, o usar Strings como se muestra
// enum ProductDescriptionResult { updated, deleted, noChange }

class ProductDescription extends StatelessWidget {
  final Product product;
  // Opcional: Callback para no depender solo del valor de retorno de pop,
  // pero para este caso, pop con valor es suficiente.
  // final Function(ProductDescriptionResult result)? onActionCompleted;

  const ProductDescription({
    Key? key,
    required this.product,
    // this.onActionCompleted,
  }) : super(key: key);

  Future<String> _getImageUrl(String path) async {
    final baseUrl = await getApiBaseUrl();
    return path.isNotEmpty ? '$baseUrl$path' : '$baseUrl/images/default.png';
  }

  // Método para manejar la edición
  Future<void> _handleEdit(BuildContext pageContext) async { // pageContext es el context del Scaffold
    final result = await showDialog<bool>( // EditProductForm devuelve true si hay cambios
      context: pageContext,
      barrierDismissible: false, // Opcional, considera si el usuario puede descartar
      builder: (dialogContext) => EditProductForm(
        product: product, // Pasa el producto actual
      ),
    );

    if (result == true) {
      // Si EditProductForm indicó éxito (pop(true)), entonces esta pantalla
      // debe "regresar" a la anterior indicando que hubo una actualización.
      // La pantalla anterior (ej: ProductsScreen) deberá hacer un fetch.
      //
      // Es importante notar que ProductDescription es un StatelessWidget.
      // Para ver los cambios *dent 소비자를 en esta misma pantalla de descripción* después de editar,
      // necesitarías convertir ProductDescription a StatefulWidget y recargar sus propios datos,
      // o que EditProductForm devuelva el producto actualizado y usarlo.
      //
      // Para el caso de simplemente notificar a la pantalla anterior, pop("updated") es suficiente.
      if (Navigator.of(pageContext).canPop()) {
        Navigator.of(pageContext).pop("updated"); // Notifica que algo se actualizó
      }
    }
  }


  // Método para manejar la eliminación
  void _showDeleteDialog(BuildContext pageContext) { // pageContext es el context del Scaffold
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Eliminar producto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${product.nombre}"?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(), // Cierra solo el AlertDialog
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Guardar referencias ANTES de operaciones async
              final scaffoldMessenger = ScaffoldMessenger.of(pageContext);
              final mainNavigator = Navigator.of(pageContext); // Navigator de ProductDescription
              final dialogNavigator = Navigator.of(dialogContext); // Navigator del AlertDialog

              try {
                final productService = Provider.of<ProductService>(pageContext, listen: false);
                await productService.delete(product.id);

                // 1. Cierra el AlertDialog
                if (dialogNavigator.canPop()) {
                  dialogNavigator.pop();
                }

                // 2. Muestra el SnackBar en el Scaffold de ProductDescription
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Producto "${product.nombre}" eliminado correctamente'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );

                // Espera un momento para que el usuario vea el SnackBar
                await Future.delayed(const Duration(milliseconds: 1500));


                // 3. Cierra ProductDescription y devuelve "deleted"
                if (mainNavigator.canPop()) {
                  mainNavigator.pop("deleted");
                }

              } catch (e) {
                // 1. Cierra el AlertDialog si aún está abierto
                if (dialogNavigator.canPop()) {
                  dialogNavigator.pop();
                }

                // 2. Muestra el SnackBar de error
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Error al eliminar el producto: $e')),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Es importante que el `context` usado para los diálogos y navegación
    // sea el context del Scaffold de esta página (`ProductDescription`).
    final pageContext = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre), // Considera actualizar esto si el producto se edita y ProductDescription es StatefulWidget
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _handleEdit(pageContext); // Llama al método de manejo de edición
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(pageContext), // Pasa el context del Scaffold
          ),
        ],
      ),
      body: Padding(
        // ... (el resto de tu widget ListView no cambia)
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Imagen del producto
            FutureBuilder<String>(
              future: _getImageUrl(product.imagePath),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildPlaceholder();
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    snapshot.data!,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            _buildRow('SKU', product.SKU),
            _buildRow('Nombre', product.nombre),
            _buildRow('Departamento', product.departamento),
            _buildRow('Precio Costo', '\$${product.precioCosto.toStringAsFixed(2)}'),
            _buildRow('Precio Venta', '\$${product.precioVenta.toStringAsFixed(2)}'),
            _buildRow('Precio Mayoreo', '\$${product.precioMayoreo.toStringAsFixed(2)}'),
            _buildRow('Precio Unidad Venta', '\$${product.precioUnidadVenta.toStringAsFixed(2)}'),
            _buildRow('Precio Unidad Mayoreo', '\$${product.precioUnidadMayoreo.toStringAsFixed(2)}'),
            _buildRow('Unidades por Presentación', '${product.unidadesPorPresentacion}'),
            _buildRow('Stock Total (por presentación)', '${product.stock}'),
            _buildRow('Stock por Unidad', '${product.stockPorUnidad}'),
            _buildRow('Stock Mínimo', '${product.stockMinimo}'),
            _buildRow('Mínimo Mayoreo', '${product.minimoMayoreo}'),

            const SizedBox(height: 20),

            // Costo de inventario (placeholder)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Costo de Inventario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Este valor se actualizará próximamente...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.grey),
      ),
    );
  }
}