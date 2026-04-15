import 'package:flutter/material.dart';

/// CLASE DE CONFIGURACIÓN DE TEMA (AppTheme)
///
/// Centraliza la configuración visual de la aplicación.
/// Elección de implementación: Se utiliza una clase estática para definir
/// un [ThemeData] global. Esto asegura la consistencia visual (principio DRY)
/// y mejora el rendimiento general al evitar la instanciación de objetos
/// de tema múltiples veces durante el ciclo de vida de la app.
class AppTheme {
  // Paleta de colores corporativa estática
  static const Color primaryColor = Color(0xFFAAD816);
  static const Color secondaryColor = Color(0xFF1E1E1E);
  static const Color inputFillColor = Color(0xFF2C2C2C);
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color whiteColor = Colors.white;

  /// Genera y devuelve el tema oscuro personalizado.
  ///
  /// Entradas: Ninguna.
  /// Salidas: Un objeto [ThemeData] configurado para Material 3.
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundBlack,

      // Se asigna la fuente local 'Teko' (definida en pubspec.yaml) de forma global.
      // Optimización: Usar la fuente cacheada localmente evita peticiones de red.
      fontFamily: 'Teko',

      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: secondaryColor,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: TextStyle(
          color: whiteColor.withAlpha(100),
          fontFamily: 'Roboto', // Se apoya en fuente del sistema o locales
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
          textStyle: const TextStyle(
            fontFamily: 'Teko',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
