import 'package:flutter/material.dart';
import '../../../models/client/client.dart';

class ClientForm extends StatefulWidget {
  final Client? client;
  final void Function(Client) onSave;
  final bool isEditing;

  const ClientForm({
    Key? key,
    this.client,
    required this.onSave,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<ClientForm> createState() => _ClientFormState();

}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _directionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _creditLimitController;



  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _directionController = TextEditingController(text: widget.client?.direction ?? '');
    _phoneController = TextEditingController(text: widget.client?.phoneNumber ?? '');
    _creditLimitController = TextEditingController(text: widget.client?.creditLimit.toString() ?? '0.0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _directionController.dispose();
    _phoneController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Client(
          id: widget.client?.id ?? 0,
          name: _nameController.text,
          direction: _directionController.text,
          phoneNumber: _phoneController.text,
          creditLimit: double.tryParse(_creditLimitController.text) ?? 0.0,
          balance: widget.client?.balance ?? 0.0,
          lastAbonoDate: widget.client?.lastAbonoDate ?? DateTime(1970, 1, 1),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEditing ? 'Editar Cliente' : 'Crear Cliente',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _directionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creditLimitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Límite de Crédito'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
