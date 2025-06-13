import 'package:flutter/material.dart';

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
          onTap: onTap,
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
              icon: _buildIcon(Icons.people_alt_rounded, 3),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.receipt_long_rounded, 4),
              label: 'Cortes',
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
