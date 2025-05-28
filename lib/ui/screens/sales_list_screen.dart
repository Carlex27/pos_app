import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sale_service.dart';
import '../widgets/sale_tile.dart';
import '../../models/sale_response.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext ctx) {
    final service = Provider.of<SaleService>(ctx, listen: false);
    return FutureBuilder<List<SaleResponse>>(
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
          itemCount: sales.length,
          itemBuilder: (c, i) => SaleTile(
            sale: sales[i],
            onTap: () { /* navegar a detalle */ },
          ),
        );
      },
    );
  }
}