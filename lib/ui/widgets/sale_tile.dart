import 'package:flutter/material.dart';
import '../../models/sale_response.dart';

class SaleTile extends StatelessWidget {
  final SaleResponse sale;

  const SaleTile({
    Key? key,
    required this.sale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre del cliente, total y cantidad de items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del cliente y vendedor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del cliente
                    Text(
                      sale.clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Vendedor
                    Text(
                      'Vendedor: ${sale.vendorName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Fecha y hora
                    Text(
                      _formatDate(sale.saleDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Total y cantidad de items
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Total
                  Text(
                    '\$${sale.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Cantidad de items
                  Text(
                    '${sale.items?.length ?? 0} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Lista de productos
          if (sale.items != null && sale.items!.isNotEmpty)
            ...sale.items!.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.nombre} x${item.cantidad}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

            )).toList(),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    // Formato: 1/20/2024, 10:30:00 AM
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