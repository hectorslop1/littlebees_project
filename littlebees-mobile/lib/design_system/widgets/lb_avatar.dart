import 'package:flutter/material.dart';
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

  const LBAvatar({
    super.key,
    this.imageUrl,
    required this.placeholder,
    this.size = LBAvatarSize.normal,
    this.showStatusDot = false,
    this.statusColor,
    this.onTap,
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

    Widget avatarContent = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryLight, width: 2),
        color: AppColors.primarySurface,
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: (imageUrl == null || imageUrl!.isEmpty) && placeholder.isNotEmpty
          ? Text(
              placeholder.substring(0, 1).toUpperCase(),
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontSize: avatarSize * 0.4,
              ),
            )
          : null,
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
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return avatarContent;
  }
}
