import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

/// PUNTO DE ENTRADA: main()
///
/// Función principal que arranca la aplicación de Flutter.
/// Elección de implementación: Se asegura la vinculación de los widgets y
/// se lanza inmediatamente la UI ([BeFitRealApp]) sin bloquear el hilo principal.
/// Las inicializaciones pesadas (Firebase, Variables de Entorno) se delegan
/// asíncronamente a la [SplashScreen] para evitar pantallas negras en el arranque.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BeFitRealApp());
}

class BeFitRealApp extends StatelessWidget {
  const BeFitRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be Fit Real',
      debugShowCheckedModeBanner: false,

      // Aplicación del sistema de diseño (Design System) global
      theme: AppTheme.getTheme(),

      // Delegación de ruteo inicial a la pantalla de carga (Middleware)
      home: const SplashScreen(),
    );
  }
}

/// PANTALLA: SplashScreen (Pantalla de Carga y Enrutamiento)
///
/// Actúa como un interceptor de inicialización. Mientras el usuario visualiza
/// una interfaz amigable, la app carga dependencias críticas y determina el
/// árbol de navegación inicial basándose en la persistencia local.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootApp();
  }

  /// Método Asíncrono: Secuencia de Arranque (Boot Sequence)
  Future<void> _bootApp() async {
    try {
      // 1. Carga de Variables de Entorno (API Keys)
      await dotenv.load(fileName: ".env");

      // 2. Inicialización del Backend as a Service (BaaS)
      await Firebase.initializeApp();

      // 3. Lectura de estado de Onboarding (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // 4. Pausa de cortesía (UX)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 5. Resolución de Enrutamiento
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => hasSeenOnboarding
                ? const LoginScreen()
                : const OnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint("Excepción fatal en secuencia de arranque: $e");
      // Fallback Visual: Previene que la app se quede colgada infinitamente
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  /// Feedback visual en caso de que falte el archivo .env o falle Firebase
  void _showErrorDialog(String errorMsg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("ERROR DE INICIALIZACIÓN",
            style: TextStyle(
                fontFamily: 'Teko', color: Colors.redAccent, fontSize: 24)),
        content: Text(
          "La aplicación no pudo arrancar. Verifica tu conexión a internet o la existencia del archivo .env.\n\nDetalle técnico: $errorMsg",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_white.png', height: 120),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Color(0xFFAAD816)),
          ],
        ),
      ),
    );
  }
}
