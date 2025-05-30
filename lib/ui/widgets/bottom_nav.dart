import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

/// Widget reutilizable para la barra de navegación inferior con 5 pestañas
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6C5CE7),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 10,
          iconSize: 24,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
          onTap: (index) async {
            if (index == 4) {
              // Cerrar sesión
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
            } else {
              onTap(index); // Navegación normal
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.dashboard_rounded, 0),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.inventory_2_rounded, 1),
              label: 'Productos',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.point_of_sale_rounded, 2),
              label: 'Ventas',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.people_rounded, 3),
              label: 'Usuarios',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.logout_rounded, 4),
              label: 'Salir',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData iconData, int index) {
    final isSelected = currentIndex == index;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6C5CE7).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        size: 24,
        color: isSelected
            ? const Color(0xFF6C5CE7)
            : Colors.grey[400],
      ),
    );
  }
}