import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/models/salidas/salidas.dart';
import 'package:pos_app/services/salidas_service.dart';
import 'package:pos_app/ui/widgets/salidas/salidas_form.dart';
import 'package:pos_app/ui/widgets/salidas/salidas_tile.dart';
import 'package:pos_app/ui/widgets/selector_date.dart';

class SalidasScreen extends StatefulWidget {
  const SalidasScreen({Key? key}) : super(key: key);

  @override
  State<SalidasScreen> createState() => _SalidasScreenState();
}

class _SalidasScreenState extends State<SalidasScreen> {
  final SalidasService _service = SalidasService();
  List<Salidas> _salidas = [];
  bool _isLoading = false;
  String _currentPeriod = 'Hoy';
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  void _calculateTotal() {
    _totalAmount = _salidas.fold(0.0, (sum, salida) => sum + salida.amount);
  }

  Future<void> _loadToday() async {
    setState(() {
      _isLoading = true;
      _currentPeriod = 'Hoy';
    });
    try {
      final today = DateTime.now();
      final result = await _service.getSalidasByDate(today);
      setState(() {
        _salidas = result;
        _calculateTotal();
      });
    } catch (e) {
      debugPrint('Error cargando salidas de hoy: $e');
      _showErrorSnackBar('Error al cargar salidas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadByDay(DateTime date) async {
    setState(() {
      _isLoading = true;
      _currentPeriod = DateFormat('dd/MM/yyyy', 'es_MX').format(date);
    });
    try {
      final result = await _service.getSalidasByDate(date);
      setState(() {
        _salidas = result;
        _calculateTotal();
      });
    } catch (e) {
      debugPrint('Error cargando salidas por día: $e');
      _showErrorSnackBar('Error al cargar salidas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadByMonth(int year, int month) async {
    setState(() {
      _isLoading = true;
      _currentPeriod = DateFormat('MMM yyyy', 'es_MX').format(DateTime(year, month));
    });
    try {
      final date = DateTime(year, month);
      final result = await _service.fetchByMonth(date);
      setState(() {
        _salidas = result;
        _calculateTotal();
      });
    } catch (e) {
      debugPrint('Error cargando salidas por mes: $e');
      _showErrorSnackBar('Error al cargar salidas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openNewSalidaForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return SalidasForm(
          salidas: Salidas(
            id: 0,
            description: '',
            amount: 0.0,
            date: DateTime.now(),
          ),
          onSubmit: (newSalida) async {
            try {
              await _service.create(newSalida);
              Navigator.of(dialogContext).pop();
              await _loadToday();
              _showSuccessSnackBar('Salida creada exitosamente');
            } catch (error) {
              _showErrorSnackBar('Error al crear salida: $error');
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salidas'),
        backgroundColor: const Color(0xFFFFB74D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadToday,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen compacto
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPeriod,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_salidas.length} salidas • ${currencyFormatter.format(_totalAmount)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openNewSalidaForm,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nueva'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Selector de fecha compacto
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SelectorDate(
              onTodaySelected: (_) => _loadToday(),
              onDaySelected: _loadByDay,
              onMonthSelected: _loadByMonth,
            ),
          ),

          const Divider(height: 1),

          // Lista de salidas
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFB74D),
              ),
            )
                : _salidas.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay salidas registradas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _salidas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final salida = _salidas[index];
                return SalidasTile(
                  salida: salida,
                  onUpdate: (updated) async {
                    try {
                      await _service.update(updated, updated.id);
                      await _loadToday();
                      _showSuccessSnackBar('Salida actualizada');
                    } catch (e) {
                      _showErrorSnackBar('Error al actualizar: $e');
                    }
                  },
                  onDelete: () async {
                    try {
                      await _service.delete(salida.id);
                      await _loadToday();
                      _showSuccessSnackBar('Salida eliminada');
                    } catch (e) {
                      _showErrorSnackBar('Error al eliminar: $e');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}