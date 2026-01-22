import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CLASE AppTheme:
// CONCEPTOS JAVA:
// - Es una clase "Helper" con miembros estáticos (static).
// - No hace falta instanciarla (new AppTheme()), se usa directamente.
class AppTheme {
  
  // 1. PALETA DE COLORES (Constantes):
  // Usamos 0xFF para indicar opacidad 100%. AAD816 es tu verde Volt.
  static const Color primaryColor = Color(0xFFAAD816); 
  static const Color secondaryColor = Color(0xFF1E1E1E); // Gris oscuro
  static const Color inputFillColor = Color(0xFF2C2C2C); // Gris inputs
  static const Color backgroundBlack = Color(0xFF121212); // Fondo casi negro
  static const Color whiteColor = Colors.white;

  // 2. MÉTODO FACTORÍA (getTheme):
  // Devuelve el objeto de configuración (ThemeData) para toda la app.
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true, // Diseño moderno de Android
      brightness: Brightness.dark, // Modo oscuro por defecto
      
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundBlack,

      // 🟢 TIPOGRAFÍA GLOBAL:
      // Aquí cambiamos a 'Teko'. Al ponerla en el fontFamily del tema,
      // Flutter intentará usarla por defecto en la mayoría de textos.
      fontFamily: GoogleFonts.teko().fontFamily,
      
      // ESQUEMA DE COLORES:
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,    
        secondary: primaryColor,  
        surface: backgroundBlack,
      ),

      // ESTILO DE INPUTS (Cajas de texto):
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        
        // Borde reposo (sin foco)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none,
        ),
        
        // Borde activo (con foco) -> Verde
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        
        // Texto de ayuda (hint)
        // Usamos withAlpha(100) -> aprox 40% opacidad.
        // GoogleFonts.roboto() para el hint porque Teko puede ser difícil de leer en textos pequeños/grises.
        hintStyle: GoogleFonts.roboto(
          color: whiteColor.withAlpha(100),
        ),
      ),

      // ESTILO DE BOTONES:
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Verde
          foregroundColor: Colors.black, // Texto negro
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // Forzamos Teko en los botones también
          textStyle: GoogleFonts.teko(
            fontSize: 22, // Teko suele ser estrecha, necesita más tamaño
            fontWeight: FontWeight.w600, // Semi-bold
            letterSpacing: 1.5, // Espaciado para que respire
          ),
        ),
      ),
    );
  }
}
