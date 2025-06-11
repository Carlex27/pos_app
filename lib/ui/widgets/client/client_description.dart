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
import 'client_abono_widget.dart'; // Importa el nuevo widget

class ClientDescription extends StatefulWidget {
  final Client client;

  const ClientDescription({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDescription> createState() => _ClientDescriptionState();
}

class _ClientDescriptionState extends State<ClientDescription> {
  List<SaleResponse> _sales = [];
  bool _loadingSales = false;

  void _onMonthSelected(int year, int month) async {
    setState(() => _loadingSales = true);
    try {
      final saleService = Provider.of<SaleService>(context, listen: false);
      final selectedDate = DateTime(year, month);
      final sales = await saleService.fetchByMonthAndClient(selectedDate, widget.client.id);
      setState(() {
        _sales = sales;
        _loadingSales = false;
      });
    } catch (e) {
      debugPrint('Error al obtener ventas del cliente: $e');
      setState(() => _loadingSales = false);
    }
  }

  Widget _buildInfo(String label, String value) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Cliente'),
        backgroundColor: Colors.orange[400],
        actions: [
          // Nuevo botón para "Abonos de Cliente"
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ClientAbonoWidget(client: widget.client);
                },
              );
            },
            child: const Text(
              'Abonos',
              style: TextStyle(color: Colors.white), // Ajusta el estilo según tu diseño
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ClientForm(
                  client: widget.client,
                  onSave: (updatedClient) {
                    Navigator.of(context).pop();
                    // Aquí podrías actualizar el estado del cliente en ClientDescription si es necesario
                    // setState(() { widget.client = updatedClient; });
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
                  content: Text(
                      '¿Seguro que deseas eliminar a ${widget.client.name}?'),
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

              if (confirmed == true) {
                try {
                  final clientService =
                  Provider.of<ClientService>(context, listen: false);
                  await clientService.delete(widget.client.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Opcional: Navegar hacia atrás después de eliminar
                  // if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
            _buildInfo('Nombre:', widget.client.name),
            const SizedBox(height: 12),
            _buildInfo('Dirección:', widget.client.direction),
            const SizedBox(height: 12),
            _buildInfo('Teléfono:', widget.client.phoneNumber),
            const SizedBox(height: 12),
            _buildInfo('Crédito disponible:', '\$${widget.client.creditLimit.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildInfo('Saldo actual:', '\$${widget.client.balance.toStringAsFixed(2)}'),
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
