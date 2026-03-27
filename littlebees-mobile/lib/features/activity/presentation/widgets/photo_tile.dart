import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/resolve_image_url.dart';
import '../../domain/photo_model.dart';

class PhotoTile extends StatelessWidget {
  final Photo photo;
  final int index;

  const PhotoTile({super.key, required this.photo, required this.index});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveImageUrl(photo.url);
    if (resolvedUrl == null) {
      return const SizedBox.shrink();
    }

    // Generate a hero tag based on ID
    final heroTag = 'photo_${photo.id}';

    return GestureDetector(
      onTap: () {
        context.push('/activity/photo/${photo.id}', extra: photo);
      },
      child:
          Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: heroTag,
                        child: Image.network(resolvedUrl, fit: BoxFit.cover),
                      ),
                      if (photo.caption != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(180),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              photo.caption!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (index * 50).ms, duration: 300.ms)
              .slideY(begin: 0.1),
    );
  }
}
