import 'package:flutter/material.dart';
import '../../../models/product/product.dart';
import '../../../config.dart';

class ProductDescription extends StatelessWidget {
  final Product product;

  const ProductDescription({
    Key? key,
    required this.product,
  }) : super(key: key);

  Future<String> _getImageUrl(String path) async {
    final baseUrl = await getApiBaseUrl();
    return path.isNotEmpty ? '$baseUrl$path' : '$baseUrl/images/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
