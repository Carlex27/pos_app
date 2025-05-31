import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../config.dart';
import 'edit_product_form.dart';
import '../../services/product_service.dart';
import 'package:provider/provider.dart';

class ProductTile extends StatefulWidget {
  final Product product;

  const ProductTile({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> imageUrl(String? imagePath) async {
    final baseUrl = await getApiBaseUrl();
    if (imagePath == null || imagePath.isEmpty) {
      return '$baseUrl/images/default.png';
    }
    return '$baseUrl$imagePath';
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPressed ? Colors.blue.shade200 : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? Colors.blue.withOpacity(0.15)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: _isPressed ? 15 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header con imagen y acciones
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen del producto mejorada
                            _buildProductImage(),

                            const SizedBox(width: 16),

                            // Información principal
                            Expanded(child: _buildProductInfo()),

                            const SizedBox(width: 12),

                            // Botones de acción mejorados
                            _buildActionButtons(),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Footer con precios y stock
                        _buildFooterInfo(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FutureBuilder<String>(
          future: imageUrl(widget.product.imagePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildImagePlaceholder(isLoading: true);
            } else if (snapshot.hasError || !snapshot.hasData) {
              return _buildImagePlaceholder();
            } else {
              return Image.network(
                snapshot.data!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({bool isLoading = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
        ),
      ),
      child: isLoading
          ? Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
          ),
        ),
      )
          : Icon(
        Icons.inventory_2_outlined,
        color: Colors.grey.shade600,
        size: 32,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del producto
        Text(
          widget.product.nombre,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        // SKU con badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Text(
            'SKU: ${widget.product.SKU}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Marca y tamaño
        Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${widget.product.marca} • ${widget.product.tamanio}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón editar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.shade200,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => EditProductForm(product: widget.product),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              Icons.edit_outlined,
              size: 18,
              color: Colors.green.shade600,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Botón eliminar
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDeleteDialog(context),
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Precios
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precios',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Precio normal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '\$${widget.product.precioNormal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Precio mayoreo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '\$${widget.product.precioMayoreo.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divisor
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),

          const SizedBox(width: 16),

          // Stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventario',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getStockColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getStockIcon(),
                        size: 16,
                        color: _getStockColor(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.product.stock}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _getStockColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor() {
    if (widget.product.stock <= 5) return Colors.red.shade600;
    if (widget.product.stock <= 15) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  IconData _getStockIcon() {
    if (widget.product.stock <= 5) return Icons.warning_outlined;
    if (widget.product.stock <= 15) return Icons.info_outlined;
    return Icons.check_circle_outlined;
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          '¿Estás seguro de que quieres eliminar "${widget.product.nombre}"?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
              try {
                final productService = Provider.of<ProductService>(context, listen: false);
                await productService.delete(widget.product.id);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Producto "${widget.product.nombre}" eliminado correctamente'),
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
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
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
}