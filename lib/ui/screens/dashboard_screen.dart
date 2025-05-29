import 'package:flutter/material.dart';

/// Pantalla principal con indicadores y ventas recientes
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Header
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bienvenido, Admin Principal',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Cards Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0, // <- esto reduce la altura disponible por ítem
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              InfoCard(
                title: 'Total Productos',
                value: '3',
                icon: Icons.inventory_2_outlined,
                color: Color(0xFF6B73FF),
              ),
              InfoCard(
                title: 'Ventas Hoy',
                value: '2',
                icon: Icons.trending_up,
                color: Color(0xFF00D4AA),
              ),
              InfoCard(
                title: 'Ingresos',
                value: '\$144.00',
                icon: Icons.attach_money,
                color: Color(0xFF9C88FF),
              ),
              InfoCard(
                title: 'Stock Bajo',
                value: '0',
                icon: Icons.warning_amber_outlined,
                color: Color(0xFFFF6B6B),
                highlight: false,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Ventas Recientes Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ventas Recientes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const SaleTile(
                  customerName: 'Carlos López',
                  date: '1/20/2024, 2:15:00 PM',
                  amount: '\$94.00',
                  items: '4 items',
                ),
                const Divider(height: 24),
                const SaleTile(
                  customerName: 'María García',
                  date: '1/20/2024, 10:30:00 AM',
                  amount: '\$50.00',
                  items: '2 items',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta informativa para indicadores del dashboard
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

/// Widget para mostrar una venta individual
class SaleTile extends StatelessWidget {
  final String customerName;
  final String date;
  final String amount;
  final String items;

  const SaleTile({
    required this.customerName,
    required this.date,
    required this.amount,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar del cliente
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person_outline,
            color: Colors.grey[600],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),

        // Información del cliente y fecha
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Monto y cantidad de items
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D4AA),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              items,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}