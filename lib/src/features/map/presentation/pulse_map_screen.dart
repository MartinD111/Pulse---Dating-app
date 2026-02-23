import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/data/auth_repository.dart';

class PulseMapScreen extends ConsumerWidget {
  const PulseMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final isDark = user?.isDarkMode ?? true; // Default to dark

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(46.0569, 14.5058), // Ljubljana
            initialZoom: 13.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            // Theme-aware map tiles
            if (isDark)
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  -1, 0, 0, 0, 255, // Red
                  0, -1, 0, 0, 255, // Green
                  0, 0, -1, 0, 255, // Blue
                  0, 0, 0, 1, 0, // Alpha
                ]),
                child: TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pulse',
                ),
              )
            else
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pulse',
              ),

            MarkerLayer(
              markers: [
                _buildHeatwaveMarker(
                    const LatLng(46.0569, 14.5058), "Ljubljana", 124),
                _buildHeatwaveMarker(const LatLng(46.0500, 14.5200), "BTC", 45),
                _buildHeatwaveMarker(
                    const LatLng(46.0600, 14.4900), "Tivoli", 32),
              ],
            ),
          ],
        ),

        // Overlay Gradient
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? Colors.black.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.transparent,
                    isDark
                        ? Colors.black.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Header
        Positioned(
          top: 60,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pulse Map",
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              Text("Poglej kje je največ dogajanja",
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  Marker _buildHeatwaveMarker(LatLng point, String label, int intensity) {
    // Increase size based on activity count
    final size = 80.0 + (intensity / 100) * 40.0;

    return Marker(
      point: point,
      width: size,
      height: size,
      child: HeatwaveAnimation(intensity: intensity),
    );
  }
}

class HeatwaveAnimation extends StatefulWidget {
  final int intensity;
  const HeatwaveAnimation({super.key, required this.intensity});

  @override
  State<HeatwaveAnimation> createState() => _HeatwaveAnimationState();
}

class _HeatwaveAnimationState extends State<HeatwaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Faster animation for higher intensity
    final durationMs = 2000 - (widget.intensity.clamp(0, 150) * 5);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
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
          painter: _HeatwavePainter(
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _HeatwavePainter extends CustomPainter {
  final double progress;

  _HeatwavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw 3 expanding rings to simulate a heatwave
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final radius = 5.0 + ringProgress * maxRadius;
      final alpha = (1.0 - ringProgress) * 0.6; // Fades out as it expands

      final paint = Paint()
        ..color = Colors.pinkAccent.withValues(alpha: alpha)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, paint);
    }

    // Core hot spot
    final corePaint = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, 8, corePaint);
  }

  @override
  bool shouldRepaint(covariant _HeatwavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
