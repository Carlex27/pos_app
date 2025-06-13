import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product/product.dart';
import '../../../models/product/alta_product.dart';
import '../../../services/product_service.dart';

class AltaProductWidget extends StatefulWidget {
  const AltaProductWidget({Key? key}) : super(key: key);

  @override
  State<AltaProductWidget> createState() => _AltaProductWidgetState();
}

class _AltaProductWidgetState extends State<AltaProductWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<TextEditingController> _precioCostoControllers = [];
  final List<TextEditingController> _cantidadControllers = [];


  final List<AltaProduct> _altaList = [];
  List<Product> _suggestions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  double _precioCosto = 1;
  int _cantidad = 1;



  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions.clear());
      return;
    }
    final service = Provider.of<ProductService>(context, listen: false);
    final result = await service.search(query);
    setState(() => _suggestions = result);
  }

  void _addToAltaList(Product product) {
    final alreadyExists = _altaList.any((p) => p.sku == product.SKU);
    if (alreadyExists) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Este producto ya fue agregado'),
            backgroundColor: Colors.orange.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
    } else {
      setState(() {
        final nuevoAltaProduct = AltaProduct(
          sku: product.SKU,
          nombre: product.nombre,
          stock: product.stock,
          cantidad: _cantidad, // Usa el _cantidad inicial del estado
          precioCosto: _precioCosto, // Usa el _precioCosto inicial del estado
        );
        _altaList.add(nuevoAltaProduct);

        // NUEVO: Crear y añadir controladores para el nuevo item
        final precioController = TextEditingController(text: nuevoAltaProduct.precioCosto.toStringAsFixed(2));
        final cantidadController = TextEditingController(text: nuevoAltaProduct.cantidad.toString());

        // Escuchar cambios en estos controladores para actualizar _altaList
        precioController.addListener(() {
          final newPriceText = precioController.text;
          final parsedPrice = double.tryParse(newPriceText);
          // Encuentra el índice del producto al que pertenece este controlador
          // Esto puede ser un poco frágil si los controladores y _altaList se desincronizan.
          // Una mejor manera sería tener un mapa de SKU a controladores o un objeto que contenga
          // tanto el AltaProduct como sus controladores.
          // Por ahora, asumimos que los índices coinciden.
          final index = _precioCostoControllers.indexOf(precioController);
          if (index != -1 && parsedPrice != null && parsedPrice >= 0 && _altaList[index].precioCosto != parsedPrice) {
            // No llames a setState aquí directamente para evitar reconstrucciones excesivas
            // Actualiza el modelo directamente. setState se llamará desde los onChanged de los TextFormField si es necesario.
            // O, si prefieres, llama a setState pero ten cuidado con los bucles.
            // La actualización directa del modelo es más limpia si el controlador ya refleja el cambio.
            _altaList[index] = _altaList[index].copyWith(precioCosto: parsedPrice);
          }
        });

        cantidadController.addListener(() {
          final newQtyText = cantidadController.text;
          final parsedQty = int.tryParse(newQtyText);
          final index = _cantidadControllers.indexOf(cantidadController);
          if (index != -1 && parsedQty != null && parsedQty > 0 && _altaList[index].cantidad != parsedQty) {
            _altaList[index] = _altaList[index].copyWith(cantidad: parsedQty);
            // También actualiza el texto del controlador de "Nuevo Stock" si lo tienes separado.
            // Esto se hace más fácil si el cálculo del nuevo stock está en el builder.
            // Es importante llamar a setState si el "Nuevo Stock" depende de esto y no se reconstruye solo.
            // Por ahora, el builder se encarga de esto.
          }
        });

        _precioCostoControllers.add(precioController);
        _cantidadControllers.add(cantidadController);

        _suggestions.clear();
        _searchController.clear();
      });
    }
  }
  // NUEVO: Método para quitar controladores cuando se elimina un item
  void _removeFromAltaList(int index) {
    setState(() {
      _altaList.removeAt(index);

      // Liberar y quitar los controladores correspondientes
      _precioCostoControllers[index].dispose();
      _precioCostoControllers.removeAt(index);

      _cantidadControllers[index].dispose();
      _cantidadControllers.removeAt(index);
    });
  }

  void _submitAltaList() async {
    if (_altaList.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ProductService>(context, listen: false);
      await service.sendAltaProductos(_altaList);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Productos enviados con éxito'),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() => _altaList.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int get _totalUnidades {
    return _altaList.fold(0, (sum, item) => sum + item.cantidad);
  }

  @override
  void dispose() {
    _searchController.dispose();
    // NUEVO: Liberar todos los controladores de la lista
    for (var controller in _precioCostoControllers) {
      controller.dispose();
    }
    for (var controller in _cantidadControllers) {
      controller.dispose();
    }
    _precioCostoControllers.clear();
    _cantidadControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Alta de Mercancía',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFFFB74D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header con icono y descripción elegante
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icono con gradiente como en EditProductForm
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFB74D).withOpacity(0.8),
                        const Color(0xFFFF8A65).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB74D).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Busca productos por SKU y agrega las cantidades recibidas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de búsqueda con diseño mejorado
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Buscar Producto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8D4E2A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Campo de búsqueda mejorado
                          TextFormField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Ingresa SKU o nombre del producto...',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFFB74D),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onChanged: (value) {
                              _searchQuery = value;
                              _onSearchChanged(_searchQuery);
                            },
                          ),

                          // Sugerencias de búsqueda mejoradas
                          if (_suggestions.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                ),
                                itemBuilder: (context, index) {
                                  final p = _suggestions[index];
                                  return ListTile(
                                    title: Text(
                                      p.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'SKU: ${p.SKU} ',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB74D),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    onTap: () => _addToAltaList(p),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sección de productos seleccionados
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Productos Seleccionados',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8D4E2A),
                                ),
                              ),
                              if (_altaList.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB74D),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_altaList.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),

                          _altaList.isEmpty
                              ? Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay productos seleccionados',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Busca y selecciona productos para agregar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _altaList.length,
                            itemBuilder: (context, index) {
                              final item = _altaList[index];
                              final precioController = _precioCostoControllers[index];
                              final cantidadController = _cantidadControllers[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header con nombre y botón eliminar
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.nombre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.red.shade200),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.red.shade400,
                                                size: 16,
                                              ),
                                              onPressed: () => setState(() => _altaList.removeAt(index)),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Información del producto
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.qr_code_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'SKU: ${item.sku}',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.inventory_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Stock: ${item.stock}',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Campo de cantidad simplificado
                                      Row(
                                        children: [
                                          Text(
                                            'Precio Costo:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            width: 80,
                                            child: TextFormField(
                                              controller: precioController,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              decoration: InputDecoration(
                                                prefixText: '\$ ',
                                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(color: Color(0xFFFFB74D), width: 2),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              onChanged: (value) {
                                                final parsed = double.tryParse(value);
                                                if (parsed != null && parsed >= 0) { // Permitir 0 si es válido
                                                  setState(() {
                                                    _altaList[index] = _altaList[index].copyWith(precioCosto: parsed);
                                                  });
                                                }
                                              },

                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text(
                                            'Cantidad a agregar:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            width: 80,
                                            child: TextFormField(
                                              controller: cantidadController,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(color: Color(0xFFFFB74D), width: 2),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              onChanged: (value) {
                                                final parsed = int.tryParse(value);
                                                if (parsed != null && parsed > 0) {
                                                  setState(() {
                                                    // Actualiza el item específico en la lista
                                                    _altaList[index] = _altaList[index].copyWith(cantidad: parsed);
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),


                                      const SizedBox(height: 12),
                                      // Nuevo stock destacado
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.trending_up,
                                              size: 16,
                                              color: Colors.green.shade600,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Nuevo stock: ${item.stock + item.cantidad}',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_altaList.isNotEmpty) const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Footer mejorado
          if (_altaList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total de unidades con diseño mejorado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFB74D).withOpacity(0.1),
                          const Color(0xFFFF8A65).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_box_outlined,
                          color: const Color(0xFFFFB74D),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Total: $_totalUnidades unidades',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8D4E2A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón de confirmación mejorado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitAltaList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB74D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Procesando...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Confirmar Alta (${_altaList.length} producto${_altaList.length != 1 ? 's' : ''})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}