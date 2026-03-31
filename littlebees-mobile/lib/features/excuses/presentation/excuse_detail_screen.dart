import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../application/excuses_provider.dart';
import '../../../shared/enums/enums.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../home/application/home_providers.dart';
import '../../notifications/application/notifications_provider.dart';

class ExcuseDetailScreen extends ConsumerWidget {
  final String excuseId;

  const ExcuseDetailScreen({
    super.key,
    required this.excuseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final canReview = authState.isDirector || authState.isAdmin;
    final excuseAsync = ref.watch(excuseDetailProvider(excuseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Justificante'),
        elevation: 0,
      ),
      body: SafeArea(
        child: excuseAsync.when(
          data: (excuse) {
            final dateFormat = DateFormat('dd MMMM yyyy', 'es');
            final timeFormat = DateFormat('HH:mm', 'es');

            Color statusColor;
            IconData statusIcon;
            String statusText;

            switch (excuse.status) {
              case ExcuseStatus.pending:
                statusColor = Colors.orange;
                statusIcon = LucideIcons.clock;
                statusText = 'Pendiente de revisión';
                break;
              case ExcuseStatus.approved:
                statusColor = Colors.green;
                statusIcon = LucideIcons.checkCircle;
                statusText = 'Aprobado';
                break;
              case ExcuseStatus.rejected:
                statusColor = Colors.red;
                statusIcon = LucideIcons.xCircle;
                statusText = 'Rechazado';
                break;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              if (excuse.reviewedAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Revisado el ${dateFormat.format(excuse.reviewedAt!)} a las ${timeFormat.format(excuse.reviewedAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Información del niño
                  LBCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.baby, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Información del niño',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Nombre', excuse.childName),
                        const SizedBox(height: 12),
                        _buildInfoRow('Fecha', dateFormat.format(excuse.date)),
                        const SizedBox(height: 12),
                        _buildInfoRow('Tipo', excuse.typeLabel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Detalles del justificante
                  LBCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.fileText, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Detalles',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          excuse.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (excuse.description != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            excuse.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Información de envío
                  LBCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.user, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Enviado por',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Nombre', excuse.submittedByName),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Fecha de envío',
                          '${dateFormat.format(excuse.createdAt)} a las ${timeFormat.format(excuse.createdAt)}',
                        ),
                      ],
                    ),
                  ),

                  // Notas de revisión (si existen)
                  if (excuse.reviewNotes != null) ...[
                    const SizedBox(height: 16),
                    LBCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.messageSquare, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Text(
                                'Notas de revisión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            excuse.reviewNotes!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          if (excuse.reviewedByName != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Por: ${excuse.reviewedByName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Botones de acción (dirección/administración y si está pendiente)
                  if (canReview && excuse.isPending) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showReviewDialog(
                              context,
                              ref,
                              excuseId,
                              ExcuseStatus.rejected,
                            ),
                            icon: const Icon(LucideIcons.xCircle),
                            label: const Text('Rechazar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showReviewDialog(
                              context,
                              ref,
                              excuseId,
                              ExcuseStatus.approved,
                            ),
                            icon: const Icon(LucideIcons.checkCircle),
                            label: const Text('Aprobar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(excuseDetailProvider(excuseId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showReviewDialog(
    BuildContext context,
    WidgetRef ref,
    String excuseId,
    ExcuseStatus status,
  ) {
    final notesController = TextEditingController();
    final isApproving = status == ExcuseStatus.approved;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isApproving ? 'Aprobar Justificante' : 'Rechazar Justificante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApproving
                  ? '¿Estás segura de aprobar este justificante?'
                  : '¿Estás segura de rechazar este justificante?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Notas (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              
              try {
                final notifier = ref.read(excusesNotifierProvider.notifier);
                await notifier.updateStatus(
                  id: excuseId,
                  status: status,
                  reviewNotes: notesController.text.isNotEmpty 
                      ? notesController.text 
                      : null,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isApproving 
                            ? 'Justificante aprobado' 
                            : 'Justificante rechazado',
                      ),
                      backgroundColor: isApproving ? Colors.green : Colors.red,
                    ),
                  );
                  
                  // Refresh the detail
                  ref.invalidate(excuseDetailProvider(excuseId));
                  ref.invalidate(excusesListProvider);
                  ref.invalidate(teacherDashboardProvider);
                  ref.invalidate(directorDashboardProvider);
                  ref.invalidate(todayRoleAttendanceProvider);
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(notificationUnreadCountProvider);
                  
                  // Go back after a short delay
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) {
                      context.pop();
                    }
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproving ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproving ? 'Aprobar' : 'Rechazar'),
          ),
        ],
      ),
    );
  }
}
