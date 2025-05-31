import 'package:flutter/material.dart';
import '../../models/user.dart';

class EditUserForm extends StatefulWidget {
  final User user;
  final void Function(String username, String password, String selectedRole) onSave;

  const EditUserForm({
    Key? key,
    required this.user,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;

  final List<Map<String, String>> roles = [
    {'label': 'Administrador', 'value': 'ROLE_ADMIN'},
    {'label': 'Vendedor', 'value': 'ROLE_VENDEDOR'},
  ];

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _selectedRole = widget.user.role == 'Administrador'
        ? 'ROLE_ADMIN'
        : 'ROLE_VENDEDOR';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      widget.onSave(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole!,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar Usuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: roles.any((r) => r['value'] == _selectedRole) ? _selectedRole : null,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: roles
                    .map((role) => DropdownMenuItem(
                  value: role['value'],
                  child: Text(role['label']!),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Selecciona un rol' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
