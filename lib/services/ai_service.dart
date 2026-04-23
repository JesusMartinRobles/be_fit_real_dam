import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// SERVICIO: AIService (Integración con Inteligencia Artificial)
///
/// Gestiona la comunicación con el modelo de lenguaje de Google (Gemini AI).
/// Elección de implementación (Seguridad): La API Key no se encuentra 'hardcodeada'
/// en el código fuente (lo cual sería una vulnerabilidad grave), sino que se extrae
/// de forma segura en tiempo de ejecución a través de variables de entorno (archivo .env).
///
/// Arquitectura de Prompt Engineering: Se ha implementado un sistema de inyección
/// de contexto estructurado (System Prompting). Las instrucciones incluyen reglas
/// algorítmicas estrictas para obligar al LLM a devolver un formato Markdown validado
/// que no corrompa el motor de renderizado del frontend.
class AIService {
  /// Método Asíncrono: Generador de Rutinas
  ///
  /// Recibe los parámetros de estado del formulario y orquesta la petición a la API.
  Future<String> generateRoutine({
    required String focus,
    required String time,
    required List<String> materials,
    required String goal,
    required String injuries,
  }) async {
    // 1. Inyección Segura de Credenciales (Variable de Entorno)
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return "Error crítico: No se encontró la API Key en el archivo .env.";
    }

    // Instanciación del modelo generativo (Se usa la versión Flash por su baja latencia)
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    // Sanitización de parámetros vacíos
    final safeInjuries =
        injuries.trim().isEmpty ? "Ninguna molestia." : injuries;
    final materialsText = materials.join(", ");

    // 2. Construcción del Prompt (Contexto + Datos + Reglas Sintácticas)
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
      // 3. Ejecución de la llamada de red al modelo
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Error: La IA no generó contenido.";
    } catch (e) {
      final errorString = e.toString();
        
        // Si el error es por saturación de Google (503)
        if (errorString.contains('503') || errorString.contains('high demand')) {
          return "Los servidores de la IA están muy concurridos en este momento. Por favor, espera unos segundos y vuelve a pulsar el botón.";
        }
        
        // Si el error es de red genérico (el móvil no tiene Wifi/Datos)
        return "Error de conexión con el servicio de IA. Comprueba tu conexión a internet.";
    }
  }
}
