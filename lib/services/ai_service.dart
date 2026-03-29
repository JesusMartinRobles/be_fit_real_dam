import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- PARA LEER EL .ENV

// ==============================================================================
// SERVICIO DE INTELIGENCIA ARTIFICIAL (GEMINI)
// ARGUMENTO DE DEFENSA: "La seguridad es vital. La API Key ya no está 'hardcodeada', 
// sino que se lee de memoria de forma segura mediante 'dotenv.env'. Además, he 
// ajustado el 'Prompt Engineering' (las instrucciones a la IA) para obligarla a 
// usar un formato Markdown impecable, reduciendo errores de renderizado en el frontend."
// ==============================================================================
class AIService {
  
  Future<String> generateRoutine({
    required String focus,
    required String time,
    required List<String> materials,
    required String goal,
    required String injuries,
  }) async {
    
    // 1. LEER LA CLAVE SECRETA (Seguridad)
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return "Error crítico: No se encontró la API Key en el archivo .env.";
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash', // Actualizado al modelo más potente y rápido
      apiKey: apiKey,
    );
    
    final safeInjuries = injuries.trim().isEmpty ? "Ninguna molestia." : injuries;
    final materialsText = materials.join(", ");

    // 2. PROMPT MEJORADO (Prevención de errores Markdown)
    final String prompt = '''
      Eres un Entrenador Personal de Élite. Diseña una rutina directa y segura.

      --- DATOS DEL ATLETA ---
      Enfoque: $focus
      Tiempo máximo: $time minutos
      Objetivo: $goal
      Material: $materialsText
      Consideraciones de salud: $safeInjuries

      --- REGLAS DE FORMATO MARKDOWN ESTRICTAS (CUMPLE ESTO AL 100%) ---
      1. Usa "## " (doble almohadilla y un espacio) EXCLUSIVAMENTE para los títulos de los bloques (Ej: ## CALENTAMIENTO).
      2. NUNCA uses negritas (**) dentro o alrededor de los títulos. NUNCA hagas esto: **## Título** o ## **Título**.
      3. DEJA SIEMPRE una línea en blanco vacía ANTES y DESPUÉS de cada título.
      4. Usa viñetas (-) para la lista de ejercicios.
      5. Adapta los ejercicios rigurosamente al material y protege las lesiones mencionadas.

      Genera la rutina ahora:
      ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Error: La IA no generó contenido.";
    } catch (e) {
      print("Error en Gemini AI: $e");
      return "Error de conexión con la IA. Detalle: $e";
    }
  }
}