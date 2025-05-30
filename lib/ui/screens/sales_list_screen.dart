import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sale_service.dart';
import '../../models/sale_response.dart';
import '../widgets/sale_tile.dart';
import '../widgets/selector_date.dart';
import '../widgets/resume_ventas_wg.dart';
import '../../services/resume_service.dart';
import '../../models/resume_ventas.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late Future<List<SaleResponse>> _futureSales;
  late Future<ResumeVentas> _futureResumen;
  String _selectedType = 'hoy';
  DateTime? _selectedDate;
  DateTime? _selectedMonth;


  Future<List<SaleResponse>> _fetchSales() {
    final service = Provider.of<SaleService>(context, listen: false);

    if (_selectedType == 'hoy' && _selectedDate != null) {
      return service.fetchByDay(_selectedDate!);
    } else if (_selectedType == 'dia' && _selectedDate != null) {
      return service.fetchByDay(_selectedDate!);
    } else if (_selectedType == 'mes' && _selectedMonth != null) {
      return service.fetchByMonth(_selectedMonth!);
    } else {
      return service.fetchAll();
    }
  }

  Future<ResumeVentas> _fetchResumen(DateTime date) async {
    try {
      final service = Provider.of<ResumeService>(context, listen: false);

      if (_selectedType == 'mes') {
        final result = await service.fetchResumeVentasByMonth(date);

        // Debug: Imprimir respuesta del mes
        debugPrint('Resumen mes - Total ventas: ${result.totalVentas}, Total ingresos: ${result.totalIngresos}');

        return result;
      } else {
        final result = await service.fetchResumeVentasByDay(date);
        debugPrint('Resumen día - Total ventas: ${result.totalVentas}, Total ingresos: ${result.totalIngresos}');
        return result;
      }
    } catch (e) {
      debugPrint('Error en _fetchResumen: $e');
      // En caso de error, devolver valores en cero para que el widget se muestre
      return ResumeVentas(totalVentas: 0, totalIngresos: 0.0);
    }
  }


  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _futureSales = _fetchSales();
    _futureResumen = _fetchResumen(now);
  }

  void _onTodaySelected(DateTime today) {
    setState(() {
      _selectedType = 'hoy';
      _selectedDate = today;
      _futureSales = _fetchSales();
      _futureResumen = _fetchResumen(today);
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedType = 'dia';
      _selectedDate = date;
      _futureSales = _fetchSales();
      _futureResumen = _fetchResumen(date);
    });
  }

  void _onMonthSelected(int year, int month) {
    final date = DateTime(year, month);
    setState(() {
      _selectedType = 'mes';
      _selectedMonth = date;
      _futureSales = _fetchSales();
      _futureResumen = _fetchResumen(date);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ventas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectorDate(
                    onTodaySelected: _onTodaySelected,
                    onDaySelected: _onDaySelected,
                    onMonthSelected: _onMonthSelected,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<ResumeVentas>(
                    future: _futureResumen,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const SizedBox();
                      }
                      return ResumeVentasWd(data: snapshot.data!);
                    },
                  ),
                ],
              ),
            ),

            // Lista de ventas
            Expanded(
              child: FutureBuilder<List<SaleResponse>>(
                future: _futureSales,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \${snapshot.error}'));
                  }
                  final sales = snapshot.data!;
                  if (sales.isEmpty) {
                    return const Center(child: Text('No hay ventas registradas.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sales.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SaleTile(sale: sales[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
