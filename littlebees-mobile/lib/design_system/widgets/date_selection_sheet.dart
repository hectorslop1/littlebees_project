import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/utils/date_utils.dart';
import '../theme/app_colors.dart';

Future<DateTime?> showDateSelectionSheet({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final today = normalizeDate(DateTime.now());
  final resolvedFirstDate = normalizeDate(
    firstDate ?? DateTime(today.year - 1, today.month, today.day),
  );
  final resolvedLastDate = normalizeDate(lastDate ?? today);
  final safeInitialDate = normalizeDate(
    initialDate.isBefore(resolvedFirstDate)
        ? resolvedFirstDate
        : initialDate.isAfter(resolvedLastDate)
        ? resolvedLastDate
        : initialDate,
  );

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DateSelectionSheet(
      initialDate: safeInitialDate,
      firstDate: resolvedFirstDate,
      lastDate: resolvedLastDate,
    ),
  );
}

class _DateSelectionSheet extends StatefulWidget {
  const _DateSelectionSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_DateSelectionSheet> createState() => _DateSelectionSheetState();
}

class _DateSelectionSheetState extends State<_DateSelectionSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColor(AppColors.surface),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.appColor(AppColors.border),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.appColor(AppColors.primarySurface),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        LucideIcons.calendarDays,
                        color: context.appColor(AppColors.primary),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar fecha',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: context.appColor(AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatLongDateLabel(_selectedDate, locale: locale),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.appColor(AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickDateChip(
                      label: 'Hoy',
                      selected: isToday(_selectedDate),
                      onTap: () {
                        setState(() {
                          _selectedDate = normalizeDate(DateTime.now());
                        });
                      },
                    ),
                    _QuickDateChip(
                      label: 'Ayer',
                      selected: isSameLogicalDay(
                        _selectedDate,
                        DateTime.now().subtract(const Duration(days: 1)),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDate = normalizeDate(
                            DateTime.now().subtract(const Duration(days: 1)),
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.appColor(AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    onDateChanged: (date) {
                      setState(() {
                        _selectedDate = normalizeDate(date);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appColor(
                            AppColors.textPrimary,
                          ),
                          side: BorderSide(
                            color: context.appColor(AppColors.border),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(normalizeDate(_selectedDate)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColor(AppColors.primary),
                          foregroundColor: context.appColor(
                            AppColors.textOnPrimary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isToday(_selectedDate)
                              ? 'Ver HOY'
                              : 'Ver ${formatShortDateLabel(_selectedDate, locale: locale)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.appColor(AppColors.primarySurface)
          : context.appColor(AppColors.surfaceVariant),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? context.appColor(AppColors.primary)
                  : context.appColor(AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
