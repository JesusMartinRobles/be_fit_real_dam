import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Para cerrar sesión
import 'routine_form_screen.dart'; // El formulario de rutina
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Método para cerrar sesión
  void _logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(160),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // --- CABECERA SUPERIOR ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Saludo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("HOLA, ATLETA", style: GoogleFonts.teko(color: Colors.white, fontSize: 24)),
                        Text("PANEL PRINCIPAL", style: GoogleFonts.teko(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold, height: 0.8)),
                      ],
                    ),
                    // Botón Salir
                    IconButton(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.white70),
                    )
                  ],
                ),

                const SizedBox(height: 40),

                // --- BOTONES DEL MENÚ ---
                // Uso Expanded para que ocupen el espacio disponible
                
                // 1. GENERAR RUTINA (El más grande e importante)
                _buildMenuCard(
                  context,
                  title: "GENERAR NUEVA RUTINA",
                  subtitle: "Crea un entreno personalizado con IA",
                  icon: Icons.auto_awesome,
                  color: primaryColor,
                  onTap: () {
                    // Navegamos al formulario
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RoutineFormScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 2. HISTORIAL
                _buildMenuCard(
                  context,
                  title: "MI HISTORIAL",
                  subtitle: "Consulta tus entrenamientos pasados",
                  icon: Icons.history,
                  color: Colors.white,
                  onTap: () {
                    // TODO: Ir a historial
                    debugPrint("Ir a historial");
                  },
                ),

                const SizedBox(height: 20),

                // 3. PERFIL
                _buildMenuCard(
                  context,
                  title: "MI PERFIL",
                  subtitle: "Datos físicos y configuración",
                  icon: Icons.person_outline,
                  color: Colors.white,
                  onTap: () {
                    // TODO: Ir a perfil
                    debugPrint("Ir a perfil");
                  },
                ),
                
                const Spacer(),
                
                // Logo pequeño abajo para marca
                Center(
                  child: Image.asset('assets/images/logo_white.png', height: 40, color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIAR: TARJETA DE MENÚ
  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20), // Fondo cristal muy sutil
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Row(
          children: [
            // Icono grande
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30), // Fondo del icono tintado
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.teko(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            // Flechita
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}