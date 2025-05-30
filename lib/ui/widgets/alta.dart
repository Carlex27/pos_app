import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/alta_product.dart';
import '../../services/product_service.dart';

class AltaProductWidget extends StatefulWidget {
  const AltaProductWidget({Key? key}) : super(key: key);

  @override
  State<AltaProductWidget> createState() => _AltaProductWidgetState();
}

class _AltaProductWidgetState extends State<AltaProductWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<AltaProduct> _altaList = [];
  List<Product> _suggestions = [];
  bool _isLoading = false;
  String _searchQuery = '';

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
        _altaList.add(
          AltaProduct(
            sku: product.SKU,
            nombre: product.nombre,
            stock: product.stock,
          ),
        );
        _suggestions.clear();
        _searchController.clear();
      });
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // SOLUCIÓN 1: Configurar resizeToAvoidBottomInset
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Alta de Mercancía',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header con descripción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Busca productos por SKU y agrega las cantidades recibidas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // SOLUCIÓN 2: Envolver el contenido principal en Flexible en lugar de Expanded
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y campo de búsqueda
                  const Text(
                    'Buscar por SKU o Nombre',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campo de búsqueda
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Ej: COR001, MOD001...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
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
                          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _onSearchChanged(_searchQuery);
                      },
                    ),
                  ),

                  // Sugerencias de búsqueda
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey.shade100,
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
                              'SKU: ${p.SKU} | ${p.marca} - ${p.tamanio}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () => _addToAltaList(p),
                            shape: RoundedRectangleBorder(
                              borderRadius: index == 0
                                  ? const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              )
                                  : index == _suggestions.length - 1
                                  ? const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              )
                                  : BorderRadius.zero,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Título de productos seleccionados
                  const Text(
                    'Productos Seleccionados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lista de productos seleccionados
                  // SOLUCIÓN 3: Usar constraints y shrinkWrap en lugar de Expanded
                  _altaList.isEmpty
                      ? Container(
                    height: 200, // Altura fija para el estado vacío
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
                    shrinkWrap: true, // IMPORTANTE: Permite que el ListView se ajuste al contenido
                    physics: const NeverScrollableScrollPhysics(), // Evita conflictos de scroll
                    itemCount: _altaList.length,
                    itemBuilder: (context, index) {
                      final item = _altaList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
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
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red.shade400,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _altaList.removeAt(index)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                              ),

                              // Información del producto
                              Text(
                                'SKU: ${item.sku} | Stock actual: ${item.stock}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Controles de cantidad
                              Row(
                                children: [
                                  // Botón decrementar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: IconButton(
                                      onPressed: item.cantidad > 1
                                          ? () => setState(() => item.cantidad--)
                                          : null,
                                      icon: const Icon(Icons.remove, size: 18),
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                    ),
                                  ),

                                  // Campo de cantidad
                                  Container(
                                    width: 60,
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    child: TextFormField(
                                      initialValue: item.cantidad.toString(),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        final parsed = int.tryParse(value);
                                        if (parsed != null && parsed > 0) {
                                          setState(() => item.cantidad = parsed);
                                        }
                                      },
                                    ),
                                  ),

                                  // Botón incrementar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: IconButton(
                                      onPressed: () => setState(() => item.cantidad++),
                                      icon: const Icon(Icons.add, size: 18),
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Nuevo stock
                              Text(
                                'Nuevo stock: ${item.stock + item.cantidad}',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Espaciado adicional para evitar que el contenido quede muy pegado al footer
                  if (_altaList.isNotEmpty) const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Footer con total y botón
          if (_altaList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // IMPORTANTE: Ajusta al contenido mínimo
                children: [
                  // Total de unidades
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Total de unidades a agregar: $_totalUnidades',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón de envío
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitAltaList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          const Text('Enviando...'),
                        ],
                      )
                          : Text(
                        'Confirmar Alta de Mercancía (${_altaList.length} producto${_altaList.length != 1 ? 's' : ''})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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