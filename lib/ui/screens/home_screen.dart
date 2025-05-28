import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'product_list_screen.dart';
import 'sales_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  static const _screens = [
    ProductListScreen(),
    SalesListScreen(),
  ];

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}