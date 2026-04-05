import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

// ==============================================================================
// FUNCIÓN MAIN (SÚPER LIGERA)
// ==============================================================================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ¡ARRANCAMOS INMEDIATAMENTE!
  // Esto le da al depurador de VS Code (F5) un "enganche" instantáneo,
  // evitando la pantalla negra o los bloqueos "zombie".
  runApp(const BeFitRealApp());
}

class BeFitRealApp extends StatelessWidget {
  const BeFitRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be Fit Real',
      debugShowCheckedModeBanner: false,
      
      // Aplicamos el tema Teko globalmente desde el milisegundo 1
      theme: AppTheme.getTheme(),
      
      // En lugar de hacer condicionales aquí, vamos directos a la pantalla de carga
      home: const SplashScreen(),
    );
  }
}

// ==============================================================================
// PANTALLA DE CARGA (SPLASH SCREEN)
// Aquí es donde se hace todo el trabajo pesado de forma segura en segundo plano.
// ==============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // Nada más aparecer esta pantalla, empezamos a cargar el backend
    _bootApp();
  }

  Future<void> _bootApp() async {
    try {
      // 1. Cargamos configuración
      await dotenv.load(fileName: ".env");
      
      // 2. Cargamos Firebase
      await Firebase.initializeApp();
      
      // 3. Leemos la memoria
      final prefs = await SharedPreferences.getInstance();
      
      // 🟢 TRUCO PARA PRUEBAS: 
      // Si quieres volver a ver la Guía Interactiva, descomenta esta línea,
      // guarda y ejecuta. Luego vuelve a comentarla.
      // await prefs.setBool('hasSeenOnboarding', false); 

      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // 4. Pausa estética para que el usuario vea el logo (1.5 segundos)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 5. NAVEGACIÓN
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => hasSeenOnboarding ? const LoginScreen() : const OnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error crítico en arranque: $e");
    }
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