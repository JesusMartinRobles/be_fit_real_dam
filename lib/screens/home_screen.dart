import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importaciones de Firebase para la seguridad de rutas
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

import 'login_screen.dart'; 
import 'routine_form_screen.dart'; 
import 'admin_screen.dart'; 
import 'history_screen.dart'; 
import 'profile_screen.dart'; 
import '../services/auth_service.dart';

// ==============================================================================
// PANEL PRINCIPAL (HOME SCREEN)
// Esta es la pantalla central (Hub) de la app. Para 
// gestionar el botón de Administración he implementado una comprobación de 
// seguridad asíncrona. En el 'initState', la app hace una petición a Firestore 
// para leer el documento del usuario logueado. Solo si el campo 'role' es 
// estrictamente igual a 'admin', se actualiza el estado y se renderiza el botón. 
// Esto evita que usuarios estándar inyecten código para ver el panel.
// ==============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Por defecto asumo que NADIE es admin, por seguridad (Fail-Safe)
  bool _isAdmin = false; 

  @override
  void initState() {
    super.initState();
    _checkRole(); // Disparo la comprobación al cargar la pantalla
  }

  // MÉTODO PRIVADO: COMPROBACIÓN DE ROL (BACKEND SEGURO)
  Future<void> _checkRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      
      if (userDoc.exists) {
        // Extraemos los datos como un Mapa (Diccionario) para poder preguntar si existe la "llave"
        final data = userDoc.data() as Map<String, dynamic>?;
        
        setState(() {
          // Si los datos existen, Y contienen el campo 'role', Y ese rol es 'admin'... entonces es true.
          // Si falla cualquiera de esas tres cosas, se queda en false de forma segura.
          _isAdmin = data != null && data.containsKey('role') && data['role'] == 'admin';
        });
      }
    }
  }

  // MÉTODO PARA CERRAR SESIÓN DE FORMA SEGURA
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
                
                // --- CABECERA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("HOLA, ATLETA", style: GoogleFonts.teko(color: Colors.white, fontSize: 24)),
                        Text("PANEL PRINCIPAL", style: GoogleFonts.teko(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold, height: 0.8)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.white70),
                    )
                  ],
                ),

                const SizedBox(height: 40),

                // --- MENÚ PRINCIPAL (BOTONES NAVEGABLES) ---
                
                // 1. GENERAR RUTINA (FLUJO IA)
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

                // 2. HISTORIAL (FLUJO PERSISTENCIA DE DATOS)
                _buildMenuCard(
                  context,
                  title: "MI HISTORIAL",
                  subtitle: "Consulta tus entrenamientos pasados",
                  icon: Icons.history,
                  color: Colors.white,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 3. PERFIL (FLUJO GESTIÓN DE USUARIO)
                _buildMenuCard(
                  context,
                  title: "MI PERFIL",
                  subtitle: "Datos físicos y configuración",
                  icon: Icons.person_outline,
                  color: Colors.white,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                
                const Spacer(),

                // --- ZONA CRÍTICA: BOTÓN ADMINISTRADOR OCULTO ---
                // Uso un spread operator (...) condicional. Si _isAdmin es false, 
                // estos widgets literalmente no existen en el árbol de renderizado.
                if (_isAdmin) ...[
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(30),
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

  // WIDGET REUTILIZABLE LOCALMENTE PARA MANTENER CÓDIGO LIMPIO
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