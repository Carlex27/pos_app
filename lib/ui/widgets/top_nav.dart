import 'package:flutter/material.dart';
import 'package:pos_app/ui/screens/salidas_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../screens/ticket_screen.dart';
import '../screens/users_screen.dart';
import '../screens/department_screen.dart';

class TopNav extends StatelessWidget {
  final String businessName;
  final String username;

  const TopNav({
    super.key,
    required this.businessName,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            PopupMenuButton<int>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: const Icon(Icons.settings, color: Colors.black),
              onSelected: (value) async {
                if (value == 0) {
                  // Mostrar pantalla de configuración de ticket como modal
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => const SalidasScreen(),
                  );
                }else if (value == 1) {
                  // Mostrar pantalla de configuración de tick et como modal
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => const TicketScreen(),
                  );
                } else if (value == 2) {
                  // Mostrar pantalla de usuarios como modal
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => const UsersScreen(),
                  );
                } else if (value == 3) {
                  // Mostrar pantalla de usuarios como modal
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => const DepartmentScreen(),
                  );
                } else if (value == 4) {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.red[400],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '¿Cerrar sesión?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        '¿Estás seguro de que quieres salir de la aplicación?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                          height: 1.5,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    final auth = Provider.of<AuthService>(context, listen: false);
                    await auth.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: const [
                      Icon(Icons.receipt_long, size: 20),
                      SizedBox(width: 8),
                      Text('Salidas'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: const [
                      Icon(Icons.receipt_long, size: 20),
                      SizedBox(width: 8),
                      Text('Configurar Ticket'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: const [
                      Icon(Icons.people_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Gestión de Usuarios'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: const [
                      Icon(Icons.store_mall_directory_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Departamentos'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Cerrar Sesión'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
