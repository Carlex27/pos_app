import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../widgets/user_tile.dart';

/// Pantalla de usuarios
class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      // Aquí iría tu servicio de usuarios
      // final service = Provider.of<UserService>(context, listen: false);
      // final users = query.isEmpty
      //     ? await service.fetchAll()
      //     : await service.search(query);

      // Por ahora datos de ejemplo
      final users = [
        User(
          id: '1',
          name: 'Admin Principal',
          role: 'Administrador',
          createdAt: DateTime(2023, 12, 31),
        ),
        User(
          id: '2',
          name: 'Juan Pérez',
          role: 'Empleado',
          createdAt: DateTime(2024, 1, 14),
        ),
      ];

      setState(() {
        _users = users.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.role.toLowerCase().contains(query.toLowerCase())
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header con título, búsqueda y logout
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // Fila superior: Título y botón logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Usuarios',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campo de búsqueda
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar usuario...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
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
                          color: Color(0xFFFF7043),
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
                      _fetchUsers(_searchQuery);
                    },
                  ),
                ],
              ),
            ),

            // Lista de usuarios
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(
                child: Text(
                  'No se encontraron usuarios',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _users.length,
                itemBuilder: (context, index) => UserTile(
                  user: _users[index],
                ),
              ),
            ),
          ],
        ),
      ),

      // Botón flotante para agregar usuario
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Aquí iría el diálogo o navegación para agregar usuario
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Agregar usuario - En desarrollo')),
            );
          },
          backgroundColor: const Color(0xFFFF7043),
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Agregar',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
