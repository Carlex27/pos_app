import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/resume/resume_ventas.dart';

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
              iconColor: const Color(0xFFFFB74D),
              iconBgColor: const Color(0xFFFFB74D).withOpacity(0.1),
              title: 'Total Ventas',
              content: '${data.totalVentas}',
            ),
          ),
          const SizedBox(width: 16),
          // Ingresos
          Expanded(
            child: _buildCard(
              icon: Icons.attach_money,
              iconColor: const Color(0xFF4CAF50),
              iconBgColor: const Color(0xFF4CAF50).withOpacity(0.1),
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
    required Color iconBgColor,
    required String title,
    required String content,
  }) {
    return Container(
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
          // Icono con fondo circular
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contenido principal
          Text(
            content,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D4E2A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Línea decorativa
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}