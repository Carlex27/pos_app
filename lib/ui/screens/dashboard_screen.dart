import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/resume_dashboard.dart';
import '../widgets/resume_dashboard.dart';
import '../../services/resume_service.dart';

/// Pantalla principal con indicadores y ventas recientes
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<ResumeDashboard> _resumeFuture;

  @override
  void initState() {
    super.initState();
    _resumeFuture = ResumeService().fetchResumeDashboardByDay(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResumeDashboard>(
      future: _resumeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No hay datos disponibles.'));
        }

        final resumeData = snapshot.data!;

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

              // Widget reutilizable de resumen
              ResumeDashboardWidget(data: resumeData),

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
                    ...resumeData.ventasRecientes.map((venta) => Column(
                      children: [
                        SaleTile(
                          customerName: venta.nombreCliente,
                          date: DateFormat('dd/MM/yyyy, hh:mm a').format(venta.fechaVenta),
                          amount: '\$${venta.totalVenta.toStringAsFixed(2)}',
                          items: '${venta.cantidadProductos} items',
                        ),
                        const Divider(height: 24),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
