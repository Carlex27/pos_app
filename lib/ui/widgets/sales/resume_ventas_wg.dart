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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono con fondo circular
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Contenido principal
          Text(
            content,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D4E2A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          // Línea decorativa
          Container(
            height: 2,
            width: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}