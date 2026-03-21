import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../application/activity_controller.dart';
import 'widgets/photo_grid.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../../design_system/widgets/lb_empty_state.dart';
import '../../../../design_system/widgets/lb_error_state.dart';
import '../../auth/application/auth_provider.dart';
import 'create_activity_screen.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool _isPhotosTab = true;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(photosProvider);
    final tr = ref.watch(translationsProvider);
    final authState = ref.watch(authProvider);
    final isTeacher =
        authState.isTeacher || authState.isDirector || authState.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.tr('activity')),
        actions: [
          if (isTeacher)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Nueva'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateActivityScreen(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPhotosTab = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isPhotosTab
                                ? AppColors.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isPhotosTab
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              '📸 ${tr.tr('photos')}',
                              style: TextStyle(
                                fontWeight: _isPhotosTab
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _isPhotosTab
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPhotosTab = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isPhotosTab
                                ? AppColors.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_isPhotosTab
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              '📋 ${tr.tr('activityLog')}',
                              style: TextStyle(
                                fontWeight: !_isPhotosTab
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: !_isPhotosTab
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isPhotosTab
                  ? photosAsync.when(
                      data: (photos) {
                        final bool isTeacherRole = isTeacher;
                        if (photos.isEmpty) {
                          return LBEmptyState(
                            icon: LucideIcons.image,
                            title: isTeacherRole
                                ? tr.tr('noPhotosTeacher')
                                : tr.tr('noPhotosParent'),
                            message: isTeacherRole
                                ? tr.tr('noPhotosTeacherMsg')
                                : tr.tr('noPhotosParentMsg'),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () => ref.refresh(photosProvider.future),
                          child: PhotoGrid(photos: photos),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => LBErrorState(
                        title: tr.tr('errorLoadingPhotos'),
                        message: tr.tr('errorLoadingPhotosMsg'),
                        onRetry: () => ref.refresh(photosProvider),
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.clipboard,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tr.tr('activityLogTitle'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isTeacher
                                  ? '${tr.tr('activityLogMsg')}\n\nPresiona "Nueva" para crear una actividad.'
                                  : tr.tr('activityLogMsg'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
