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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Título
                  const Text(
                    'Ventas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                ],
              ),
            ),

            // Lista de ventas
            Expanded(
              child: FutureBuilder<List<SaleResponse>>(
                future: service.fetchAll(),
                builder: (c, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final sales = snap.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sales.length,
                    itemBuilder: (c, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SaleTile(sale: sales[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}