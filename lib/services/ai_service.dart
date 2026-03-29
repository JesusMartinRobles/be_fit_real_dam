import 'package:google_generative_ai/google_generative_ai.dart';

// ==============================================================================
// SERVICIO DE INTELIGENCIA ARTIFICIAL (GEMINI)
// ARGUMENTO DE DEFENSA: "Para la generación de rutinas he utilizado la API oficial 
// de Google Generative AI (Gemini 1.5 Flash por su velocidad). He encapsulado esta 
// lógica en un servicio independiente mediante el patrón Singleton para mantener 
// la arquitectura limpia y separar la lógica de negocio de la interfaz gráfica."
// ==============================================================================

class AIService {
  // 1. CONFIGURACIÓN
  // ATENCIÓN: En un entorno de producción real, esta clave NO debe estar hardcodeada aquí,
  // sino en un archivo .env oculto. Para este MVP académico, la dejamos aquí por simplicidad.
  static const String _apiKey = 'AIzaSyANrI1Z0lpgt9jaxh6Jj5TtLMYiuQU52-w'; 
  
  // Usamos el modelo 'gemini-1.5-flash' porque es rapidísimo y muy bueno siguiendo instrucciones.
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  // 2. MÉTODO PRINCIPAL: GENERAR RUTINA
  // Recibe todos los datos del formulario y devuelve un String (el texto de la rutina).
  Future<String> generateRoutine({
    required String focus,
    required String time,
    required List<String> materials,
    required String goal,
    required String injuries,
  }) async {
    
    // Si no ha puesto molestias, le pasamos "Ninguna" por defecto
    final safeInjuries = injuries.trim().isEmpty ? "Ninguna molestia o lesión." : injuries;
    
    // Formateamos la lista de materiales separados por comas
    final materialsText = materials.join(", ");

    // 3. EL "PROMPT ENGINEERING" (Ingeniería de Prompts)
    // Aquí está el verdadero valor del proyecto. Le damos a la IA un contexto estricto,
    // un rol y unas reglas inquebrantables de cómo debe responder.
    final String prompt = '''
      Eres un Entrenador Personal de Élite y experto en Calistenia, Entrenamiento Funcional y Musculación.
      Tu tarea es diseñar una rutina de entrenamiento altamente efectiva, segura y directa al grano, 
      basada EXCLUSIVAMENTE en los siguientes parámetros del usuario:

      --- PARÁMETROS DEL USUARIO ---
      - Enfoque del día: $focus
      - Tiempo máximo disponible: $time minutos
      - Objetivo principal: $goal
      - Material disponible: $materialsText
      - Lesiones o molestias a tener en cuenta: $safeInjuries

      --- REGLAS ESTRICTAS PARA LA CREACIÓN ---
      1. ADAPTACIÓN AL MATERIAL: Si el usuario NO tiene cierto material (ej: barra de dominadas o TRX), NO puedes incluir ejercicios que lo requieran. Adapta los ejercicios al material listado o a peso corporal.
      2. SEGURIDAD: Ten MUY en cuenta las lesiones ($safeInjuries). Adapta los ejercicios para no agravarlas (ej: si duele el menisco o la muñeca, evita impactos y flexiones extremas).
      3. ESTRUCTURA: La rutina DEBE incluir un Calentamiento breve, el Bloque Principal y una Vuelta a la Calma.
      4. FORMATO: Debes devolver la rutina usando formato Markdown para que se vea bonita en la app. Usa ## para títulos grandes, **negritas** para los nombres de los ejercicios, y listas con viñetas (-).
      5. TONO: Motivador pero muy profesional. No te enrolles con introducciones largas, ve directo a la rutina.

      Genera la rutina ahora:
      ''';

    try {
      // 4. LLAMADA A LA API
      // Enviamos el mensaje a los servidores de Google y esperamos la respuesta.
      final response = await _model.generateContent([Content.text(prompt)]);
      
      // Devolvemos el texto generado, o un mensaje de error si vino vacío.
      return response.text ?? "Error: La IA no pudo generar texto en este momento.";
      
    } catch (e) {
      // Capturamos cualquier error (sin internet, clave incorrecta...)
      print("Error en Gemini AI: $e");
      return "Lo siento, ha habido un error al conectar con la IA.\nVerifica tu conexión a internet o intenta de nuevo más tarde.\n\nDetalle técnico: $e";
    }
  }
}