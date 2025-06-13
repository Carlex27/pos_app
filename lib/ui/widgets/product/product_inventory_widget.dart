import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para FilteringTextInputFormatter
import 'package:intl/intl.dart';
// Asegúrate de que la ruta a tu modelo sea correcta
import 'package:pos_app/models/product/product_Inventory_entry.dart';
// Asegúrate de que la ruta a tu servicio sea correcta
import '../../../services/product_service.dart';

class ProductInventoryWidget extends StatefulWidget {
  final int productId;
  final ProductService productService;

  const ProductInventoryWidget({
    Key? key,
    required this.productId,
    required this.productService,
  }) : super(key: key);

  @override
  State<ProductInventoryWidget> createState() => _ProductInventoryWidgetState();
}

class _ProductInventoryWidgetState extends State<ProductInventoryWidget> {
  Future<List<ProductInventoryEntry>>? _entriesFuture;
  // Usar una clave para el FutureBuilder puede ayudar a forzar su reconstrucción
  // cuando _entriesFuture es reemplazado por una nueva instancia de Future.
  Key _futureBuilderKey = UniqueKey();


  @override
  void initState() {
    super.initState();
    _loadInventoryEntries();
  }

  void _loadInventoryEntries() {
    setState(() {
      // Asignar una nueva UniqueKey fuerza al FutureBuilder a reconstruirse
      // con el nuevo Future, lo cual es útil después de una actualización.
      _futureBuilderKey = UniqueKey();
      _entriesFuture = widget.productService.fetchAllEntriesByProduct(widget.productId);
    });
  }

  Future<void> _showEditEntryDialog(ProductInventoryEntry entry) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController cantidadController =
    TextEditingController(text: entry.cajasCompradas.toString());
    final TextEditingController precioCostoController =
    TextEditingController(text: entry.precioPorCaja.toStringAsFixed(2));

    ProductInventoryEntry? updatedEntryData = await showDialog<ProductInventoryEntry>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Entrada'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: cantidadController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad (cajas)',
                      icon: Icon(Icons.shopping_cart_checkout_outlined), // Icono actualizado
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la cantidad';
                      }
                      final intValue = int.tryParse(value);
                      if (intValue == null || intValue <= 0) {
                        return 'Ingrese un número válido mayor a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: precioCostoController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Costo por Caja',
                      prefixText: '\$ ',
                      icon: Icon(Icons.attach_money_outlined), // Icono actualizado
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el precio costo';
                      }
                      final doubleValue = double.tryParse(value);
                      if (doubleValue == null || doubleValue <= 0) {
                        return 'Ingrese un precio válido mayor a 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Crea una nueva instancia con los datos actualizados.
                  // `copyWith` debería mantener los campos no modificados como
                  // `id`, `productId`, y `entryDate` de la 'entry' original.
                  final updatedData = entry.copyWith(
                    cajasCompradas: int.parse(cantidadController.text),
                    precioPorCaja: double.parse(precioCostoController.text),
                  );
                  Navigator.of(dialogContext).pop(updatedData);
                }
              },
            ),
          ],
        );
      },
    );

    if (updatedEntryData != null) {
      // Mostrar un indicador de carga mientras se actualiza
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [CircularProgressIndicator(), SizedBox(width: 15), Text('Actualizando entrada...')]),
          duration: Duration(seconds: 5), // Duración más larga para que el usuario vea que se está procesando
        ),
      );

      try {
        // Llama al método del servicio para actualizar.
        // Asegúrate de que el nombre del método (updateEntry o update) sea el correcto.
        final successMessage = await widget.productService.updateEntry(updatedEntryData);

        // Quitar el SnackBar de "Actualizando..." y mostrar el de éxito
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        _loadInventoryEntries(); // Recarga la lista para reflejar los cambios
      } catch (e) {
        // Quitar el SnackBar de "Actualizando..." y mostrar el de error
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        // Opcional: podrías querer imprimir el error completo en la consola de depuración
        print("Error completo al actualizar entrada: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es_MX');

    return Material(
      color: Theme.of(context).canvasColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Entradas de Inventario',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (widget.productId != 0) // Asumiendo 0 como un ID no válido o no especificado
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Producto ID: ${widget.productId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const Divider(thickness: 1, height: 16),
            Expanded(
              child: FutureBuilder<List<ProductInventoryEntry>>(
                key: _futureBuilderKey, // Importante para la reconstrucción
                future: _entriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar entradas',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(), // Muestra el error
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                              onPressed: _loadInventoryEntries,
                            )
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade500),
                            const SizedBox(height: 16),
                            Text(
                              'Sin Entradas Registradas',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final entries = snapshot.data!;
                  return ListView.separated(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12), // Ajuste de padding derecho para el botón
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cantidad: ${entry.cajasCompradas}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Precio Costo: ${currencyFormatter.format(entry.precioPorCaja)} /caja',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.secondary), // Icono actualizado
                                    tooltip: 'Editar Entrada',
                                    padding: EdgeInsets.zero, // Ajustar padding si es necesario
                                    constraints: const BoxConstraints(), // Para quitar padding extra
                                    onPressed: () {
                                      _showEditEntryDialog(entry);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Fecha: ${dateFormatter.format(entry.entryDate)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}