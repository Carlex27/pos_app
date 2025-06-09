import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/resume/resume_dashboard.dart';

/// Widget que muestra los 4 indicadores del dashboard
class ResumeDashboardWidget extends StatelessWidget {
  final ResumeDashboard data;

  const ResumeDashboardWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'es_MX');

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        InfoCard(
          title: 'Total Productos',
          value: data.totalProductos.toString(),
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFF6B73FF),
          iconBgColor: const Color(0xFF6B73FF).withOpacity(0.1),
        ),
        InfoCard(
          title: 'Ventas Hoy',
          value: data.totalVentas.toString(),
          icon: Icons.trending_up,
          iconColor: const Color(0xFF00D4AA),
          iconBgColor: const Color(0xFF00D4AA).withOpacity(0.1),
        ),
        InfoCard(
          title: 'Ingresos',
          value: currencyFormat.format(data.ingresosTotales),
          icon: Icons.attach_money,
          iconColor: const Color(0xFF9C88FF),
          iconBgColor: const Color(0xFF9C88FF).withOpacity(0.1),
        ),
        InfoCard(
          title: 'Stock Bajo',
          value: data.stockBajo.toString(),
          icon: Icons.warning_amber_outlined,
          iconColor: const Color(0xFFFF6B6B),
          iconBgColor: const Color(0xFFFF6B6B).withOpacity(0.1),
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
  final Color iconColor;
  final Color iconBgColor;
  final bool highlight;

  const InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.highlight = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono con fondo circular y título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Valor principal
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: highlight ? const Color(0xFFFF6B6B) : const Color(0xFF8D4E2A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Línea decorativa
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: highlight
                      ? [const Color(0xFFFF6B6B), const Color(0xFFFF6B6B).withOpacity(0.3)]
                      : [iconColor, iconColor.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}