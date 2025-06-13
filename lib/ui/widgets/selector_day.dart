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

class _SelectorDayState extends State<SelectorDay> with TickerProviderStateMixin {
  DateTime? selectedDate;
  late DateTime _currentMonth;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _currentMonth = widget.initialDate;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar la animación después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Usar AlertDialog en lugar de Dialog para mejor compatibilidad
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con gradiente glassmorphism
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                      const Color(0xFF6366F1).withOpacity(0.8),
                      const Color(0xFF8B5CF6).withOpacity(0.8),
                      const Color(0xFFA855F7).withOpacity(0.8),
                    ]
                        : [
                      const Color(0xFF667EEA),
                      const Color(0xFF764BA2),
                      const Color(0xFF6B46C1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Seleccionar Fecha',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige un día para ver las ventas',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Navegación del mes con estilo minimalista
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(Icons.chevron_left_rounded, () => _navigateMonth(false), isDarkMode),
                    Expanded(
                      child: Center(
                        child: Text(
                          DateFormat('MMMM yyyy', 'es').format(_currentMonth),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    _buildNavButton(Icons.chevron_right_rounded, () => _navigateMonth(true), isDarkMode),
                  ],
                ),
              ),

              // Días de la semana con mejor tipografía
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                      .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.6)
                              : const Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),

              // Calendario con animaciones suaves
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
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

                    return _buildDayCell(day, isCurrentMonth, isSelected, isToday, isPast, isDarkMode);
                  },
                ),
              ),

              // Fecha seleccionada con diseño card mejorado
              if (selectedDate != null)
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                        const Color(0xFF374151).withOpacity(0.8),
                        const Color(0xFF4B5563).withOpacity(0.6),
                      ]
                          : [
                        const Color(0xFFF8FAFC),
                        const Color(0xFFE2E8F0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha seleccionada',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.7)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'es').format(selectedDate!),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            icon,
            color: isDarkMode ? Colors.white : const Color(0xFF374151),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isCurrentMonth, bool isSelected,
      bool isToday, bool isPast, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCurrentMonth && !isPast
            ? () {
          setState(() {
            selectedDate = day;
          });
          widget.onDaySelected(day);
          //Navigator.pop(context);
        }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            )
                : isToday && isCurrentMonth
                ? LinearGradient(
              colors: isDarkMode
                  ? [
                const Color(0xFF667EEA).withOpacity(0.2),
                const Color(0xFF764BA2).withOpacity(0.1),
              ]
                  : [
                const Color(0xFF667EEA).withOpacity(0.1),
                const Color(0xFF764BA2).withOpacity(0.05),
              ],
            )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: isToday && isCurrentMonth && !isSelected
                ? Border.all(
              color: const Color(0xFF667EEA).withOpacity(0.5),
              width: 2,
            )
                : null,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : !isCurrentMonth
                    ? (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300)
                    : isPast
                    ? (isDarkMode ? Colors.white.withOpacity(0.3) : Colors.grey.shade400)
                    : isToday
                    ? const Color(0xFF667EEA)
                    : isDarkMode
                    ? Colors.white
                    : const Color(0xFF374151),
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}