import 'package:flutter/material.dart';
import 'package:pos_app/ui/screens/clients_screen.dart';
import 'package:pos_app/ui/screens/cortes_screen.dart';
import 'package:pos_app/ui/screens/dashboard_screen.dart';
import 'package:pos_app/ui/screens/product_list_screen.dart';
import 'package:pos_app/ui/screens/sales_list_screen.dart';
import 'package:pos_app/ui/screens/ticket_screen.dart';
import 'package:pos_app/ui/screens/users_screen.dart';
import 'package:pos_app/ui/widgets/bottom_nav.dart';
import 'package:pos_app/ui/widgets/top_nav.dart';

/// HomeScreen que muestra las 5 secciones con navegación inferior
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista de pantallas que corresponden a cada pestaña
  static final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const SalesScreen(),
    const ClientsScreen(),
    const CortesScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Mostrar siempre el TopNav
          const TopNav(
            businessName: 'Cervecería Admin',
            username: 'admin',
          ),
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
