import 'package:flutter/material.dart';

class CortesScreen extends StatelessWidget {
  const CortesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Cortes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              // Aquí puedes comenzar a agregar tus widgets relacionados a los cortes
              // Ejemplo: resumen de ventas, botón de generar corte, historial, etc.
            ],
          ),
        ),
      ),
    );
  }
}
