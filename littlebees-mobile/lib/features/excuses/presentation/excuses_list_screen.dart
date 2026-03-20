import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../application/excuses_provider.dart';
import '../../../shared/enums/enums.dart';
import 'package:intl/intl.dart';

class ExcusesListScreen extends ConsumerStatefulWidget {
  const ExcusesListScreen({super.key});

  @override
  ConsumerState<ExcusesListScreen> createState() => _ExcusesListScreenState();
}

class _ExcusesListScreenState extends ConsumerState<ExcusesListScreen> {
  ExcuseStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isTeacher =
        authState.isTeacher || authState.isDirector || authState.isAdmin;

    final filters = ExcusesFilters(status: _selectedStatus);
    final excusesAsync = ref.watch(excusesListProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'Justificantes' : 'Mis Justificantes'),
        elevation: 0,
        actions: [
          PopupMenuButton<ExcuseStatus?>(
            icon: const Icon(LucideIcons.filter),
            onSelected: (status) {
              setState(() => _selectedStatus = status);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text('Todos')),
              PopupMenuItem(
                value: ExcuseStatus.pending,
                child: Row(
                  children: [
                    Icon(LucideIcons.clock, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('Pendientes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ExcuseStatus.approved,
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.checkCircle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text('Aprobados'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ExcuseStatus.rejected,
                child: Row(
                  children: [
                    Icon(LucideIcons.xCircle, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Rechazados'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: excusesAsync.when(
          data: (excuses) {
            if (excuses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedStatus == null
                          ? 'No hay justificantes'
                          : 'No hay justificantes ${_selectedStatus == ExcuseStatus.pending
                                ? "pendientes"
                                : _selectedStatus == ExcuseStatus.approved
                                ? "aprobados"
                                : "rechazados"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(excusesListProvider(filters).future),
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: excuses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final excuse = excuses[index];
                  return _buildExcuseCard(excuse, isTeacher);
                },
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
                    onPressed: () => ref.refresh(excusesListProvider(filters)),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: !isTeacher
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/excuses/create'),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Nuevo'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildExcuseCard(excuse, bool isTeacher) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    Color statusColor = Colors.grey;
    IconData statusIcon = LucideIcons.circle;

    switch (excuse.status) {
      case ExcuseStatus.pending:
        statusColor = Colors.orange;
        statusIcon = LucideIcons.clock;
        break;
      case ExcuseStatus.approved:
        statusColor = Colors.green;
        statusIcon = LucideIcons.checkCircle;
        break;
      case ExcuseStatus.rejected:
        statusColor = Colors.red;
        statusIcon = LucideIcons.xCircle;
        break;
    }

    return LBCard(
      onTap: () => context.push('/excuses/${excuse.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      excuse.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      excuse.typeLabel,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(excuse.date),
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 24),
              if (isTeacher) ...[
                Icon(
                  LucideIcons.user,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    excuse.childName,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (excuse.isPending && isTeacher) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.alertCircle, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Requiere revisión',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
