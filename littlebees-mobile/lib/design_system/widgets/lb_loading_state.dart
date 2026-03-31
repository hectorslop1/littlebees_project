import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_radii.dart';

/// Premium loading state with shimmer skeleton placeholders.
/// Use [layout] to match the target screen structure.
enum LBLoadingLayout { list, cards, profile, home, detail }

class LBLoadingState extends StatelessWidget {
  final LBLoadingLayout layout;
  final int itemCount;

  const LBLoadingState({
    super.key,
    this.layout = LBLoadingLayout.list,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEEECE8);
    final highlightColor = isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFF8F6F2);

    Widget content;
    switch (layout) {
      case LBLoadingLayout.home:
        content = _HomeShimmerLayout(
          baseColor: baseColor,
          highlightColor: highlightColor,
        );
        break;
      case LBLoadingLayout.profile:
        content = _ProfileShimmerLayout(
          baseColor: baseColor,
          highlightColor: highlightColor,
        );
        break;
      case LBLoadingLayout.cards:
        content = _CardsShimmerLayout(
          baseColor: baseColor,
          highlightColor: highlightColor,
          itemCount: itemCount,
        );
        break;
      case LBLoadingLayout.detail:
        content = _DetailShimmerLayout(
          baseColor: baseColor,
          highlightColor: highlightColor,
        );
        break;
      case LBLoadingLayout.list:
        content = _ListShimmerLayout(
          baseColor: baseColor,
          highlightColor: highlightColor,
          itemCount: itemCount,
        );
        break;
    }

    return content
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: highlightColor.withAlpha(120));
  }
}

// ─── Shimmer building blocks ─────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 10,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _ShimmerCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Home layout ─────────────────────────────────────────────────────

class _HomeShimmerLayout extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _HomeShimmerLayout({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: greeting + action buttons
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: 100,
                        height: 14,
                        color: baseColor,
                        radius: 6,
                      ),
                      const SizedBox(height: 8),
                      _ShimmerBox(
                        width: 160,
                        height: 24,
                        color: baseColor,
                        radius: 8,
                      ),
                      const SizedBox(height: 8),
                      _ShimmerBox(
                        width: 120,
                        height: 14,
                        color: baseColor,
                        radius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _ShimmerBox(
                  width: 76,
                  height: 48,
                  color: baseColor,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                _ShimmerCircle(size: 48, color: baseColor),
                const SizedBox(width: 10),
                _ShimmerCircle(size: 48, color: baseColor),
              ],
            ),
            const SizedBox(height: 16),
            // Child header card
            _ShimmerBox(
              width: double.infinity,
              height: 120,
              color: baseColor,
              radius: 22,
            ),
            const SizedBox(height: 12),
            // Status card
            _ShimmerBox(
              width: double.infinity,
              height: 100,
              color: baseColor,
              radius: 18,
            ),
            const SizedBox(height: 12),
            // AI Summary card
            _ShimmerBox(
              width: double.infinity,
              height: 72,
              color: baseColor,
              radius: 18,
            ),
            const SizedBox(height: 14),
            // Section header
            _ShimmerBox(
              width: double.infinity,
              height: 80,
              color: baseColor,
              radius: 18,
            ),
            const SizedBox(height: 12),
            // Timeline event card
            _ShimmerBox(
              width: double.infinity,
              height: 90,
              color: baseColor,
              radius: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List layout ─────────────────────────────────────────────────────

class _ListShimmerLayout extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  final int itemCount;

  const _ListShimmerLayout({
    required this.baseColor,
    required this.highlightColor,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _ListItemShimmer(baseColor: baseColor),
    );
  }
}

class _ListItemShimmer extends StatelessWidget {
  final Color baseColor;

  const _ListItemShimmer({required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: baseColor.withAlpha(60),
        borderRadius: AppRadii.borderRadiusLg,
      ),
      child: Row(
        children: [
          _ShimmerCircle(size: 44, color: baseColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: 140,
                  height: 14,
                  color: baseColor,
                  radius: 6,
                ),
                const SizedBox(height: 8),
                _ShimmerBox(
                  width: double.infinity,
                  height: 11,
                  color: baseColor,
                  radius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ShimmerBox(width: 48, height: 12, color: baseColor, radius: 6),
        ],
      ),
    );
  }
}

// ─── Cards layout ────────────────────────────────────────────────────

class _CardsShimmerLayout extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  final int itemCount;

  const _CardsShimmerLayout({
    required this.baseColor,
    required this.highlightColor,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _ShimmerBox(
        width: double.infinity,
        height: 96,
        color: baseColor,
        radius: 18,
      ),
    );
  }
}

// ─── Profile layout ──────────────────────────────────────────────────

class _ProfileShimmerLayout extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _ProfileShimmerLayout({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Avatar + name
          Center(child: _ShimmerCircle(size: 80, color: baseColor)),
          const SizedBox(height: 14),
          _ShimmerBox(width: 160, height: 20, color: baseColor, radius: 8),
          const SizedBox(height: 8),
          _ShimmerBox(width: 120, height: 14, color: baseColor, radius: 6),
          const SizedBox(height: 24),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _ShimmerBox(
                  width: double.infinity,
                  height: 72,
                  color: baseColor,
                  radius: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShimmerBox(
                  width: double.infinity,
                  height: 72,
                  color: baseColor,
                  radius: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShimmerBox(
                  width: double.infinity,
                  height: 72,
                  color: baseColor,
                  radius: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Settings card
          _ShimmerBox(
            width: double.infinity,
            height: 140,
            color: baseColor,
            radius: 18,
          ),
          const SizedBox(height: 14),
          _ShimmerBox(
            width: double.infinity,
            height: 180,
            color: baseColor,
            radius: 18,
          ),
        ],
      ),
    );
  }
}

// ─── Detail layout ───────────────────────────────────────────────────

class _DetailShimmerLayout extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _DetailShimmerLayout({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image / header
          _ShimmerBox(
            width: double.infinity,
            height: 180,
            color: baseColor,
            radius: 22,
          ),
          const SizedBox(height: 16),
          _ShimmerBox(width: 200, height: 22, color: baseColor, radius: 8),
          const SizedBox(height: 10),
          _ShimmerBox(
            width: double.infinity,
            height: 14,
            color: baseColor,
            radius: 6,
          ),
          const SizedBox(height: 6),
          _ShimmerBox(width: 260, height: 14, color: baseColor, radius: 6),
          const SizedBox(height: 20),
          // Info rows
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  _ShimmerBox(
                    width: 100,
                    height: 14,
                    color: baseColor,
                    radius: 6,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ShimmerBox(
                      width: double.infinity,
                      height: 14,
                      color: baseColor,
                      radius: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
