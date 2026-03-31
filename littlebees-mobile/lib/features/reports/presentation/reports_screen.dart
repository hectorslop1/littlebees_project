import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_loading_state.dart';
import '../../../design_system/widgets/compact_layout.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../core/i18n/app_translations.dart';
import '../application/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final summaryAsync = ref.watch(reportsSummaryProvider);

    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      appBar: AppBar(title: Text(tr.tr('reports')), elevation: 0),
      body: SafeArea(
        child: summaryAsync.when(
          data: (summary) {
            final attendance =
                (summary['attendance'] as Map<String, dynamic>? ?? {});
            final activities =
                (summary['activities'] as Map<String, dynamic>? ?? {});
            final payments =
                (summary['payments'] as Map<String, dynamic>? ?? {});
            final groups = (attendance['groups'] as List? ?? const [])
                .whereType<Map<String, dynamic>>()
                .toList();
            final activityTypes =
                (activities['activitiesByType'] as List? ?? const [])
                    .whereType<Map<String, dynamic>>()
                    .toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(reportsSummaryProvider);
                await ref.read(reportsSummaryProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const CompactHeroCard(
                    eyebrow: 'Resumen operativo',
                    title: 'Reportes operativos',
                    subtitle:
                        'Consulta el pulso del dia: asistencia, actividad registrada y panorama de pagos.',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: LucideIcons.userCheck,
                          title: 'Asistencia',
                          value:
                              '${attendance['overall']?['averageAttendanceRate'] ?? 0}%',
                          caption: 'Promedio de hoy',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: LucideIcons.sparkles,
                          title: 'Actividad',
                          value: '${activities['totalActivities'] ?? 0}',
                          caption: 'Registros del día',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: LucideIcons.walletCards,
                          title: 'Cobrado',
                          value: '\$${payments['totalRevenue'] ?? 0}',
                          caption: 'Mes actual',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: LucideIcons.badgeAlert,
                          title: 'Pendiente',
                          value: '\$${payments['totalPending'] ?? 0}',
                          caption: 'Por cobrar',
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: 'Asistencia por grupo',
                    subtitle: 'Qué tan completa estuvo la llegada del día.',
                  ),
                  const SizedBox(height: 12),
                  if (groups.isEmpty)
                    const _InlineEmptyCard(
                      title: 'Sin datos de asistencia',
                      subtitle:
                          'Todavía no hay registros suficientes para mostrar este corte.',
                    )
                  else
                    ...groups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LBCard(
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  LucideIcons.layoutGrid,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${group['groupName'] ?? 'Grupo'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${group['totalChildren'] ?? 0} alumnos • ${group['averageAttendanceRate'] ?? 0}% de asistencia',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: 'Tipos de actividad',
                    subtitle: 'Qué estuvo registrando el equipo hoy.',
                  ),
                  const SizedBox(height: 12),
                  if (activityTypes.isEmpty)
                    const _InlineEmptyCard(
                      title: 'Sin actividad registrada',
                      subtitle:
                          'Cuando maestra o dirección registren eventos, aparecerán aquí.',
                    )
                  else
                    ...activityTypes.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LBCard(
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.secondarySurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  LucideIcons.sparkles,
                                  color: AppColors.secondary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  '${item['type']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${item['count'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const LBLoadingState(layout: LBLoadingLayout.cards),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.alertTriangle,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No fue posible cargar reportes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(reportsSummaryProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _InlineEmptyCard extends StatelessWidget {
  const _InlineEmptyCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LBCard(
      child: Column(
        children: [
          const Icon(
            LucideIcons.inbox,
            size: 36,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
