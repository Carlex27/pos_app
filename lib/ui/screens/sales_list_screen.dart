import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sale_service.dart';
import '../../models/sale_response.dart';
import '../widgets/sale_tile.dart';

/// Pantalla de listado de ventas
class SalesScreen extends StatelessWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SaleService>(context, listen: false);
    return FutureBuilder<List<SaleResponse>>(
      future: service.fetchAll(),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: \${snap.error}'));
        final sales = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sales.length,
          itemBuilder: (c, i) => SaleTile(sale: sales[i]),
        );
      },
    );
  }
}
