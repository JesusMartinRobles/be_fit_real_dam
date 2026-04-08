import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

// ==============================================================================
// PANTALLA DE GUÍA INTERACTIVA (ONBOARDING)
// Para cumplir con el requisito obligatorio de la guía 
// interactiva, he implementado un 'PageView' que muestra las funcionalidades clave. 
// Para garantizar que solo se muestre en la primera ejecución, utilizo el paquete 
// 'shared_preferences'. Al finalizar la guía, se guarda un flag booleano en la 
// memoria local del dispositivo (no en la nube, por eficiencia). El archivo main.dart 
// lee este flag antes de arrancar para decidir si muestra esta guía o salta al Login.
// ==============================================================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  // Método que guarda en la memoria del móvil que ya hemos visto la guía
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true); // Guardamos la variable local
    
    if (mounted) {
      // Navegamos al Login y borramos la guía del historial de navegación
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // FONDO (Podrías poner una imagen, pero aquí un gradiente oscuro queda elegante)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ Color(0xFF1E1E1E), Colors.black],
              ),
            ),
          ),
          
          // CARRUSEL DE PÁGINAS
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == 2; // Son 3 páginas (0, 1, 2)
              });
            },
            children: [
              _buildPage(
                title: "INTELIGENCIA ARTIFICIAL",
                subtitle: "Rutinas creadas por Gemini AI basadas en tu nivel, tiempo y objetivos.",
                icon: Icons.auto_awesome,
                color: primaryColor,
              ),
              _buildPage(
                title: "ADÁPTALO A TI",
                subtitle: "Selecciona tu material (paralelas, lastre...) y protege tus articulaciones (menisco, muñeca...).",
                icon: Icons.accessibility_new,
                color: Colors.blueAccent,
              ),
              _buildPage(
                title: "GUARDA TU PROGRESO",
                subtitle: "Todo tu historial sincronizado en la nube para que nunca pierdas un entrenamiento.",
                icon: Icons.cloud_done,
                color: Colors.greenAccent,
              ),
            ],
          ),

          // CONTROLES INFERIORES (Puntos y Botones)
          Container(
            alignment: const Alignment(0, 0.85),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón SALTAR
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text("SALTAR", style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ),

                  // INDICADORES DE PÁGINA (Puntitos)
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withAlpha(_controller.hasClients && _controller.page?.round() == index ? 255 : 50),
                        ),
                      );
                    }),
                  ),

                  // Botón SIGUIENTE o EMPEZAR
                  _isLastPage
                    ? ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("EMPEZAR", style: GoogleFonts.teko(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                      )
                    : IconButton(
                        onPressed: () {
                          _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                        },
                        icon: Icon(Icons.arrow_forward_ios, color: primaryColor),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET REUTILIZABLE PARA LAS PÁGINAS
  Widget _buildPage({required String title, required String subtitle, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: color),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.teko(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.0),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}