import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/product_service.dart';
import '../services/sale_service.dart';
import '../models/product.dart';
import '../models/sale_response.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => SaleService()),
      ],
      child: MaterialApp(
        title: 'POS Cervecería',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProductListScreen(),
    const SalesListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Ventas',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ProductService>(context);
    return FutureBuilder<List<Product>>(
      future: service.fetchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        }
        final products = snapshot.data!;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return ListTile(
              title: Text(p.nombre),
              subtitle: Text('\${p.marca} - \$\${p.precioNormal.toStringAsFixed(2)}'),
            );
          },
        );
      },
    );
  }
}

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SaleService>(context);
    return FutureBuilder<List<SaleResponse>>(
      future: service.fetchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        }
        final sales = snapshot.data!;
        return ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final s = sales[index];
            return ListTile(
              title: Text('Venta #\${s.id}'),
              subtitle: Text('\${s.clientName} - \$\${s.total.toStringAsFixed(2)}'),
              onTap: () {
                // TODO: navegar a detalle de venta
              },
            );
          },
        );
      },
    );
  }
}
