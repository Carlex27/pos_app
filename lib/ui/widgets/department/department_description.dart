import 'package:flutter/material.dart';
import 'package:pos_app/models/department/department.dart';


class DepartmentDescription extends StatelessWidget {
  final Department department;

  const DepartmentDescription({Key? key, required this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Departamento'),
        backgroundColor: Colors.orange[400],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo('Nombre del Departamento:', department.name),
            const SizedBox(height: 12),
            _buildInfo('Estado:', department.isActive ? 'Activo' : 'Inactivo'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
