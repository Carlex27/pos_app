import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

/// Pantalla de usuarios y logout
class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await auth.logout();
          Navigator.of(context).pushReplacementNamed('/login');
        },
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
        ),
      ),
    );
  }
}
