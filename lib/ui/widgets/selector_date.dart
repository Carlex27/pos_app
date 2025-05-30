import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectorDate extends StatefulWidget {
  final void Function(DateTime) onTodaySelected;
  final void Function(DateTime) onDaySelected;
  final void Function(int year, int month) onMonthSelected;

  const SelectorDate({
    Key? key,
    required this.onTodaySelected,
    required this.onDaySelected,
    required this.onMonthSelected,
  }) : super(key: key);

  @override
  State<SelectorDate> createState() => _SelectorDateState();
}

class _SelectorDateState extends State<SelectorDate> {
  int _selectedIndex = 0;
  DateTime _selectedDay = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  void _selectToday() {
    final today = DateTime.now();
    setState(() {
      _selectedIndex = 0;
      _selectedDay = today;
    });
    widget.onTodaySelected(today);
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', ''),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF7043),
              primary: const Color(0xFFFF7043),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked;
        _selectedIndex = 1;
      });
      widget.onDaySelected(picked);
    }
  }

  void _pickMonth() async {
    final List<int> years = List.generate(10, (i) => DateTime.now().year - i);
    int? selectedYear = _selectedYear;
    int? selectedMonth = _selectedMonth;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Selecciona mes y año',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8D4E2A),
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de Año
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButton<int>(
                  value: selectedYear,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  onChanged: (value) => setState(() => selectedYear = value!),
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Selector de Mes
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButton<int>(
                  value: selectedMonth,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  onChanged: (value) => setState(() => selectedMonth = value!),
                  items: List.generate(12, (i) => i + 1)
                      .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(DateFormat.MMMM('es').format(DateTime(0, m))),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              setState(() {
                _selectedYear = selectedYear!;
                _selectedMonth = selectedMonth!;
                _selectedIndex = 2;
              });
              widget.onMonthSelected(_selectedYear, _selectedMonth);
              Navigator.pop(context);
            },
            child: const Text(
              'Aceptar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = _selectedIndex == 0
        ? 'Mostrando ventas de hoy: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}'
        : _selectedIndex == 1
        ? 'Mostrando ventas del día: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}'
        : 'Mostrando ventas del mes: ${DateFormat('MMMM yyyy', 'es').format(DateTime(_selectedYear, _selectedMonth))}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tabs de selección
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildTab('Hoy', 0, _selectToday),
                  _buildTab('Por Día', 1, _pickDate),
                  _buildTab('Por Mes', 2, _pickMonth),
                ],
              ),
            ),
          ),

          // Texto descriptivo
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: const Color(0xFF8D4E2A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8D4E2A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, VoidCallback onTap) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFFF7043) : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}