import 'package:flutter/material.dart';
import '../../models/sale_response.dart';
import '../../utils/date_formatter.dart';

class SaleTile extends StatelessWidget {
  final SaleResponse sale;
  final VoidCallback? onTap;
  const SaleTile({ required this.sale, this.onTap, Key? key }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return ListTile(
      title: Text('Venta #${sale.id}'),
      subtitle: Text('${sale.clientName} • ${formatDate(sale.saleDate)}'),
      trailing: Text('\$${sale.total.toStringAsFixed(2)}'),
      onTap: onTap,
    );
  }
}