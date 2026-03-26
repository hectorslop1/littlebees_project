import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../application/activity_controller.dart';
import 'widgets/photo_grid.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../../design_system/widgets/lb_empty_state.dart';
import '../../../../design_system/widgets/lb_error_state.dart';
import '../../../../design_system/widgets/lb_avatar.dart';
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
    final activityFeedAsync = ref.watch(activityFeedProvider);
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
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateActivityScreen(),
                    ),
                  ).then((saved) {
                    if (saved == true) {
                      if (mounted) {
                        setState(() {
                          _isPhotosTab = false;
                        });
                      }
                      ref.invalidate(photosProvider);
                      ref.invalidate(activityFeedProvider);
                    }
                  });
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
                  : activityFeedAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return LBEmptyState(
                            icon: LucideIcons.clipboardList,
                            title: 'Aún no hay actividad registrada',
                            message: isTeacher
                                ? 'Cuando registres actividades del aula, aparecerán aquí y también podrán reflejarse en la experiencia del padre.'
                                : tr.tr('activityLogMsg'),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(activityFeedProvider);
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final log = item.log;
                              final metadata = log.metadata ?? const {};
                              final activityType =
                                  metadata['activityType'] as String?;

                              return Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(8),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        LBAvatar(
                                          imageUrl: item.childPhotoUrl,
                                          placeholder: item.childName.isNotEmpty
                                              ? item.childName
                                                    .trim()
                                                    .split(' ')
                                                    .first[0]
                                              : '?',
                                          size: LBAvatarSize.large,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.childName,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                log.time ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(
                                              24,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            _activityBadgeLabel(
                                              activityType ?? log.type.value,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      log.title,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if ((log.description ?? '')
                                        .trim()
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          log.description!,
                                          style: TextStyle(
                                            height: 1.45,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    if ((metadata['photoUrls'] as List?)
                                            ?.isNotEmpty ==
                                        true)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySurface,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                LucideIcons.image,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${(metadata['photoUrls'] as List).length} foto(s) adjuntas',
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => LBErrorState(
                        title: 'No fue posible cargar la bitácora',
                        message:
                            'Intenta actualizar. Si el problema sigue, revisamos el contrato del backend.',
                        onRetry: () => ref.invalidate(activityFeedProvider),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _activityBadgeLabel(String rawType) {
    switch (rawType) {
      case 'meal':
        return 'Comida';
      case 'nap':
        return 'Siesta';
      case 'bathroom':
        return 'Baño';
      case 'play':
        return 'Juego';
      case 'learning':
        return 'Aprendizaje';
      case 'outdoor':
        return 'Exterior';
      case 'art':
        return 'Arte';
      default:
        return 'Actividad';
    }
  }
}
