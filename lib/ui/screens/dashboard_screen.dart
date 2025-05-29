import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/product_service.dart';
import '../../services/sale_service.dart';
import '../../models/product.dart';
import '../../models/sale_response.dart';
import '../../utils/date_formatter.dart';
import '../widgets/sale_tile.dart';

/// Pantalla principal con indicadores y ventas recientes
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    final saleService = Provider.of<SaleService>(context, listen: false);
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([productService.fetchAll(), saleService.fetchAll()]),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        }
        final products = snapshot.data![0] as List<Product>;
        final sales = snapshot.data![1] as List<SaleResponse>;

        final today = DateTime.now();
        final salesToday = sales.where((s) =>
        s.saleDate.year == today.year &&
            s.saleDate.month == today.month &&
            s.saleDate.day == today.day
        ).toList();

        final ingresos = salesToday.fold<double>(0, (sum, s) => sum + s.total);
        final lowStockCount = products.where((p) => p.stock < 5).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Bienvenido, Admin Principal', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  InfoCard(title: 'Total Productos', value: products.length.toString()),
                  InfoCard(title: 'Ventas Hoy', value: salesToday.length.toString()),
                  InfoCard(title: 'Ingresos', value: '\\${ingresos.toStringAsFixed(2)}'),
                  InfoCard(title: 'Stock Bajo', value: lowStockCount.toString(), highlight: lowStockCount > 0),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Ventas Recientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...sales.take(5).map((s) => SaleTile(sale: s)),
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta informativa para indicadores del dashboard
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  const InfoCard({
    required this.title,
    required this.value,
    this.highlight = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: highlight ? Colors.red : Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
