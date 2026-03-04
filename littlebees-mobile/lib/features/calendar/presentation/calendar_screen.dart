import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/widgets/lb_card.dart';
import '../../../../core/i18n/app_translations.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr.tr('agenda')),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _calendarFormat == CalendarFormat.week
                  ? LucideIcons.calendarDays
                  : LucideIcons.calendar,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.week
                    ? CalendarFormat.month
                    : CalendarFormat.week;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    leftChevronIcon: const Icon(
                      LucideIcons.chevronLeft,
                      color: AppColors.textSecondary,
                    ),
                    rightChevronIcon: const Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Text(
                    _selectedDay != null
                        ? DateFormat('EEEE, MMMM d').format(_selectedDay!)
                        : 'Schedule',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate(key: ValueKey(_selectedDay)).fadeIn().slideX(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8,
                ),
                children: [
                  _buildAgendaItem(
                    time: '09:00 AM',
                    endTime: '10:00 AM',
                    title: 'Morning Circle & Songs 🎵',
                    description: 'Interactive group activity',
                    color: AppColors.primary,
                    icon: LucideIcons.music,
                    index: 0,
                  ),
                  _buildAgendaItem(
                    time: '10:30 AM',
                    endTime: '11:15 AM',
                    title: 'Art Creation 🎨',
                    description: 'Finger painting session',
                    color: AppColors.info,
                    icon: LucideIcons.palette,
                    index: 1,
                  ),
                  _buildAgendaItem(
                    time: '12:00 PM',
                    endTime: '12:30 PM',
                    title: 'Lunch Time 🍱',
                    description: 'Healthy meals in the cafeteria',
                    color: AppColors.warning,
                    icon: LucideIcons.utensils,
                    index: 2,
                  ),
                  _buildAgendaItem(
                    time: '02:00 PM',
                    endTime: 'All Day',
                    title: 'Monthly Payment Due 💳',
                    description: 'Please process via the app',
                    color: AppColors.error,
                    icon: LucideIcons.creditCard,
                    index: 3,
                    isImportant: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaItem({
    required String time,
    required String endTime,
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required int index,
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child:
          IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            time.split(' ')[0],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isImportant
                                  ? color
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            time.split(' ').length > 1
                                ? time.split(' ')[1]
                                : '',
                            style: TextStyle(
                              color: isImportant
                                  ? color
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isImportant
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          if (endTime.isNotEmpty) ...[
                            Text(
                              endTime.split(' ')[0],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              endTime.split(' ').length > 1
                                  ? endTime.split(' ')[1]
                                  : '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(100),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 2,
                            decoration: BoxDecoration(
                              color: color.withAlpha(isImportant ? 200 : 50),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LBCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(key: ValueKey('$_selectedDay-$index'))
              .fadeIn(delay: (index * 50).ms, duration: 400.ms)
              .slideX(begin: 0.1, curve: Curves.easeOutQuad),
    );
  }
}
