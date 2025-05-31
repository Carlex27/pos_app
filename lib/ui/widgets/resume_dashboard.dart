import 'package:flutter/material.dart';
import '../../models/resume_dashboard.dart';

/// Widget que muestra los 4 indicadores del dashboard
class ResumeDashboardWidget extends StatelessWidget {
  final ResumeDashboard data;

  const ResumeDashboardWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        InfoCard(
          title: 'Total Productos',
          value: data.totalProductos.toString(),
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF6B73FF),
        ),
        InfoCard(
          title: 'Ventas Hoy',
          value: data.totalVentas.toString(),
          icon: Icons.trending_up,
          color: const Color(0xFF00D4AA),
        ),
        InfoCard(
          title: 'Ingresos',
          value: '\$${data.ingresosTotales.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: const Color(0xFF9C88FF),
        ),
        InfoCard(
          title: 'Stock Bajo',
          value: data.stockBajo.toString(),
          icon: Icons.warning_amber_outlined,
          color: const Color(0xFFFF6B6B),
          highlight: data.stockBajo > 0,
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: highlight ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
