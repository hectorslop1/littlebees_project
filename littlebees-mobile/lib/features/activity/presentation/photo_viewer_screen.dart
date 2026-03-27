import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/resolve_image_url.dart';
import '../domain/photo_model.dart';
import '../../../../design_system/theme/app_colors.dart';

class PhotoViewerScreen extends StatelessWidget {
  final String heroTag;
  final Photo photo;

  const PhotoViewerScreen({
    super.key,
    required this.heroTag,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveImageUrl(photo.url);
    if (resolvedUrl == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Icon(LucideIcons.imageOff, color: Colors.white70, size: 40),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background immersive image
          PhotoView(
            imageProvider: NetworkImage(resolvedUrl),
            heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          // Top Overlay: Gradient and Actions
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(180), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.share, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          // Bottom Overlay: Story Data (Caption, caregiver, time, like)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 48,
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(200), Colors.transparent],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (photo.caregiverName != null)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.user,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                photo.caregiverName!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                TimeOfDay.fromDateTime(
                                  photo.timestamp,
                                ).format(context),
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                        if (photo.caption != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            photo.caption!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            photo.isLiked
                                ? LucideIcons.heart
                                : LucideIcons
                                      .heart, // Ideally solid heart if liked
                            color: photo.isLiked
                                ? AppColors.error
                                : Colors.white,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
