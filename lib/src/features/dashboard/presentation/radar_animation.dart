import 'dart:math';
import 'package:flutter/material.dart';

class RadarAnimation extends StatefulWidget {
  const RadarAnimation({super.key});

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
          painter: RadarPainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double value;

  RadarPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Draw static circles
    canvas.drawCircle(center, maxRadius * 0.33, paint);
    canvas.drawCircle(center, maxRadius * 0.66, paint);
    canvas.drawCircle(center, maxRadius, paint);

    // Draw scanning line
    final scanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: pi / 2,
        colors: [Colors.transparent, Colors.white.withOpacity(0.8)],
        stops: const [0.0, 1.0],
        transform: GradientRotation(value * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius),
      value * 2 * pi,
      pi / 2,
      true,
      scanPaint,
    );

    // Draw expanding ripple
    final rippleRadius = maxRadius * value;
    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(1.0 - value)
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, rippleRadius, ripplePaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
