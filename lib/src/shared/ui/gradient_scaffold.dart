import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../features/auth/data/auth_repository.dart';

class GradientScaffold extends ConsumerWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final List<Color>? gradientColors;

  const GradientScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.gradientColors,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final showPing = user?.showPingAnimation ?? true;

    final bgColors = gradientColors ??
        PulseTheme.getGradient(
          isDarkMode: user?.isDarkMode ?? false,
          isPrideMode: user?.isPrideMode ?? false,
          gender: user?.gender,
        );

    return Scaffold(
      extendBody: extendBody,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
          ),
          if (showPing) const _SubtlePingOverlay(),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

/// Lightweight pulsing dots overlay — subtle ambient animation
class _SubtlePingOverlay extends StatefulWidget {
  const _SubtlePingOverlay();

  @override
  State<_SubtlePingOverlay> createState() => _SubtlePingOverlayState();
}

class _SubtlePingOverlayState extends State<_SubtlePingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_PingDot> _dots;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    final rng = math.Random(42);
    _dots = List.generate(8, (_) {
      return _PingDot(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        delay: rng.nextDouble(),
        size: 2.0 + rng.nextDouble() * 3.0,
      );
    });
  }

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
          painter: _SubtlePingPainter(progress: _controller.value, dots: _dots),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PingDot {
  final double x, y, delay, size;
  const _PingDot(
      {required this.x,
      required this.y,
      required this.delay,
      required this.size});
}

class _SubtlePingPainter extends CustomPainter {
  final double progress;
  final List<_PingDot> dots;

  _SubtlePingPainter({required this.progress, required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in dots) {
      final phase = (progress + dot.delay) % 1.0;
      final opacity = (math.sin(phase * math.pi) * 0.25).clamp(0.0, 1.0);
      final pulseSize = dot.size + math.sin(phase * math.pi) * 3;

      final pos = Offset(dot.x * size.width, dot.y * size.height);

      // Glow
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, pulseSize * 2, glowPaint);

      // Core dot
      final dotPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, pulseSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SubtlePingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
