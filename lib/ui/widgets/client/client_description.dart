import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/models/sales/sale_response.dart';
import 'package:pos_app/services/client_service.dart';
import 'package:pos_app/ui/widgets/client/client_form.dart';
import 'package:pos_app/ui/widgets/sales/sale_tile.dart';
import 'package:pos_app/ui/widgets/selector_month.dart';
import 'package:provider/provider.dart';

import '../../../models/client/client.dart';
import '../../../services/sale_service.dart';
import 'client_abono_widget.dart';

class ClientDescription extends StatefulWidget {
  final Client client;

  const ClientDescription({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDescription> createState() => _ClientDescriptionState();
}

class _ClientDescriptionState extends State<ClientDescription> {
  late Client _currentClient; // Para mantener el estado actual del cliente
  List<SaleResponse> _sales = [];
  bool _loadingSales = false;

  @override
  void initState() {
    super.initState();
    _currentClient = widget.client; // Inicializa con el cliente pasado al widget
    // _onMonthSelected inicial se podría llamar aquí si quieres cargar ventas inmediatamente
    // por ejemplo, para el mes actual.
  }

  // Si el widget padre puede cambiar el cliente que se pasa a ClientDescription,
  // y quieres que esta pantalla reaccione a ese cambio, necesitarías didUpdateWidget:
  @override
  void didUpdateWidget(covariant ClientDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.client.id != oldWidget.client.id) {
      setState(() {
        _currentClient = widget.client;
        _sales = []; // Resetea las ventas si el cliente cambia completamente
        // Podrías llamar a _onMonthSelected aquí para el nuevo cliente si es necesario
      });
    }
  }


  void _onMonthSelected(int year, int month) async {
    setState(() => _loadingSales = true);
    try {
      final saleService = Provider.of<SaleService>(context, listen: false);
      final selectedDate = DateTime(year, month);
      // Usa _currentClient.id aquí
      final sales = await saleService.fetchByMonthAndClient(selectedDate, _currentClient.id);
      if (mounted) {
        setState(() {
          _sales = sales;
          _loadingSales = false;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener ventas del cliente: $e');
      if (mounted) {
        setState(() => _loadingSales = false);
      }
    }
  }

  Widget _buildInfo(String label, String value) {
    // ... (sin cambios en _buildInfo)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            )),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ahora, todas las referencias a widget.client en el build method
    // deben cambiarse a _currentClient
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentClient.name), // Usa _currentClient.name si quieres que el título también se actualice
        // title: const Text('Detalles del Cliente'), // O mantenlo genérico
        backgroundColor: Colors.orange[400],
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // Pasa _currentClient al widget de abonos
                  return ClientAbonoWidget(client: _currentClient);
                },
              );
            },
            child: const Text(
              'Abonos',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => ClientForm(
                  client: _currentClient, // Pasa el _currentClient al formulario
                  isEditing: true,
                  onSave: (updatedClient) async {
                    final clientService = Provider.of<ClientService>(context, listen: false);
                    try {
                      await clientService.update(updatedClient);

                      if (mounted) {
                        setState(() {
                          _currentClient = updatedClient; // <--- ACTUALIZA EL ESTADO AQUÍ
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cliente actualizado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // No necesitas hacer nada más aquí para ClientDescription,
                        // ya que setState reconstruirá esta pantalla con _currentClient.

                        // Si ClientScreen (la pantalla anterior) necesita actualizarse,
                        // esa lógica permanece como se discutió antes (callbacks, Provider, etc.)
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar cliente: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      debugPrint('Error al actualizar cliente: $e');
                    }
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar cliente'),
                  // Usa _currentClient aquí también
                  content: Text('¿Seguro que deseas eliminar a ${_currentClient.name}?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Eliminar'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) { // Añade chequeo de mounted aquí también
                try {
                  final clientService = Provider.of<ClientService>(context, listen: false);
                  // Usa _currentClient.id para eliminar
                  await clientService.delete(_currentClient.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Después de eliminar, probablemente quieras cerrar esta pantalla
                  if (mounted) {
                    Navigator.of(context).pop(); // Vuelve a la pantalla anterior
                  }
                } catch (e) {
                  if (mounted) { // mounted check
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Usa _currentClient para mostrar la información
            _buildInfo('Nombre:', _currentClient.name),
            const SizedBox(height: 12),
            _buildInfo('Dirección:', _currentClient.direction),
            const SizedBox(height: 12),
            _buildInfo('Teléfono:', _currentClient.phoneNumber),
            const SizedBox(height: 12),
            _buildInfo('Crédito disponible:', '\$${_currentClient.creditLimit.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildInfo('Saldo actual:', '\$${_currentClient.balance.toStringAsFixed(2)}'),
            const SizedBox(height: 24),

            SelectorMonth(onMonthSelected: _onMonthSelected),

            const SizedBox(height: 24),
            _loadingSales
                ? const Center(child: CircularProgressIndicator())
                : _sales.isEmpty
                ? const Text('No hay ventas en este período.')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sales.length,
              itemBuilder: (context, index) {
                return SaleTile(sale: _sales[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}