import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/resume_ventas.dart';

class ResumeVentasWd extends StatelessWidget {
  final ResumeVentas data;

  const ResumeVentasWd({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'es_MX');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Total Ventas
          Expanded(
            child: _buildCard(
              icon: Icons.trending_up,
              iconColor: Colors.blue,
              title: 'Total Ventas',
              content: '${data.totalVentas}',
            ),
          ),
          const SizedBox(width: 12),
          // Ingresos
          Expanded(
            child: _buildCard(
              icon: Icons.attach_money,
              iconColor: Colors.green,
              title: 'Ingresos',
              content: currencyFormat.format(data.totalIngresos),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y título
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
