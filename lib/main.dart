import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- LIBRERÍA DE SEGURIDAD (NUEVO)

// Importamos nuestros paquetes (como los 'import' de Java)
import 'config/theme.dart';
import 'screens/login_screen.dart';

// ==============================================================================
// FUNCIÓN MAIN:
// CONCEPTOS JAVA: public static void main(String[] args)
// Es donde arranca el programa.
// ARGUMENTO DE DEFENSA: "Para garantizar la seguridad del código en un repositorio 
// público, he implementado variables de entorno usando 'flutter_dotenv'. 
// Antes de que la app arranque, cargo el archivo '.env' de forma asíncrona. 
// Esto me permite mantener mis claves API seguras y fuera del control de versiones."
// ==============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté listo antes de inicializar Firebase y otras cosas.
  
  // 1. CARGAMOS LAS VARIABLES SECRETAS (NUEVO)
  // Debe ir antes de inicializar la app para que las claves estén disponibles.
  await dotenv.load(fileName: ".env");

  // 2. INICIALIZAMOS FIREBASE (Método tradicional)
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