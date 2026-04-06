import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/ai_voice_models.dart';

class BeeaVoiceOrb extends StatefulWidget {
  const BeeaVoiceOrb({
    super.key,
    required this.status,
    required this.amplitude,
    this.size = 220,
  });

  final AiVoiceSessionStatus status;
  final double amplitude;
  final double size;

  @override
  State<BeeaVoiceOrb> createState() => _BeeaVoiceOrbState();
}

class _BeeaVoiceOrbState extends State<BeeaVoiceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _BeeaVoiceOrbPainter(
            phase: _controller.value * math.pi * 2,
            amplitude: widget.amplitude.clamp(0.0, 1.0),
            status: widget.status,
          ),
        );
      },
    );
  }
}

class _BeeaVoiceOrbPainter extends CustomPainter {
  const _BeeaVoiceOrbPainter({
    required this.phase,
    required this.amplitude,
    required this.status,
  });

  final double phase;
  final double amplitude;
  final AiVoiceSessionStatus status;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.width * 0.34;
    final amplitudeBoost = switch (status) {
      AiVoiceSessionStatus.listening => 16 + (amplitude * 28),
      AiVoiceSessionStatus.processing => 10,
      AiVoiceSessionStatus.speaking => 12 + (amplitude * 24),
      AiVoiceSessionStatus.connecting => 6,
      _ => 8,
    };
    final radius = baseRadius + amplitudeBoost;

    final orbPath = _buildBlobPath(center, radius);
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34)
      ..color = const Color(0x662AA5FF);
    canvas.drawCircle(center, radius + 10, glowPaint);

    canvas.save();
    canvas.clipPath(orbPath);

    final orbRect = Rect.fromCircle(center: center, radius: radius + 24);
    final radial = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius + 24,
        const [
          Color(0xFFF8FFFF),
          Color(0xFFAEEBFF),
          Color(0xFF2391FF),
          Color(0xFF1162F3),
        ],
        const [0, 0.34, 0.72, 1],
      );
    canvas.drawRect(orbRect, radial);

    _paintRibbon(
      canvas,
      orbRect,
      center,
      angle: phase * 0.55,
      colors: const [
        Color(0x00FFFFFF),
        Color(0x90F6FFFF),
        Color(0x803FD2FF),
        Color(0x001062F3),
      ],
      stops: const [0.0, 0.28, 0.72, 1.0],
      widthFactor: 0.34,
      verticalBias: -0.22,
    );
    _paintRibbon(
      canvas,
      orbRect,
      center,
      angle: (phase * -0.75) + 1.4,
      colors: const [
        Color(0x00FFFFFF),
        Color(0x75D9F7FF),
        Color(0x8863B6FF),
        Color(0x000D4CD9),
      ],
      stops: const [0.0, 0.26, 0.74, 1.0],
      widthFactor: 0.26,
      verticalBias: 0.18,
    );

    final highlightPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawCircle(
      center.translate(-radius * 0.22, -radius * 0.34),
      radius * 0.24,
      highlightPaint,
    );

    canvas.restore();

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawPath(orbPath, outlinePaint);
  }

  Path _buildBlobPath(Offset center, double radius) {
    final distortion = switch (status) {
      AiVoiceSessionStatus.listening => 0.09 + (amplitude * 0.12),
      AiVoiceSessionStatus.processing => 0.06,
      AiVoiceSessionStatus.speaking => 0.07 + (amplitude * 0.08),
      AiVoiceSessionStatus.connecting => 0.04,
      _ => 0.035,
    };

    final path = Path();
    const segments = 72;
    for (var i = 0; i <= segments; i++) {
      final t = (i / segments) * math.pi * 2;
      final wave = math.sin((t * 3) + phase) * distortion;
      final wave2 = math.cos((t * 5) - (phase * 1.3)) * distortion * 0.5;
      final currentRadius = radius * (1 + wave + wave2);
      final point = Offset(
        center.dx + (math.cos(t) * currentRadius),
        center.dy + (math.sin(t) * currentRadius),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _paintRibbon(
    Canvas canvas,
    Rect rect,
    Offset center, {
    required double angle,
    required List<Color> colors,
    required List<double> stops,
    required double widthFactor,
    required double verticalBias,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    final ribbonRect = Rect.fromCenter(
      center: center.translate(0, rect.height * verticalBias),
      width: rect.width * 1.35,
      height: rect.height * widthFactor,
    );
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..shader = ui.Gradient.linear(
        ribbonRect.topLeft,
        ribbonRect.bottomRight,
        colors,
        stops,
      );

    final ribbonPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          ribbonRect,
          Radius.circular(ribbonRect.height * 0.9),
        ),
      );
    canvas.drawPath(ribbonPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BeeaVoiceOrbPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.status != status;
  }
}
