import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectorDay extends StatefulWidget {
  final DateTime initialDate;
  final void Function(DateTime) onDaySelected;

  const SelectorDay({
    Key? key,
    required this.initialDate,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  State<SelectorDay> createState() => _SelectorDayState();
}

class _SelectorDayState extends State<SelectorDay> {
  DateTime? selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _currentMonth = widget.initialDate;
  }

  List<DateTime> _getDaysOfMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    return List.generate(42, (i) => startDate.add(Duration(days: i)));
  }

  void _navigateMonth(bool next) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + (next ? 1 : -1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysOfMonth(_currentMonth);
    final today = DateTime.now();

    return Dialog(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    'Seleccionar Fecha',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige un día para ver las ventas',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            // Mes y navegación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Color(0xFFFF7043)),
                    onPressed: () => _navigateMonth(false),
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'es').format(_currentMonth),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Color(0xFFFF7043)),
                    onPressed: () => _navigateMonth(true),
                  ),
                ],
              ),
            ),

            // Días de la semana
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                    .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),

            // Calendario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrentMonth = day.month == _currentMonth.month;
                  final isSelected = selectedDate != null &&
                      day.year == selectedDate!.year &&
                      day.month == selectedDate!.month &&
                      day.day == selectedDate!.day;
                  final isToday = day.year == today.year &&
                      day.month == today.month &&
                      day.day == today.day;
                  final isPast = day.isAfter(today);

                  return GestureDetector(
                    onTap: isCurrentMonth && !isPast
                        ? () {
                      setState(() {
                        selectedDate = day;
                      });
                      widget.onDaySelected(day);
                      Navigator.pop(context);
                    }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF7043)
                            : isToday && isCurrentMonth
                            ? const Color(0xFFFF7043).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday && isCurrentMonth && !isSelected
                            ? Border.all(color: const Color(0xFFFF7043), width: 1)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : !isCurrentMonth
                                ? Colors.grey[300]
                                : isPast
                                ? Colors.grey[400]
                                : isToday
                                ? const Color(0xFFFF7043)
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Fecha seleccionada
            if (selectedDate != null)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.indigo.shade50],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.today, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha seleccionada',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'es').format(selectedDate!),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
