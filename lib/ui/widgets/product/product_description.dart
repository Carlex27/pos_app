import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml
import 'package:pos_app/ui/widgets/product/product_inventory_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/product/product.dart';
import '../../../config.dart';
import 'edit_product_form.dart';
import '../../../services/product_service.dart';

// Puede ser útil tener un enum para los resultados, o usar Strings como se muestra
// enum ProductDescriptionResult { updated, deleted, noChange }

class ProductDescription extends StatefulWidget { // <--- CAMBIO: StatefulWidget
  final Product product;
  // Opcional: Callback
  // final Function(ProductDescriptionResult result)? onActionCompleted;

  const ProductDescription({
    Key? key,
    required this.product,
    // this.onActionCompleted,
  }) : super(key: key);

  @override
  State<ProductDescription> createState() => _ProductDescriptionState(); // <--- CAMBIO
}

class _ProductDescriptionState extends State<ProductDescription> { // <--- NUEVA CLASE DE ESTADO
  // Variables de estado para el costo de inventario
  double? _costoInventario;
  bool _isLoadingCosto = true;
  String? _errorCosto;
  late ProductService _productService;
  late Product _currentProduct; // Para manejar actualizaciones del producto

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product; // Inicializar con el producto pasado
    // Es mejor obtener el Provider en didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productService = Provider.of<ProductService>(context, listen: false);
    // Solo llama a fetch si el producto es el mismo o si el ID es válido
    // (en caso de que el producto pudiera cambiar y necesitar un nuevo fetch)
    if (_currentProduct.id != null) {
      _fetchCostoInventario(_currentProduct.id!);
    } else {
      setState(() {
        _isLoadingCosto = false;
        _errorCosto = 'ID del producto no disponible para obtener costo.';
      });
    }
  }

  Future<String> _getImageUrl(String path) async {
    final baseUrl = await getApiBaseUrl();
    return path.isNotEmpty ? '$baseUrl$path' : '$baseUrl/images/default.png';
  }

  // Método para manejar la edición
  Future<void> _handleEdit(BuildContext pageContext) async {
    final result = await showDialog<Product?>( // EditProductForm ahora puede devolver el Product actualizado
      context: pageContext,
      barrierDismissible: false,
      builder: (dialogContext) => EditProductForm(
        product: _currentProduct, // Pasa el producto actual del estado
      ),
    );

    if (result is Product) { // Si se devolvió un producto actualizado
      setState(() {
        _currentProduct = result; // Actualiza el producto en el estado local
      });
      // Opcionalmente, notifica a la pantalla anterior que hubo una actualización general
      // Navigator.of(pageContext).pop("updated");
      // Si quieres que la pantalla anterior también se actualice con el objeto Product específico:
      // Navigator.of(pageContext).pop(result);
      // Para este ejemplo, solo actualizamos localmente y notificamos "updated"
      if (Navigator.of(pageContext).canPop()) {
        Navigator.of(pageContext).pop("updated");
      }
    } else if (result == true) { // Manejo legado si EditProductForm devuelve bool
      if (Navigator.of(pageContext).canPop()) {
        Navigator.of(pageContext).pop("updated");
      }
    }
  }

  Future<void> _fetchCostoInventario(int productId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingCosto = true;
      _errorCosto = null;
      _costoInventario = null;
    });

    try {
      final costo = await _productService.getCostoInventarioPorProducto(productId);
      if (mounted) {
        setState(() {
          _costoInventario = costo;
          _isLoadingCosto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorCosto = 'Error al cargar costo: ${e.toString()}';
          _isLoadingCosto = false;
        });
      }
      print('Error fetching costo inventario para ID $productId: $e');
    }
  }

  // Método para manejar la eliminación
  void _showDeleteDialog(BuildContext pageContext) {
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
          '¿Estás seguro de que quieres eliminar "${_currentProduct.nombre}"?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
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
              final scaffoldMessenger = ScaffoldMessenger.of(pageContext);
              final mainNavigator = Navigator.of(pageContext);
              final dialogNavigator = Navigator.of(dialogContext);

              try {
                // USA _currentProduct.id
                await _productService.delete(_currentProduct.id!);

                if (dialogNavigator.canPop()) dialogNavigator.pop();

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Producto "${_currentProduct.nombre}" eliminado correctamente'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );

                await Future.delayed(const Duration(milliseconds: 1500));

                if (mainNavigator.canPop()) mainNavigator.pop("deleted");

              } catch (e) {
                if (dialogNavigator.canPop()) dialogNavigator.pop();
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showProductInventoryModal(BuildContext pageContext) { // pageContext es el context del Scaffold
    if (_currentProduct.id == null) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        const SnackBar(content: Text('ID del producto no disponible.')),
      );
      return;
    }

    showModalBottomSheet(
      context: pageContext, // Usa el contexto que tiene acceso al Navigator del Scaffold
      isScrollControlled: true, // Permite que el contenido determine la altura
      backgroundColor: Colors.transparent, // El color lo define el Container interno
      shape: const RoundedRectangleBorder( // Redondea las esquinas superiores del modal en sí
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalBuilderContext) { // Un nuevo contexto para el contenido del modal
        return DraggableScrollableSheet(
          initialChildSize: 0.65, // Altura inicial (65% de la pantalla)
          minChildSize: 0.3,    // Altura mínima al arrastrar hacia abajo
          maxChildSize: 0.9,    // Altura máxima al arrastrar hacia arriba
          expand: false, // Importante para que funcione dentro de showModalBottomSheet
          builder: (_, scrollController) {
            // El scrollController de DraggableScrollableSheet puede ser pasado
            // al ListView dentro de ProductInventoryWidget si es necesario,
            // aunque usualmente el ListView interno maneja su propio scroll.
            // Para este caso, ProductInventoryWidget ya tiene un ListView interno
            // que se expandirá.
            return Container(
              // El Container ya no necesita decoration si el shape del showModalBottomSheet lo maneja,
              // a menos que quieras un color de fondo diferente al del canvas del tema.
              // Si ProductInventoryWidget tiene su propio Padding, puedes quitar el Padding aquí.
              child: ProductInventoryWidget(
                productId: _currentProduct.id!,
                productService: _productService, // Pasas la instancia del servicio
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageContext = context; // Para usar en los diálogos
    final currencyFormatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProduct.nombre), // Usa _currentProduct
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _handleEdit(pageContext),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(pageContext),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            FutureBuilder<String>(
              future: _getImageUrl(_currentProduct.imagePath), // Usa _currentProduct
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildPlaceholder();
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

            _buildRow('SKU', _currentProduct.SKU),
            _buildRow('Nombre', _currentProduct.nombre),
            _buildRow('Departamento', _currentProduct.departamento),
            _buildRow('Precio Costo', currencyFormatter.format(_currentProduct.precioCosto)),
            _buildRow('Precio Venta', currencyFormatter.format(_currentProduct.precioVenta)),
            _buildRow('Precio Mayoreo', currencyFormatter.format(_currentProduct.precioMayoreo)),
            _buildRow('Precio Unidad Venta', currencyFormatter.format(_currentProduct.precioUnidadVenta)),
            _buildRow('Precio Unidad Mayoreo', currencyFormatter.format(_currentProduct.precioUnidadMayoreo)),
            _buildRow('Unidades por Presentación', '${_currentProduct.unidadesPorPresentacion}'),
            _buildRow('Stock Total (por presentación)', '${_currentProduct.stock}'),
            _buildRow('Stock por Unidad', '${_currentProduct.stockPorUnidad}'),
            _buildRow('Stock Mínimo', '${_currentProduct.stockMinimo}'),
            _buildRow('Mínimo Mayoreo', '${_currentProduct.minimoMayoreo}'),

            const SizedBox(height: 20),

            // Costo de inventario (AHORA CON LÓGICA)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Costo de Inventario del Producto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoadingCosto)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
                        SizedBox(width: 12),
                        Text('Calculando costo...', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    )
                  else if (_errorCosto != null)
                    Text(_errorCosto!, style: const TextStyle(fontSize: 14, color: Colors.redAccent))
                  else if (_costoInventario != null)
                      Text(
                        currencyFormatter.format(_costoInventario),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700, // Un color diferente para destacar
                        ),
                      )
                    else
                      const Text('No disponible.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Ver Entradas de Inventario'),
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.teal, // Puedes personalizar el color
                // foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              onPressed: () {
                // Llama al método para mostrar el modal, usando el 'context' del build
                _showProductInventoryModal(context);
              },
            ),
            const SizedBox(height: 24),
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
              // overflow: TextOverflow.ellipsis, // Considera si quieres ellipsis
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
      child: Center(
        child: Icon(Icons.image_outlined, size: 60, color: Colors.grey.shade400),
      ),
    );
  }
}