// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/sale_service.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ProductService>(create: (_) => ProductService()),
        Provider<SaleService>(create: (_) => SaleService()),
      ],
      child: MaterialApp(
        title: 'POS Cervecería',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (ctx) => const LoginScreen(),
          '/home':  (ctx) => const HomeScreen(),

        },
      ),
    );
  }
}
