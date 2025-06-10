import 'package:flutter/material.dart';
import '../../../models/client/client.dart';

class ClientDescription extends StatelessWidget {
  final Client client;

  const ClientDescription({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Cliente'),
        backgroundColor: Colors.orange[400],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo('Nombre:', client.name),
            const SizedBox(height: 12),
            _buildInfo('Dirección:', client.direction),
            const SizedBox(height: 12),
            _buildInfo('Teléfono:', client.phoneNumber),
            const SizedBox(height: 12),
            _buildInfo('Balance:', client.balance.toString()),
            const SizedBox(height: 12),
            _buildInfo('Crédito disponible:', '\$${client.creditLimit.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildInfo('Saldo actual:', '\$${client.balance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
