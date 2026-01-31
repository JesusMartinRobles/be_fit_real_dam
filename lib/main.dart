import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Importamos nuestros paquetes (como los 'import' de Java)
import 'config/theme.dart';
import 'screens/login_screen.dart';

// FUNCIÓN MAIN:
// CONCEPTOS JAVA: public static void main(String[] args)
// Es donde arranca el programa.
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que Flutter esté listo antes de inicializar Firebase.
  await Firebase.initializeApp();
  // runApp() toma el widget raíz y lo "pega" en la pantalla del móvil.
  runApp(const BeFitRealApp());
}

// CLASE BeFitRealApp:
// Es el widget raíz (Root). En Java Swing sería tu JFrame principal.
class BeFitRealApp extends StatelessWidget {
  const BeFitRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MATERIAL APP:
    // Es el "Dios" de la configuración. Provee navegación, estilos y estructura.
    return MaterialApp(
      // Título interno (administrador de tareas)
      title: 'Be Fit Real',

      // Oculta la etiqueta roja de "DEBUG"
      debugShowCheckedModeBanner: false,

      // TEMA (Estilos):
      // Aquí conectamos nuestra clase de configuración.
      theme: AppTheme.getTheme(),

      // HOME (Pantalla Inicial):
      // Le decimos qué widget mostrar al arrancar.
      home: const LoginScreen(),
    );
  }
}
