import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// PANTALLA: RoutineResultScreen (Renderizado de Rutinas)
///
/// Encargada de mostrar el entrenamiento generado o recuperado del historial.
/// Elección de implementación: Debido a la naturaleza estocástica de los
/// modelos generativos (LLMs), ocasionalmente devuelven Markdown malformado.
/// Esta clase implementa un algoritmo de sanitización (Filtro RegExp) que
/// intercepta y corrige anomalías de formato (ej: Títulos envueltos en negrita)
/// *antes* de delegar el renderizado al motor de Flutter, previniendo excepciones
/// visuales y garantizando una interfaz de usuario robusta.
class RoutineResultScreen extends StatelessWidget {
  /// Texto crudo en formato Markdown a renderizar.
  final String routineText;

  const RoutineResultScreen({super.key, required this.routineText});

  /// Método Privado: Sanitizador de Markdown
  ///
  /// Utiliza Expresiones Regulares (RegExp) para limpiar el texto crudo.
  /// Entradas: [rawText] generado por la IA o leído de Firestore.
  /// Salidas: Cadena de texto compatible con el estándar estricto de [flutter_markdown].
  String _sanitizeMarkdown(String rawText) {
    String text = rawText;

    // Regla 1: Desanida negritas externas (ej: **## Titulo** -> ## Titulo)
    text = text.replaceAllMapped(
        RegExp(r'\*\*(#+)\s*(.*?)\*\*'), (m) => '${m[1]} ${m[2]}');

    // Regla 2: Desanida negritas internas (ej: ## **Titulo** -> ## Titulo)
    text = text.replaceAllMapped(
        RegExp(r'(#+)\s*\*\*(.*?)\*\*'), (m) => '${m[1]} ${m[2]}');

    // Regla 3: Fuerza espaciado estructural (ej: ##Titulo -> ## Titulo)
    text = text.replaceAllMapped(
        RegExp(r'^(#+)([^ \n])', multiLine: true), (m) => '${m[1]} ${m[2]}');

    // Regla 4: Previene colisiones de bloques inyectando saltos de línea dobles
    text = text.replaceAllMapped(
        RegExp(r'([^\n])\n(#+ )'), (m) => '${m[1]}\n\n${m[2]}');

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Ejecución del middleware de limpieza de formato
    final String safeText = _sanitizeMarkdown(routineText);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("TU ENTRENAMIENTO",
            style: TextStyle(
                fontFamily: 'Teko', color: Colors.white, fontSize: 28)),
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
              // Inyección de los datos sanitizados al widget de renderizado
              data: safeText,
              physics: const BouncingScrollPhysics(),
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                    color: Colors.white, fontSize: 16, height: 1.5),
                // Jerarquía visual personalizada con la tipografía corporativa
                h2: TextStyle(
                    fontFamily: 'Teko',
                    color: primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
                h3: const TextStyle(
                    fontFamily: 'Teko',
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
                strong:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                listBullet: TextStyle(color: primaryColor, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
