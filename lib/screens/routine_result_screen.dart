import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// ==============================================================================
// PANTALLA DE RESULTADO (RENDERIZADO)
// Aunque he instruido a la IA para que el Markdown sea puro, 
// a veces el modelo 'alucina' formatos incorrectos. He rediseñado el sanitizador con 
// expresiones regulares (RegExp) avanzadas. Este algoritmo detecta y repara 
// anomalías comunes (como títulos mezclados con negritas o faltas de espaciado) 
// ANTES de que Flutter intente dibujar la pantalla, garantizando una interfaz robusta.
// ==============================================================================
class RoutineResultScreen extends StatelessWidget {
  final String routineText;

  const RoutineResultScreen({super.key, required this.routineText});

  // FILTRO ANTIMANCHAS MARKDOWN (Súper Agresivo)
  String _sanitizeMarkdown(String rawText) {
    String text = rawText;
    
    // 1. Quitar negritas enteras que envuelven un título (ej: **## Titulo**)
    text = text.replaceAllMapped(RegExp(r'\*\*(#+)\s*(.*?)\*\*'), (m) => '${m[1]} ${m[2]}');
    
    // 2. Quitar negritas por dentro de un título (ej: ## **Titulo**)
    text = text.replaceAllMapped(RegExp(r'(#+)\s*\*\*(.*?)\*\*'), (m) => '${m[1]} ${m[2]}');
    
    // 3. Obligar a que haya un espacio después de los ## (ej: ##Titulo -> ## Titulo)
    text = text.replaceAllMapped(RegExp(r'^(#+)([^ \n])', multiLine: true), (m) => '${m[1]} ${m[2]}');
    
    // 4. Asegurar línea en blanco antes de cualquier título para que el parser no se atragante
    text = text.replaceAllMapped(RegExp(r'([^\n])\n(#+ )'), (m) => '${m[1]}\n\n${m[2]}');

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // Pasamos la rutina por la "lavadora" antes de pintarla
    final String safeText = _sanitizeMarkdown(routineText);

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
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withAlpha(50)),
            ),
            child: Markdown(
              data: safeText, // Texto limpio
              physics: const BouncingScrollPhysics(),
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                // Aquí el H2 es el maestro de ceremonias: Verde y enorme
                h2: GoogleFonts.teko(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold),
                h3: GoogleFonts.teko(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                strong: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                listBullet: TextStyle(color: primaryColor, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}