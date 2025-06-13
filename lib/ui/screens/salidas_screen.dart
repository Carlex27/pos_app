import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    setState(() => _isLoading = true);
    try {
      final today = DateTime.now();
      final result = await _service.getSalidasByDate(today);
      setState(() => _salidas = result);
    } catch (e) {
      debugPrint('Error cargando salidas de hoy: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadByDay(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getSalidasByDate(date);
      setState(() => _salidas = result);
    } catch (e) {
      debugPrint('Error cargando salidas por día: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadByMonth(int year, int month) async {
    setState(() => _isLoading = true);
    try {
      final date = DateTime(year, month);
      final result = await _service.fetchByMonth(date);
      setState(() => _salidas = result);
    } catch (e) {
      debugPrint('Error cargando salidas por mes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openNewSalidaForm() {
    final currentContext = context;

    showDialog(
      context: currentContext,
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
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
              if (mounted) {
                await _loadToday();
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Salida creada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (error) {
              if (mounted) {
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  SnackBar(
                    content: Text('Error al crear salida: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salidas'),
        backgroundColor: Colors.orange[400],
        elevation: 0,
      ),
      body: Column(
        children: [
          SelectorDate(
            onTodaySelected: (_) => _loadToday(),
            onDaySelected: _loadByDay,
            onMonthSelected: _loadByMonth,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _salidas.isEmpty
                ? const Center(child: Text('No hay salidas disponibles'))
                : ListView.builder(
              itemCount: _salidas.length,
              itemBuilder: (context, index) {
                final salida = _salidas[index];
                return SalidasTile(
                  salida: salida,
                  onUpdate: (updated) async {
                    await _service.update(updated, updated.id);
                    await _loadToday();
                  },
                  onDelete: () async {
                    await _service.delete(salida.id);
                    await _loadToday();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _openNewSalidaForm,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Agregar nueva salida',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
