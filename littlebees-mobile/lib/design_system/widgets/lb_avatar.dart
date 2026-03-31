import 'package:flutter/material.dart';
import '../../core/utils/resolve_image_url.dart';
import 'full_screen_image_viewer.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum LBAvatarSize { small, normal, large }

class LBAvatar extends StatelessWidget {
  final String? imageUrl;
  final String placeholder;
  final LBAvatarSize size;
  final bool showStatusDot;
  final Color? statusColor;
  final VoidCallback? onTap;
  final String? heroTag;

  const LBAvatar({
    super.key,
    this.imageUrl,
    required this.placeholder,
    this.size = LBAvatarSize.normal,
    this.showStatusDot = false,
    this.statusColor,
    this.onTap,
    this.heroTag,
  });

  double get _sizePixels {
    switch (size) {
      case LBAvatarSize.small:
        return 32.0;
      case LBAvatarSize.normal:
        return 48.0;
      case LBAvatarSize.large:
        return 64.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = _sizePixels;
    final resolvedImageUrl = resolveImageUrl(imageUrl);
    final initial = placeholder.isNotEmpty
        ? placeholder.substring(0, 1).toUpperCase()
        : '';
    final borderColor = context.appColor(AppColors.primaryLight);
    final surfaceColor = context.appColor(AppColors.primarySurface);

    Widget avatarContent = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        color: surfaceColor,
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: resolvedImageUrl != null
            ? Image.network(
                resolvedImageUrl,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _AvatarPlaceholder(initial: initial, size: avatarSize),
              )
            : _AvatarPlaceholder(initial: initial, size: avatarSize),
      ),
    );

    if (showStatusDot) {
      final dotSize = avatarSize * 0.3;
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor ?? AppColors.success,
                border: Border.all(
                  color: context.appColor(AppColors.surface),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final effectiveOnTap =
        onTap ??
        (resolvedImageUrl != null
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FullScreenImageViewer(
                      imageUrl: resolvedImageUrl,
                      heroTag: heroTag,
                    ),
                  ),
                );
              }
            : null);

    // Wrap in Hero if tag provided
    if (heroTag != null) {
      avatarContent = Hero(tag: heroTag!, child: avatarContent);
    }

    if (effectiveOnTap != null) {
      return GestureDetector(onTap: effectiveOnTap, child: avatarContent);
    }

    return avatarContent;
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.initial, required this.size});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.appColor(AppColors.primarySurface);

    return Container(
      width: size,
      height: size,
      color: surfaceColor,
      alignment: Alignment.center,
      child: initial.isNotEmpty
          ? Text(
              initial,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: context.appColor(AppColors.primary),
                fontSize: size * 0.4,
              ),
            )
          : null,
    );
  }
}
