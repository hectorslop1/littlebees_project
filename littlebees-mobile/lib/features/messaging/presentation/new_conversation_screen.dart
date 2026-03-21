import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../shared/enums/enums.dart';
import '../../auth/application/auth_provider.dart';
import '../../home/application/home_providers.dart';

class NewConversationScreen extends ConsumerWidget {
  const NewConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Conversación'), elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // For Parents: Show teachers of their children + director
            if (user?.role == UserRole.parent) ...[
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Maestras de mis hijos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              childrenAsync.when(
                data: (children) {
                  // Get unique teachers from children's groups
                  final teachers = <String, Map<String, dynamic>>{};
                  for (final child in children) {
                    if (child.groupName != null &&
                        child.groupName!.isNotEmpty) {
                      // This is a placeholder - in real implementation,
                      // you'd fetch teacher info from the group
                      teachers['teacher_${child.groupName}'] = {
                        'id': 'teacher_${child.groupName}',
                        'name': 'Maestra de ${child.groupName}',
                        'role': 'Maestra',
                      };
                    }
                  }

                  if (teachers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No hay maestras asignadas',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return Column(
                    children: teachers.values.map((teacher) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildContactCard(
                          context,
                          ref,
                          teacher['id'] as String,
                          teacher['name'] as String,
                          teacher['role'] as String,
                          LucideIcons.graduationCap,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Administración',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildContactCard(
                context,
                ref,
                'director',
                'Director',
                'Administración',
                LucideIcons.briefcase,
              ),
            ],

            // For Teachers: Show parents of their students + director
            if (user?.role == UserRole.teacher) ...[
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Padres de mis alumnos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              childrenAsync.when(
                data: (children) {
                  if (children.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No hay alumnos asignados',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return Column(
                    children: children.map((child) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildContactCard(
                          context,
                          ref,
                          'parent_${child.id}',
                          'Padres de ${child.firstName} ${child.lastName}',
                          'Familia',
                          LucideIcons.users,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Administración',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildContactCard(
                context,
                ref,
                'director',
                'Director',
                'Administración',
                LucideIcons.briefcase,
              ),
            ],

            // For Director/Admin: Show all teachers and parents
            if (user?.role == UserRole.director ||
                user?.role == UserRole.admin ||
                user?.role == UserRole.superAdmin) ...[
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Personal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildContactCard(
                context,
                ref,
                'all_teachers',
                'Maestras',
                'Ver todas las maestras',
                LucideIcons.graduationCap,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Familias',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildContactCard(
                context,
                ref,
                'all_parents',
                'Padres',
                'Ver todos los padres',
                LucideIcons.users,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String name,
    String subtitle,
    IconData icon,
  ) {
    return LBCard(
      onTap: () {
        // Show info dialog since backend endpoint doesn't exist yet
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Funcionalidad en desarrollo'),
            content: Text(
              'La mensajería con $name estará disponible próximamente.\n\n'
              'El backend necesita implementar el endpoint POST /conversations para crear conversaciones.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
