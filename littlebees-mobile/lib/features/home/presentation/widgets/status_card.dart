import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/i18n/app_translations.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../domain/child_status.dart';

class StatusCard extends ConsumerWidget {
  const StatusCard({super.key, required this.status});

  final ChildStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final theme = _statusTheme(status.status);
    final timeLabel = status.lastStatusChange != null
        ? TimeOfDay.fromDateTime(status.lastStatusChange!).format(context)
        : 'Sin hora';
    final responsibleLabel = switch (status.status) {
      ChildPresenceStatus.checkedIn =>
        status.checkedInBy?.trim().isNotEmpty == true
            ? status.checkedInBy!
            : 'Registro automático',
      ChildPresenceStatus.checkedOut =>
        status.checkedOutBy?.trim().isNotEmpty == true
            ? status.checkedOutBy!
            : 'Salida sin responsable',
      ChildPresenceStatus.absent => 'Sin asistencia registrada',
      ChildPresenceStatus.expected => 'Pendiente de llegada',
    };

    final subtitle = switch (status.status) {
      ChildPresenceStatus.checkedIn =>
        'Ingreso confirmado y visible para el colegio.',
      ChildPresenceStatus.checkedOut =>
        'Salida registrada y cerrada correctamente.',
      ChildPresenceStatus.absent =>
        'No hay check-in para este dia en el sistema.',
      ChildPresenceStatus.expected =>
        'Se espera la llegada del nino durante el dia.',
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surface,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.color.withAlpha(24),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(theme.icon, color: theme.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.label(tr),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatusDetail(
                  label: 'Hora',
                  value: timeLabel,
                  icon: LucideIcons.clock3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusDetail(
                  label: 'Registrado por',
                  value: responsibleLabel,
                  icon: LucideIcons.user,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDetail extends StatelessWidget {
  const _StatusDetail({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTheme {
  const _StatusTheme({
    required this.color,
    required this.surface,
    required this.border,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Color surface;
  final Color border;
  final IconData icon;
  final String Function(dynamic tr) label;
}

_StatusTheme _statusTheme(ChildPresenceStatus status) {
  switch (status) {
    case ChildPresenceStatus.checkedIn:
      return _StatusTheme(
        color: AppColors.success,
        surface: const Color(0xFFF3FAF2),
        border: const Color(0xFFD9EED7),
        icon: LucideIcons.badgeCheck,
        label: (tr) => tr.tr('checkedIn'),
      );
    case ChildPresenceStatus.checkedOut:
      return _StatusTheme(
        color: AppColors.info,
        surface: const Color(0xFFF2F7FB),
        border: const Color(0xFFD9E6F0),
        icon: LucideIcons.home,
        label: (tr) => tr.tr('checkedOut'),
      );
    case ChildPresenceStatus.absent:
      return const _StatusTheme(
        color: AppColors.warning,
        surface: Color(0xFFFFF8EA),
        border: Color(0xFFF2E4B7),
        icon: LucideIcons.calendarX2,
        label: _absentLabel,
      );
    case ChildPresenceStatus.expected:
      return const _StatusTheme(
        color: AppColors.primary,
        surface: Color(0xFFFCF7ED),
        border: Color(0xFFF2E2BF),
        icon: LucideIcons.sunMedium,
        label: _expectedLabel,
      );
  }
}

String _absentLabel(dynamic _) => 'Ausente';

String _expectedLabel(dynamic _) => 'Esperado hoy';
