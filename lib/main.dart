// main.dart
import 'package:flutter/material.dart';
import 'package:pos_app/services/client_service.dart';
import 'package:pos_app/services/department_service.dart';
import 'package:pos_app/services/resume_service.dart';
import 'package:pos_app/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/sale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Si aún no lo tienes
  await initializeDateFormatting('es_ES', null);
  runApp(PosApp());
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
        Provider<ResumeService>(create: (_) => ResumeService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<DepartmentService>(create: (_) => DepartmentService()),
        Provider<ClientService>(create: (_) => ClientService()),
      ],
      child: MaterialApp(
        title: 'POS Cervecería',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''), // Español
          Locale('en', ''), // Inglés (opcional)
        ],
        initialRoute: '/login',
        routes: {
          '/login': (ctx) => const LoginScreen(),
          '/home':  (ctx) => const HomeScreen(),
        },
      ),

    );

  }


}
