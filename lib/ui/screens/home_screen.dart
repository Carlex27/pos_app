import 'package:flutter/material.dart';
import 'package:pos_app/ui/screens/product_list_screen.dart';
import 'package:pos_app/ui/screens/sales_list_screen.dart';
import '../widgets/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';
import 'sales_list_screen.dart';
import 'users_screen.dart';

/// HomeScreen que muestra las 5 secciones con navegación inferior
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista de pantallas que corresponden a cada pestaña
  static const List<Widget> _screens = [
    DashboardScreen(),
    ProductsScreen(),
    SalesScreen(),
    UsersScreen(),
    UsersScreen(), // la pestaña Salir reutiliza UsersScreen para logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
