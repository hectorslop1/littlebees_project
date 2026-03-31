import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../../core/utils/haptic_feedback.dart';

enum LBButtonVariant { primary, secondary, outline, text }

class LBButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LBButtonVariant variant;
  final bool isFullWidth;
  final Widget? icon;
  final bool isLoading;

  const LBButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = LBButtonVariant.primary,
    this.isFullWidth = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<LBButton> createState() => _LBButtonState();
}

class _LBButtonState extends State<LBButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      HapticFeedbackHelper.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onPressed != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.labelLarge!;

    Color bgColor;
    Color textColor;
    Border? border;
    List<BoxShadow>? shadows;

    final isDisabled = widget.onPressed == null || widget.isLoading;

    switch (widget.variant) {
      case LBButtonVariant.primary:
        bgColor = isDisabled
            ? context.appColor(AppColors.surfaceVariant)
            : context.appColor(AppColors.primary);
        textColor = isDisabled
            ? context.appColor(AppColors.textTertiary)
            : context.appColor(AppColors.textOnPrimary);
        shadows = isDisabled ? null : [AppShadows.shadowGlow];
        break;
      case LBButtonVariant.secondary:
        bgColor = isDisabled
            ? context.appColor(AppColors.surfaceVariant)
            : context.appColor(AppColors.secondarySurface);
        textColor = isDisabled
            ? context.appColor(AppColors.textTertiary)
            : context.appColor(AppColors.secondary);
        break;
      case LBButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDisabled
            ? context.appColor(AppColors.textTertiary)
            : context.appColor(AppColors.primary);
        border = Border.all(
          color: isDisabled
              ? context.appColor(AppColors.border)
              : context.appColor(AppColors.primary),
          width: 1.5,
        );
        break;
      case LBButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = isDisabled
            ? context.appColor(AppColors.textTertiary)
            : context.appColor(AppColors.textPrimary);
        break;
    }

    Widget content = widget.isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        : Row(
            mainAxisSize: widget.isFullWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(widget.text, style: textTheme.copyWith(color: textColor)),
            ],
          );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: bgColor,
            border: border,
            borderRadius: AppRadii.borderRadiusFull,
            boxShadow: shadows,
          ),
          child: content,
        ),
      ),
    );
  }
}
