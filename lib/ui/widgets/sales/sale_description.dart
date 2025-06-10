import 'package:flutter/material.dart';
import '../../../models/sales/sale_response.dart';

class SaleDescription extends StatelessWidget {
  final SaleResponse sale;

  const SaleDescription({
    Key? key,
    required this.sale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Cliente', sale.clientName),
            _buildInfoRow('Vendedor', sale.vendorName),
            _buildInfoRow('Fecha de venta', _formatDate(sale.saleDate)),
            const SizedBox(height: 16),
            _buildSectionTitle('Productos'),
            const SizedBox(height: 8),
            if (sale.items != null && sale.items!.isNotEmpty)
              ...sale.items!.map((item) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                title: Text(item.nombre),
                subtitle: Text('Cantidad: ${item.cantidad}'),
                trailing: Text('\$${(item.precio * item.cantidad).toStringAsFixed(2)}'),
              )),
            const SizedBox(height: 24),
            _buildInfoRow('Total', '\$${sale.total.toStringAsFixed(2)}', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    String month = dateTime.month.toString();
    String day = dateTime.day.toString();
    String year = dateTime.year.toString();

    int hour = dateTime.hour;
    int minute = dateTime.minute;
    int second = dateTime.second;

    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    String formattedTime = '${displayHour.toString()}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} $period';

    return '$month/$day/$year, $formattedTime';
  }
}
