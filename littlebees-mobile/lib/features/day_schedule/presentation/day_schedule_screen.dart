import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/providers/groups_provider.dart';
import '../../register_activity/presentation/quick_register_screen.dart';

class DayScheduleScreen extends ConsumerStatefulWidget {
  const DayScheduleScreen({super.key});

  @override
  ConsumerState<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends ConsumerState<DayScheduleScreen> {
  String? selectedGroupId;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Cargar grupos al iniciar
    Future.microtask(() => ref.read(groupsProvider.notifier).loadGroups());
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);
    final childrenState = ref.watch(childrenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTranslations.daySchedule),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de grupo
          _buildGroupSelector(groupsState),

          // Fecha seleccionada
          _buildDateHeader(),

          // Contenido principal
          Expanded(
            child: selectedGroupId == null
                ? _buildEmptyState()
                : _buildScheduleContent(childrenState),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelector(GroupsState groupsState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppTranslations.selectGroup,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (groupsState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (groupsState.error != null)
            Text(
              groupsState.error!,
              style: const TextStyle(color: AppColors.error),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: selectedGroupId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text(AppTranslations.selectGroup),
              items: groupsState.groups.map((group) {
                return DropdownMenuItem(
                  value: group.id,
                  child: Text(group.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGroupId = value;
                });
                if (value != null) {
                  ref
                      .read(childrenProvider.notifier)
                      .loadChildren(groupId: value);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surfaceVariant,
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(selectedDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            AppTranslations.selectGroup,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona un grupo para ver la programación del día',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(ChildrenState childrenState) {
    if (childrenState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (childrenState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              childrenState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedGroupId != null) {
                  ref
                      .read(childrenProvider.notifier)
                      .loadChildren(groupId: selectedGroupId!);
                }
              },
              child: const Text(AppTranslations.retry),
            ),
          ],
        ),
      );
    }

    final children = childrenState.children;

    if (children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.noData,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Estadísticas
        _buildStats(children.length),

        // Timeline del día
        _buildTimeline(),

        // Lista de niños
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return _buildChildCard(children[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats(int totalChildren) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            label: AppTranslations.total,
            value: totalChildren.toString(),
            color: AppColors.primary,
            icon: Icons.group,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            label: AppTranslations.present,
            value: '0', // TODO: Calcular desde datos reales
            color: AppColors.success,
            icon: Icons.check_circle,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            label: AppTranslations.absent,
            value: '0', // TODO: Calcular desde datos reales
            color: AppColors.error,
            icon: Icons.cancel,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final scheduleItems = [
      {'time': '07:30', 'label': AppTranslations.checkIn},
      {'time': '09:00', 'label': AppTranslations.meal},
      {'time': '11:00', 'label': AppTranslations.activity},
      {'time': '13:00', 'label': AppTranslations.nap},
      {'time': '15:00', 'label': AppTranslations.meal},
      {'time': '16:00', 'label': AppTranslations.checkOut},
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: scheduleItems.length,
        itemBuilder: (context, index) {
          final item = scheduleItems[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['time']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['label']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChildCard(Child child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openQuickRegister(child),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withAlpha(51),
                child: child.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          child.avatarUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        child.initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Nombre
              Expanded(
                child: Text(
                  child.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Indicadores de actividades
              _buildActivityIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIndicators() {
    return Row(
      children: [
        _buildActivityDot(AppColors.checkIn, false),
        const SizedBox(width: 4),
        _buildActivityDot(AppColors.meal, false),
        const SizedBox(width: 4),
        _buildActivityDot(AppColors.nap, false),
        const SizedBox(width: 4),
        _buildActivityDot(AppColors.activity, false),
        const SizedBox(width: 4),
        _buildActivityDot(AppColors.checkOut, false),
      ],
    );
  }

  Widget _buildActivityDot(Color color, bool completed) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: completed ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }

  void _openQuickRegister(Child child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuickRegisterScreen(childId: child.id, childName: child.fullName),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Recargar datos para la nueva fecha
      if (selectedGroupId != null) {
        ref
            .read(childrenProvider.notifier)
            .loadChildren(groupId: selectedGroupId!);
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      AppTranslations.january,
      AppTranslations.february,
      AppTranslations.march,
      AppTranslations.april,
      AppTranslations.may,
      AppTranslations.june,
      AppTranslations.july,
      AppTranslations.august,
      AppTranslations.september,
      AppTranslations.october,
      AppTranslations.november,
      AppTranslations.december,
    ];

    return '${date.day} de ${months[date.month]} ${date.year}';
  }
}
