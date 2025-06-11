import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/department/department.dart';
import '../../services/department_service.dart';
import '../widgets/department/department_tile.dart';
import '../widgets/department/department_form.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  List<Department> _filteredDepartments = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<DepartmentService>(context, listen: false);
      final departments = query.isEmpty
          ? await service.fetchAll()
          : await service.search(query);

      setState(() {
        _filteredDepartments = departments;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching departments: $e');
      setState(() => _isLoading = false);
    }
  }

  void _openNewDepartmentForm() {
    showDialog(
      context: context,
      builder: (_) => DepartmentForm(
        department: Department(id: 0, name: '', isActive: true),
        onSave: (newDepartment) {
          final service = Provider.of<DepartmentService>(context, listen: false);
          service.create(newDepartment);
          _fetchDepartments();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  const Text(
                    'Departamentos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar departamento...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _fetchDepartments(_searchQuery);
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDepartments.isEmpty
                  ? const Center(child: Text('No se encontraron departamentos'))
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: _filteredDepartments.length,
                itemBuilder: (c, i) => DepartmentTile(department: _filteredDepartments[i]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: ElevatedButton.icon(
          onPressed: _openNewDepartmentForm,
          icon: const Icon(Icons.add_business, color: Colors.white, size: 18),
          label: const Text(
            'Agregar nuevo departamento',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
