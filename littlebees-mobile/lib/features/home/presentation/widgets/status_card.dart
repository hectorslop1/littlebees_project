import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/i18n/app_translations.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../domain/child_status.dart';

class StatusCard extends ConsumerWidget {
  const StatusCard({
    super.key,
    required this.status,
  });

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
      ChildPresenceStatus.absent =>
        status.checkedInBy?.trim().isNotEmpty == true
            ? status.checkedInBy!
            : 'Pendiente de registro',
      ChildPresenceStatus.expected => 'Pendiente de llegada',
    };

    final subtitle = switch (status.status) {
      ChildPresenceStatus.checkedIn =>
        'La maestra ya confirmó la llegada del niño.',
      ChildPresenceStatus.checkedOut =>
        'Salida registrada y cerrada correctamente.',
      ChildPresenceStatus.absent =>
        status.checkedInBy?.trim().isNotEmpty == true
            ? 'No llego a clase. Registro capturado por la profesora.'
            : 'Todavia no se registra la llegada del niño.',
      ChildPresenceStatus.expected =>
        'La llegada sigue pendiente de confirmacion por la maestra.',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surfaceFor(context),
            context.appColor(AppColors.surface),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderFor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(context.isDark ? 28 : 20),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.color.withAlpha(24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(theme.icon, color: theme.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.label(tr),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: context.appColor(AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                flex: 2,
                child: _StatusDetail(
                  label: 'Hora',
                  value: timeLabel,
                  icon: LucideIcons.clock3,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 3,
                child: _StatusDetail(
                  label: null,
                  value: responsibleLabel,
                  icon: LucideIcons.user,
                  emphasizeValue: true,
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
    this.label,
    required this.value,
    required this.icon,
    this.emphasizeValue = false,
  });

  final String? label;
  final String value;
  final IconData icon;
  final bool emphasizeValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surface).withAlpha(
          context.isDark ? 255 : 220,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColor(AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: context.appColor(AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  if (label != null)
                    TextSpan(
                      text: '$label: ',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: context.appColor(AppColors.textSecondary),
                      ),
                    ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: emphasizeValue ? 12.5 : 11.5,
                      fontWeight: FontWeight.w700,
                      color: context.appColor(AppColors.textPrimary),
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

  Color surfaceFor(BuildContext context) =>
      context.isDark ? context.appColor(AppColors.surfaceVariant) : surface;

  Color borderFor(BuildContext context) =>
      context.isDark ? context.appColor(AppColors.border) : border;
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
