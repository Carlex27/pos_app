import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/resume/resume_dashboard.dart';
import '../widgets/dashboard/resume_dashboard.dart';
import '../../services/resume_service.dart';
import '../widgets/selector_date.dart';

/// Pantalla principal con indicadores y ventas recientes
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<ResumeDashboard>? _resumeFuture;
  DateTime _lastRequestedDate = DateTime.now();
  int? _lastRequestedYear;
  int? _lastRequestedMonth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadToday(DateTime.now());
  }

  void _loadToday(DateTime date) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _lastRequestedDate = date;
      _lastRequestedYear = null;
      _lastRequestedMonth = null;
    });

    _resumeFuture = ResumeService().fetchResumeDashboardByDay(date).then((data) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return data;
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading today data: $error');
      throw error;
    });
  }

  void _loadByDay(DateTime date) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _lastRequestedDate = date;
      _lastRequestedYear = null;
      _lastRequestedMonth = null;
    });

    _resumeFuture = ResumeService().fetchResumeDashboardByDay(date).then((data) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return data;
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading day data: $error');
      throw error;
    });
  }

  void _loadByMonth(int year, int month) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _lastRequestedYear = year;
      _lastRequestedMonth = month;
    });

    _resumeFuture = ResumeService().fetchResumeDashboardByMonth(DateTime(year, month)).then((data) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return data;
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading month data: $error');
      throw error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bienvenido, Admin Principal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Selector de fecha
            SelectorDate(
              onTodaySelected: _loadToday,
              onDaySelected: _loadByDay,
              onMonthSelected: _loadByMonth,
            ),

            const SizedBox(height: 1),

            // Contenido del dashboard
            _buildDashboardContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_resumeFuture == null) {
      return const Center(
        child: Text('Cargando datos...'),
      );
    }

    return FutureBuilder<ResumeDashboard>(
      future: _resumeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar los datos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadToday(DateTime.now()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 64),
                const SizedBox(height: 16),
                Text(
                  'No hay datos disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No se encontraron datos para el período seleccionado.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final resumeData = snapshot.data!;

        return Column(
          children: [
            // Widget reutilizable de resumen
            ResumeDashboardWidget(data: resumeData),

            const SizedBox(height: 32),

            // Ventas Recientes Section
            _buildSalesSection(resumeData),
          ],
        );
      },
    );
  }

  Widget _buildSalesSection(ResumeDashboard resumeData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ventas Recientes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          if (resumeData.ventasRecientes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      color: Colors.grey[400], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ventas recientes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...resumeData.ventasRecientes.asMap().entries.map((entry) {
              final index = entry.key;
              final venta = entry.value;
              final isLast = index == resumeData.ventasRecientes.length - 1;

              return Column(
                children: [
                  SaleTile(
                    customerName: venta.nombreCliente,
                    date: DateFormat('dd/MM/yyyy, hh:mm a').format(venta.fechaVenta),
                    amount: '\$${venta.totalVenta.toStringAsFixed(2)}',
                    items: '${venta.cantidadProductos} items',
                  ),
                  if (!isLast) const Divider(height: 24),
                ],
              );
            }),
        ],
      ),
    );
  }
}

/// Widget para mostrar una venta individual
class SaleTile extends StatelessWidget {
  final String customerName;
  final String date;
  final String amount;
  final String items;

  const SaleTile({
    required this.customerName,
    required this.date,
    required this.amount,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del cliente mejorado
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00D4AA).withOpacity(0.1),
                  const Color(0xFF00D4AA).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00D4AA).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.person_outline,
              color: const Color(0xFF00D4AA),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Información del cliente y fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        date,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Monto y cantidad de items mejorado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D4AA),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    items,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}