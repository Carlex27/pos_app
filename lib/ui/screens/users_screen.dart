import 'package:flutter/material.dart';
import 'package:pos_app/ui/widgets/user_form.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../../models/user_registration.dart';
import '../widgets/user_tile.dart';


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
      final service = Provider.of<UserService>(context, listen: false);
      final users = query.isEmpty
          ? await service.fetchAll()
          : await service.search(query);

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await Provider.of<UserService>(context, listen: false).delete(userId);
      _fetchUsers(_searchQuery);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }




  Future<void> _showDeleteDialog(User user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas eliminar el usuario "${user.username}"?'),
                const SizedBox(height: 8),
                const Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(user.id);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
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
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return UserTile(
                    user: user,
                    onDelete: () => _showDeleteDialog(user),
                    onEdit: (username, password, selectedRole) async {
                      try {
                        final userService = Provider.of<UserService>(context, listen: false);
                        await userService.update(UserRegistration(
                          userName: username,
                          userPassword: password,
                          userRole: selectedRole,
                        ), user.id);
                        _fetchUsers(); // para actualizar la lista
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario actualizado correctamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar usuario: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => UserForm(
                user: User(
                  id: 0, // este valor no se usará al crear
                  username: '',
                  role: 'Vendedor', // por defecto
                  createdAt: DateTime.now(),
                ),
                onSave: (username, password, selectedRole) async {
                  try {
                    final userService = Provider.of<UserService>(context, listen: false);
                    await userService.create(
                      UserRegistration(
                        userName: username,
                        userPassword: password,
                        userRole: selectedRole,
                      ),
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario creado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _fetchUsers(); // actualizar lista
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al crear usuario: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
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
