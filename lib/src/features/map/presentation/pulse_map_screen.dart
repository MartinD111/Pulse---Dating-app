import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PulseMapScreen extends StatelessWidget {
  const PulseMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101010), // Dark background
      child: Stack(
        children: [
          // Mock Map Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/e/ec/World_map_blank_without_borders.png', // Placeholder
                fit: BoxFit.cover,
                color: Colors.blueGrey,
                colorBlendMode: BlendMode.modulate,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 60,
            left: 20,
            child: Text("Pulse Map",
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
          ),

          // City Bubbles (Mock Data for Slovenia)
          _buildCityBubble(context,
              top: 200, left: 100, count: 124, city: "Ljubljana"),
          _buildCityBubble(context,
              top: 150, left: 250, count: 56, city: "Maribor"),
          _buildCityBubble(context,
              top: 350, left: 80, count: 32, city: "Koper"),
          _buildCityBubble(context,
              top: 300, left: 200, count: 18, city: "Novo Mesto"),
        ],
      ),
    );
  }

  Widget _buildCityBubble(BuildContext context,
      {double? top, double? left, required int count, required String city}) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.pink.shade500.withValues(alpha: 0.8),
                  Colors.purple.shade500.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5), width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 5),
              ],
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(height: 5),
          Text(city,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
