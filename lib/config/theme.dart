import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFAAD816); 
  static const Color secondaryColor = Color(0xFF1E1E1E); 
  static const Color inputFillColor = Color(0xFF2C2C2C); 
  static const Color backgroundBlack = Color(0xFF121212); 
  static const Color whiteColor = Colors.white;

  static ThemeData getTheme() {
    // Generamos un tema oscuro de base para usar sus propiedades
    final baseTheme = ThemeData.dark();

    return ThemeData(
      useMaterial3: true, 
      brightness: Brightness.dark, 
      
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundBlack,

      // 🟢 USAMOS LA FUENTE LOCAL (Sin internet)
      fontFamily: 'Teko',
      
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,    
        secondary: primaryColor,  
        surface: secondaryColor,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: GoogleFonts.roboto(
          color: whiteColor.withAlpha(100),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, 
          foregroundColor: Colors.black, 
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.teko(
            fontSize: 22, 
            fontWeight: FontWeight.w600, 
            letterSpacing: 1.5, 
          ),
        ),
      ),
    );
  }
}