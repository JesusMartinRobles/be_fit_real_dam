import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

/// PANTALLA: OnboardingScreen (Guía Interactiva de Bienvenida)
///
/// Componente obligatorio que introduce al usuario a las funcionalidades clave.
/// Elección de implementación: Se utiliza [PageView] para una navegación gestual fluida.
/// Para cumplir el requisito de "mostrarse solo en su primera ejecución", se integra
/// el paquete [shared_preferences]. Al finalizar el recorrido, se inyecta un 'flag'
/// booleano ('hasSeenOnboarding') en la memoria persistente del dispositivo.
/// Esta estrategia es altamente eficiente porque evita peticiones de red redundantes
/// durante los arranques futuros de la aplicación.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  /// Método Privado: Finalización del recorrido
  ///
  /// Registra localmente que el usuario ha completado el tutorial y ejecuta una
  /// navegación destructiva ([pushReplacement]) hacia el Login, evitando que el
  /// usuario pueda volver a esta pantalla usando el botón físico "Atrás" de Android.
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
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
          // --- CAPA FONDO ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E1E1E), Colors.black],
              ),
            ),
          ),

          // --- CAPA INTERACTIVA: CARRUSEL ---
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _isLastPage =
                    index == 2; // Basado en 3 páginas (índices 0, 1, 2)
              });
            },
            children: [
              _buildPage(
                title: "INTELIGENCIA ARTIFICIAL",
                subtitle:
                    "Rutinas creadas por Gemini AI basadas en tu nivel, tiempo y objetivos.",
                icon: Icons.auto_awesome,
                color: primaryColor,
              ),
              _buildPage(
                title: "ADÁPTALO A TI",
                subtitle:
                    "Selecciona tu material (paralelas, lastre...) y protege tus articulaciones (menisco, muñeca...).",
                icon: Icons.accessibility_new,
                color: Colors.blueAccent,
              ),
              _buildPage(
                title: "GUARDA TU PROGRESO",
                subtitle:
                    "Todo tu historial sincronizado en la nube para que nunca pierdas un entrenamiento.",
                icon: Icons.cloud_done,
                color: Colors.greenAccent,
              ),
            ],
          ),

          // --- CAPA DE NAVEGACIÓN Y CONTROLES ---
          Container(
            alignment: const Alignment(0, 0.85),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Acción Secundaria: Saltar Tutorial
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text("SALTAR",
                        style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ),

                  // Feedback Visual: Indicadores de Progreso
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withAlpha(
                              _controller.hasClients &&
                                      _controller.page?.round() == index
                                  ? 255
                                  : 50),
                        ),
                      );
                    }),
                  ),

                  // Acción Principal: Siguiente / Empezar
                  _isLastPage
                      ? ElevatedButton(
                          onPressed: _completeOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("EMPEZAR",
                              style: TextStyle(
                                  fontFamily: 'Teko',
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        )
                      : IconButton(
                          onPressed: () {
                            _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                          },
                          icon: Icon(Icons.arrow_forward_ios,
                              color: primaryColor),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constructor de Widgets Reutilizable: _buildPage
  ///
  /// Abstrae la estructura visual de cada diapositiva del tutorial para cumplir
  /// con el principio DRY y facilitar el mantenimiento de los contenidos descriptivos.
  Widget _buildPage(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color}) {
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
            style: const TextStyle(
                fontFamily: 'Teko',
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                height: 1.0),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
