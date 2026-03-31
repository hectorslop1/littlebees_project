import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/widgets/compact_layout.dart';
import '../application/activity_controller.dart';
import 'widgets/photo_grid.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../../design_system/widgets/lb_empty_state.dart';
import '../../../../design_system/widgets/lb_error_state.dart';
import '../../../../design_system/widgets/lb_avatar.dart';
import '../../../../core/utils/resolve_image_url.dart';
import '../../../../design_system/widgets/full_screen_image_viewer.dart';
import '../../auth/application/auth_provider.dart';
import 'create_activity_screen.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool _showGallery = false;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(photosProvider);
    final activityFeedAsync = ref.watch(activityFeedProvider);
    final tr = ref.watch(translationsProvider);
    final authState = ref.watch(authProvider);
    final isTeacher =
        authState.isTeacher || authState.isDirector || authState.isAdmin;
    final photosCount = photosAsync.valueOrNull?.length ?? 0;
    final logsCount = activityFeedAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'Actividad del día' : tr.tr('activity')),
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
                          _showGallery = false;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: CompactHeroCard(
                eyebrow: isTeacher ? 'Jornada del aula' : 'Actividad compartida',
                title: isTeacher
                    ? 'Todo lo que registras hoy, en un solo lugar'
                    : 'Momentos y registros del dia',
                subtitle: isTeacher
                    ? 'Usa Jornada para revisar registros y Galeria para compartir evidencia visual con las familias.'
                    : 'Consulta primero los registros mas recientes y despues las fotos del dia.',
                child: Row(
                  children: [
                    Expanded(
                      child: CompactMetricTile(
                        icon: LucideIcons.clipboardList,
                        label: 'Registros',
                        value: '$logsCount',
                        accent: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CompactMetricTile(
                        icon: LucideIcons.image,
                        label: 'Fotos',
                        value: '$photosCount',
                        accent: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 2.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColor(AppColors.surfaceVariant),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showGallery = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: !_showGallery
                                ? context.appColor(AppColors.surface)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_showGallery
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
                              'Jornada',
                              style: TextStyle(
                                fontWeight: !_showGallery
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: !_showGallery
                                    ? context.appColor(AppColors.textPrimary)
                                    : context.appColor(AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showGallery = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: _showGallery
                                ? context.appColor(AppColors.surface)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _showGallery
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
                              'Galería',
                              style: TextStyle(
                                fontWeight: _showGallery
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _showGallery
                                    ? context.appColor(AppColors.textPrimary)
                                    : context.appColor(AppColors.textSecondary),
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
              child: _showGallery
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
                            title: 'Aún no hay registros en la jornada',
                            message: isTeacher
                                ? 'Cuando registres actividades del aula, aquí verás la jornada ordenada por hora y por alumno.'
                                : tr.tr('activityLogMsg'),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(activityFeedProvider);
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final log = item.log;
                              final metadata = log.metadata ?? const {};
                              final activityType =
                                  metadata['activityType'] as String?;
                              final photoUrls = _extractPhotoUrls(metadata);

                              return _CompactActivityFeedCard(
                                childName: item.childName,
                                childPhotoUrl: item.childPhotoUrl,
                                timeLabel: log.time ?? '',
                                badgeLabel: _activityBadgeLabel(
                                  activityType ?? log.type.value,
                                ),
                                title: log.title,
                                description: log.description,
                                photoUrls: photoUrls,
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

List<String> _extractPhotoUrls(Map<String, dynamic> metadata) {
  final urls = <String>[];
  final rawPhotoUrls = metadata['photoUrls'];
  if (rawPhotoUrls is List) {
    urls.addAll(
      rawPhotoUrls
          .map((value) => value?.toString())
          .whereType<String>()
          .where((value) => value.isNotEmpty),
    );
  }

  final singlePhotoUrl = metadata['photoUrl']?.toString();
  if (singlePhotoUrl != null && singlePhotoUrl.isNotEmpty) {
    urls.add(singlePhotoUrl);
  }

  return urls;
}

class _CompactActivityFeedCard extends StatelessWidget {
  const _CompactActivityFeedCard({
    required this.childName,
    required this.childPhotoUrl,
    required this.timeLabel,
    required this.badgeLabel,
    required this.title,
    required this.description,
    required this.photoUrls,
  });

  final String childName;
  final String? childPhotoUrl;
  final String timeLabel;
  final String badgeLabel;
  final String title;
  final String? description;
  final List<String> photoUrls;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = photoUrls.isEmpty ? null : resolveImageUrl(photoUrls.first);
    final summary = (description ?? '').trim().isEmpty ? title : description!.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LBAvatar(
            imageUrl: childPhotoUrl,
            placeholder: childName.isNotEmpty ? childName.trim().split(' ').first[0] : '?',
            size: LBAvatarSize.normal,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        childName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (photoUrls.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${photoUrls.length} foto${photoUrls.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (resolvedUrl != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FullScreenImageViewer(imageUrl: resolvedUrl),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  resolvedUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.primarySurface,
                    alignment: Alignment.center,
                    child: const Icon(
                      LucideIcons.imageOff,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
