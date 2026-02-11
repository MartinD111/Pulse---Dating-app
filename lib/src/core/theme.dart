import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PulseTheme {
  static const primaryColor = Color(0xFFE91E63);
  static const secondaryColor = Color(0xFF87CEEB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor:
          Colors.transparent, // Background handled by GradientScaffold
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondaryColor,
        secondary: primaryColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      // Add other component themes here as needed
    );
  }
}
