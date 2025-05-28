import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNav({ required this.currentIndex, required this.onTap, Key? key }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: 'Productos'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ventas'),
      ],
      onTap: onTap,
    );
  }
}