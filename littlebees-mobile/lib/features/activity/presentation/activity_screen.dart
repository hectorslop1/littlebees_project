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
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
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
                horizontal: 18.0,
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
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final log = item.log;
                              final metadata = log.metadata ?? const {};
                              final activityType =
                                  metadata['activityType'] as String?;
                              final photoUrls = _extractPhotoUrls(metadata);

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(8),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
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
                                                  fontSize: 15,
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
                                            horizontal: 9,
                                            vertical: 5,
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
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      log.title,
                                      style: TextStyle(
                                        fontSize: 15.5,
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
                                            fontSize: 13,
                                            height: 1.35,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    if (photoUrls.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppColors.primarySurface,
                                                borderRadius:
                                                    BorderRadius.circular(14),
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
                                                      '${photoUrls.length} foto(s) adjuntas',
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 74,
                                              child: ListView.separated(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: photoUrls.length,
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                itemBuilder: (context, index) {
                                                  final resolvedUrl =
                                                      resolveImageUrl(
                                                        photoUrls[index],
                                                      );
                                                  if (resolvedUrl == null) {
                                                    return const SizedBox();
                                                  }

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(
                                                        context,
                                                      ).push(
                                                        MaterialPageRoute<void>(
                                                          builder: (_) =>
                                                              FullScreenImageViewer(
                                                                imageUrl:
                                                                    resolvedUrl,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: Image.network(
                                                        resolvedUrl,
                                                        width: 82,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => Container(
                                                              width: 82,
                                                              color: AppColors
                                                                  .primarySurface,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: const Icon(
                                                                LucideIcons
                                                                    .imageOff,
                                                                color: AppColors
                                                                    .textSecondary,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
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
