import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// IMPORTANTE: He añadido esta librería externa para parsear el texto de la IA
import 'package:flutter_markdown/flutter_markdown.dart'; 

// ==============================================================================
// PANTALLA DE RESULTADO DE LA IA
// ARGUMENTO DE DEFENSA: "La IA de Gemini me devuelve la rutina estructurada en 
// formato Markdown (usando ## para títulos y ** para negritas). Como Flutter 
// pinta texto plano por defecto, he integrado el paquete 'flutter_markdown'. 
// Además, en lugar de usar el estilo por defecto, he sobrescrito el 'StyleSheet' 
// para aplicar el 'Theme' de mi aplicación (fuente Teko, color verde corporativo), 
// logrando una integración visual perfecta."
// ==============================================================================
class RoutineResultScreen extends StatelessWidget {
  final String routineText;

  // Constructor que exige el texto generado por la IA para poder dibujarse
  const RoutineResultScreen({super.key, required this.routineText});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("TU ENTRENAMIENTO", style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            // Diseño consistente con el resto de la app (Glassmorphism sutil)
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withAlpha(50)),
            ),
            // AQUÍ OCURRE LA MAGIA DEL RENDERIZADO
            child: Markdown(
              data: routineText, // El texto bruto que me dio Gemini
              physics: const BouncingScrollPhysics(), // Scroll suave estilo iOS
              
              // Personalización del parser de Markdown adaptado a mi UI
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5), // Párrafos normales
                h2: GoogleFonts.teko(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold), // Títulos (##)
                h3: GoogleFonts.teko(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold), // Subtítulos (###)
                strong: TextStyle(color: primaryColor, fontWeight: FontWeight.bold), // Negritas (**) en verde
                listBullet: TextStyle(color: primaryColor, fontSize: 20), // Viñetas de las listas
              ),
            ),
          ),
        ),
      ),
    );
  }
}