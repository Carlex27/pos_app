import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml
import 'package:pos_app/ui/widgets/product/product_inventory_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/product/product.dart';
import '../../../config.dart';
import 'edit_product_form.dart';
import '../../../services/product_service.dart';

class ProductDescription extends StatefulWidget {
  final Product product;

  const ProductDescription({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  // Variables de estado para el costo de inventario
  double? _costoInventario;
  bool _isLoadingCosto = true;
  String? _errorCosto;
  late ProductService _productService;
  late Product _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productService = Provider.of<ProductService>(context, listen: false);
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

  Future<void> _handleEdit(BuildContext pageContext) async {
    final result = await showDialog<Product?>(
      context: pageContext,
      barrierDismissible: false,
      builder: (dialogContext) => EditProductForm(
        product: _currentProduct,
      ),
    );

    if (result is Product) {
      setState(() {
        _currentProduct = result;
      });
      if (Navigator.of(pageContext).canPop()) {
        Navigator.of(pageContext).pop("updated");
      }
    } else if (result == true) {
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Eliminar producto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8D4E2A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${_currentProduct.nombre}"?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(pageContext);
              final mainNavigator = Navigator.of(pageContext);
              final dialogNavigator = Navigator.of(dialogContext);

              try {
                await _productService.delete(_currentProduct.id!);

                if (dialogNavigator.canPop()) dialogNavigator.pop();

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Producto "${_currentProduct.nombre}" eliminado correctamente'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 2),
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
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showProductInventoryModal(BuildContext pageContext) {
    if (_currentProduct.id == null) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(
          content: const Text('ID del producto no disponible.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalBuilderContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              child: ProductInventoryWidget(
                productId: _currentProduct.id!,
                productService: _productService,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageContext = context;
    final currencyFormatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _currentProduct.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFFFB74D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _handleEdit(pageContext),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(pageContext),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen del producto
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Imagen del producto
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FutureBuilder<String>(
                        future: _getImageUrl(_currentProduct.imagePath),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return _buildPlaceholder();
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              snapshot.data!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nombre del producto
                    Text(
                      _currentProduct.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8D4E2A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // SKU destacado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFB74D).withOpacity(0.2),
                            const Color(0xFFFF8A65).withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_outlined,
                            size: 16,
                            color: const Color(0xFF8D4E2A),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SKU: ${_currentProduct.SKU}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8D4E2A),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Información General
            _buildInfoSection(
              'Información General',
              Icons.info_outline,
              [
                _buildInfoRow('Departamento', _currentProduct.departamento, Icons.category_outlined),
                _buildInfoRow('Stock Total', '${_currentProduct.stock} presentaciones', Icons.inventory_outlined),
                _buildInfoRow('Stock por Unidad', '${_currentProduct.stockPorUnidad} unidades', Icons.inventory_2_outlined),
                _buildInfoRow('Stock Mínimo', '${_currentProduct.stockMinimo}', Icons.warning_amber_outlined),
                _buildInfoRow('Unidades por Presentación', '${_currentProduct.unidadesPorPresentacion}', Icons.view_module_outlined),
                _buildInfoRow('Mínimo Mayoreo', '${_currentProduct.minimoMayoreo}', Icons.shopping_cart_outlined),
              ],
            ),

            const SizedBox(height: 24),

            // Precios
            _buildInfoSection(
              'Precios',
              Icons.attach_money_outlined,
              [
                _buildPriceRow('Precio Costo', _currentProduct.precioCosto, currencyFormatter, Colors.red.shade400),
                _buildPriceRow('Precio Venta', _currentProduct.precioVenta, currencyFormatter, Colors.green.shade400),
                _buildPriceRow('Precio Mayoreo', _currentProduct.precioMayoreo, currencyFormatter, Colors.blue.shade400),
                _buildPriceRow('Precio Unidad Venta', _currentProduct.precioUnidadVenta, currencyFormatter, Colors.green.shade400),
                _buildPriceRow('Precio Unidad Mayoreo', _currentProduct.precioUnidadMayoreo, currencyFormatter, Colors.blue.shade400),
              ],
            ),

            const SizedBox(height: 24),

            // Costo de Inventario
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFB74D).withOpacity(0.1),
                    const Color(0xFFFF8A65).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFFB74D).withOpacity(0.8),
                                const Color(0xFFFF8A65).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB74D).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Costo Total de Inventario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8D4E2A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingCosto)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Calculando costo...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                    else if (_errorCosto != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorCosto!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_costoInventario != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            currencyFormatter.format(_costoInventario),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8D4E2A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No disponible.',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón de inventario
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showProductInventoryModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list_alt_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Ver Entradas de Inventario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFB74D).withOpacity(0.8),
                        const Color(0xFFFF8A65).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB74D).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8D4E2A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, NumberFormat formatter, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.attach_money,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatter.format(price),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}