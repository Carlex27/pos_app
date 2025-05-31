// Este archivo permite modificar la IP del backend desde la pantalla de login
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

class BackendConfigEditor extends StatefulWidget {
  const BackendConfigEditor({super.key});

  @override
  State<BackendConfigEditor> createState() => _BackendConfigEditorState();
}

class _BackendConfigEditorState extends State<BackendConfigEditor> {
  bool showEditor = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('api_ip') ?? '';
    _controller.text = ip;
  }

  Future<void> _saveIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_ip', _controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dirección IP actualizada. Reinicia la app.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => setState(() => showEditor = !showEditor),
          child: const Text('Configurar IP del servidor'),
        ),
        if (showEditor)
          Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'IP del servidor (sin http ni puerto)',
                  hintText: 'Ej: 192.168.1.10',
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saveIp,
                child: const Text('Guardar'),
              ),
            ],
          ),
      ],
    );
  }
}


