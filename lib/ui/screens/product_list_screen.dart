// En product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:pos_app/ui/widgets/product/alta.dart';
import 'package:pos_app/ui/widgets/product/new_product.dart';
import 'package:provider/provider.dart';
import '../../services/product_service.dart';
import '../../models/product/product.dart';
import '../widgets/product/product_tile.dart';
import 'package:intl/intl.dart'; // Para formatear moneda

/// Pantalla de listado de productos
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  double? _totalInventoryCost; // <--- NUEVO ESTADO para el costo del inventario
  String? _inventoryCostError; // <--- NUEVO ESTADO para errores del costo

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$'); // Formateador de moneda

  @override
  void initState() {
    super.initState();
    _fetchData(); // Cambiamos el nombre para reflejar que carga más que solo productos
  }

  // Función para cargar tanto productos como el costo del inventario
  Future<void> _fetchData([String query = '']) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _inventoryCostError = null; // Resetea el error
      if (query.isEmpty) { // Solo resetea el costo si no es una búsqueda (para que no desaparezca al buscar)
        _totalInventoryCost = null;
      }
    });

    try {
      final service = Provider.of<ProductService>(context, listen: false);

      // 1. Obtener productos
      final products = query.isEmpty
          ? await service.fetchAll()
          : await service.search(query);

      if (!mounted) return;
      setState(() {
        _filteredProducts = products;
      });

      // 2. Obtener el costo total del inventario (solo si no es una búsqueda o si aún no se ha cargado)
      //    O puedes decidir cargarlo siempre. Depende de tu lógica deseada.
      //    Aquí lo cargamos si `_totalInventoryCost` es null, para no llamarlo en cada búsqueda.
      if (_totalInventoryCost == null && query.isEmpty) { // Solo si no es búsqueda y no está cargado
        try {
          final cost = await service.getCostoInventarioTotal();
          if (mounted) {
            setState(() {
              _totalInventoryCost = cost;
            });
          }
        } catch (e) {
          debugPrint('Error fetching total inventory cost: $e');
          if (mounted) {
            setState(() {
              _inventoryCostError = 'Error al cargar costo';
            });
          }
        }
      }

      debugPrint('Productos encontrados (${products.length}): $query');

    } catch (e) {
      debugPrint('Error fetching products: $e');
      if (mounted) {
        setState(() {
          // Considera si quieres un error específico para productos también
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _openNewProductForm() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const NewProductForm();
      },
    );

    if (result == true && mounted) {
      _fetchData(); // Llama a _fetchData para recargar todo (productos y potencialmente costo)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Container(
        child: Column(
          children: [
            // Header con caja de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  const Text(
                    'Productos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      // ... (tu TextField de búsqueda no cambia) ...
                      decoration: InputDecoration(
                        hintText: 'Buscar producto...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF7043),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _fetchData(_searchQuery); // Llama a _fetchData con la query
                      },
                    ),
                  ),
                ],
              ),
            ),

            // SECCIÓN PARA MOSTRAR EL COSTO DEL INVENTARIO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título con icono
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withOpacity(0.1), // Púrpura para inventario
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            size: 20,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Costo del Inventario',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contenido principal con estados
                    if (_isLoading && _totalInventoryCost == null && _searchQuery.isEmpty)
                      const Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Cargando...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    else if (_inventoryCostError != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _inventoryCostError!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      )
                    else if (_totalInventoryCost != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currencyFormat.format(_totalInventoryCost),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8D4E2A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 3,
                              width: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9C27B0), Color(0xFF9C27B0)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        )
                      else if (!_isLoading && _searchQuery.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'No disponible',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 3,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          )
                        else if (_searchQuery.isNotEmpty && _totalInventoryCost != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currencyFormat.format(_totalInventoryCost),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8D4E2A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 3,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF9C27B0), Color(0xFF9C27B0)],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // Lista de productos
            Expanded(
              child: _isLoading && _filteredProducts.isEmpty // Muestra indicador solo si está cargando y no hay productos aún
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                  ? Center(
                child: Text(
                  _searchQuery.isEmpty
                      ? 'No hay productos disponibles.'
                      : 'No se encontraron productos para "$_searchQuery".',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Ajusta el padding si es necesario
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductTile(
                    product: _filteredProducts[index],
                    onDataChanged: () {
                      _fetchData(_searchQuery); // Llama a _fetchData para recargar todo
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Botones flotantes
      floatingActionButton: Padding(
        // ... (tus FloatingActionButtons no cambian) ...
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AltaProductWidget(),

                  ).then((_) { // Añadido .then para recargar después de cerrar el diálogo
                    _fetchData(_searchQuery);
                  });
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
            ElevatedButton.icon(
              onPressed: _openNewProductForm,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Agregar nuevo producto',
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