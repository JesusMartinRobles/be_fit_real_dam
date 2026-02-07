import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Para cerrar sesión
import 'routine_form_screen.dart'; // El formulario de rutina
import 'admin_screen.dart'; // <--- IMPORTANTE: La pantalla de Admin que crearemos luego
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // NOTA PARA MÍ:
  // Esta variable simula si el usuario es Admin.
  // MÁS ADELANTE: Esto vendrá de la base de datos de Firebase.
  // Por ahora lo pongo en 'false' para poder programar la pantalla.
  bool _isAdmin = true; 

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

                // --- MENÚ PRINCIPAL ---
                
                // 1. GENERAR RUTINA
                _buildMenuCard(
                  context,
                  title: "GENERAR NUEVA RUTINA",
                  subtitle: "Crea un entreno personalizado con IA",
                  icon: Icons.auto_awesome,
                  color: primaryColor,
                  onTap: () {
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
                    debugPrint("Ir a perfil");
                  },
                ),
                
                const Spacer(),

                // --- ZONA ADMIN (SOLO VISIBLE SI _isAdmin es true) ---
                if (_isAdmin) ...[
                  const Divider(color: Colors.white24), // Línea separadora
                  const SizedBox(height: 10),
                  
                  // Botón especial de Admin
                  InkWell(
                    onTap: () {
                      // NAVEGACIÓN: Ir al Panel de Admin
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(30), // Fondo rojizo para destacar
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Text(
                            "PANEL DE ADMINISTRADOR",
                            style: GoogleFonts.teko(
                              color: Colors.redAccent, 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Logo pequeño marca de agua
                Center(
                  child: Image.asset('assets/images/logo_white.png', height: 30, color: Colors.white38),
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
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.teko(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}