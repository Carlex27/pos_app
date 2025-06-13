import 'package:flutter/material.dart';
import 'package:pos_app/models/salidas/salidas.dart';

class SalidasForm extends StatefulWidget {
  final Salidas salidas;
  final Function(Salidas) onSubmit;

  const SalidasForm({
    Key? key,
    required this.salidas,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<SalidasForm> createState() => _SalidasFormState();
}

class _SalidasFormState extends State<SalidasForm> {
  late TextEditingController _montoController;
  late TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController(text: widget.salidas.amount.toString());
    _descripcionController = TextEditingController(text: widget.salidas.description ?? '');
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final double? monto = double.tryParse(_montoController.text);
    final String descripcion = _descripcionController.text;

    if (monto == null || descripcion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos correctamente.')),
      );
      return;
    }

    final updatedSalidas = widget.salidas.copyWith(
      amount: monto,
      description: descripcion,
    );

    widget.onSubmit(updatedSalidas);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Salida'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
