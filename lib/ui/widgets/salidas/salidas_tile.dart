import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/models/salidas/salidas.dart';
import 'package:pos_app/ui/widgets/salidas/salidas_form.dart'; // Asegúrate de importar correctamente

class SalidasTile extends StatelessWidget {
  final Salidas salida;
  final VoidCallback? onDelete;
  final Function(Salidas)? onUpdate;

  const SalidasTile({
    Key? key,
    required this.salida,
    this.onDelete,
    this.onUpdate,
  }) : super(key: key);

  void _openEditForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SalidasForm(
        salidas: salida,
        onSubmit: (updatedSalida) {
          Navigator.of(ctx).pop();
          if (onUpdate != null) {
            onUpdate!(updatedSalida);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.arrow_circle_up, color: Colors.orange.shade800),
        ),
        title: Text(
          salida.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Fecha: ${dateFormat.format(salida.date)}\nMonto: \$${salida.amount.toStringAsFixed(2)}',
          style: const TextStyle(height: 1.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () => _openEditForm(context),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
