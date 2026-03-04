import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../application/activity_controller.dart';
import 'widgets/photo_grid.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../../design_system/widgets/lb_empty_state.dart';
import '../../../../design_system/widgets/lb_error_state.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.tr('activity')),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
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
                        if (photos.isEmpty) {
                          return LBEmptyState(
                            icon: LucideIcons.image,
                            title: 'No Photos Yet',
                            message:
                                'Photos and activities will appear here when caregivers share them.',
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
                        title: 'Couldn\'t Load Photos',
                        message:
                            'We had trouble loading the photos. Please try again.',
                        onRetry: () => ref.refresh(photosProvider),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildLogItem(
                            '2:30pm',
                            'Photos added (3)',
                            Icons.camera_alt,
                          ),
                          _buildLogItem('1:00pm', 'Nap ended', Icons.wb_sunny),
                          _buildLogItem(
                            '11:30am',
                            'Nap started',
                            Icons.nights_stay,
                          ),
                          _buildLogItem(
                            '10:00am',
                            'Ate mostly entirely lunch',
                            Icons.restaurant,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(String time, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
