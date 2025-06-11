import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectorMonth extends StatefulWidget {
  final void Function(int year, int month) onMonthSelected;

  const SelectorMonth({
    Key? key,
    required this.onMonthSelected,
  }) : super(key: key);

  @override
  State<SelectorMonth> createState() => _SelectorMonthState();
}

class _SelectorMonthState extends State<SelectorMonth> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  void _pickMonth() async {
    final List<int> years = List.generate(10, (i) => DateTime.now().year - i);
    int selectedYear = _selectedYear;
    int selectedMonth = _selectedMonth;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Seleccionar Período',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elige el año y mes',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (value) => setInnerState(() => selectedYear = value!),
                          items: years.map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y'),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (value) => setInnerState(() => selectedMonth = value!),
                          items: List.generate(12, (i) => i + 1)
                              .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(DateFormat.MMMM('es').format(DateTime(0, m))),
                          ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedYear = selectedYear;
                              _selectedMonth = selectedMonth;
                            });
                            widget.onMonthSelected(_selectedYear, _selectedMonth);
                            Navigator.pop(context);
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _pickMonth,
      icon: const Icon(Icons.calendar_month),
      label: Text(
        'Mes: ${DateFormat('MMMM yyyy', 'es').format(DateTime(_selectedYear, _selectedMonth))}',
      ),
    );
  }
}
