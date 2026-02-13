import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PulseTheme {
  // Base Colors
  static const primaryColor = Color(0xFFE91E63);
  static const secondaryColor = Color(0xFF87CEEB);

  // Male Theme Colors
  static const malePrimaryColor = Color(0xFF2196F3);
  static const maleSecondaryColor = Color(0xFF00BCD4);

  // Dark Mode Colors
  static const darkPrimaryColor = Color(0xFF880E4F); // Dark Pink
  static const darkSecondaryColor = Color(0xFF1A237E); // Dark Blue

  static const darkMalePrimaryColor = Color(0xFF0D47A1); // Dark Blue
  static const darkMaleSecondaryColor = Color(0xFF006064); // Dark Cyan

  // Pride Colors
  static const List<Color> prideGradient = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  static List<Color> getGradient(
      {required bool isDarkMode,
      required bool isPrideMode,
      required String? gender}) {
    if (isPrideMode) {
      if (isDarkMode) {
        return prideGradient.map((c) => c.withValues(alpha: 0.7)).toList();
      }
      return prideGradient;
    }

    if (gender == 'Moški' || gender == 'Male') {
      if (isDarkMode) {
        return [darkMaleSecondaryColor, darkMalePrimaryColor];
      }
      return [maleSecondaryColor, malePrimaryColor];
    }

    // Default (Female/Other)
    if (isDarkMode) {
      return [darkSecondaryColor, darkPrimaryColor];
    }
    return [secondaryColor, primaryColor];
  }

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
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkSecondaryColor,
        secondary: darkPrimaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      ),
    );
  }
}
