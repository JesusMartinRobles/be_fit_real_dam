import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importo las pantallas a las que voy a navegar
import 'materials_admin_screen.dart';
import 'invite_codes_screen.dart';

// PANTALLA DE ADMINISTRACIÓN
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("PANEL DE CONTROL", 
          style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(180), 
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
                
                // CABECERA
                Text("GESTIÓN GLOBAL", textAlign: TextAlign.center,
                  style: GoogleFonts.teko(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor)),
                Text("ADMINISTRACIÓN DEL SISTEMA", textAlign: TextAlign.center,
                  style: GoogleFonts.teko(fontSize: 22, color: Colors.white70)),

                const SizedBox(height: 50),

                // LISTA VERTICAL DE BOTONES
                // Al usar Column con crossAxisAlignment.stretch, ocupan todo el ancho.
                
                // 1. MATERIALES (El más importante ahora)
                _buildAdminButton(
                  icon: Icons.construction, 
                  title: "GESTIONAR MATERIALES",
                  subtitle: "Añadir o eliminar equipamiento del club",
                  color: Colors.cyanAccent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MaterialsAdminScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 2. USUARIOS
                _buildAdminButton(
                  icon: Icons.group,
                  title: "GESTIONAR USUARIOS",
                  subtitle: "Ver usuarios registrados y baneos",
                  color: Colors.orangeAccent,
                  onTap: () {
                    debugPrint("Ir a gestión de usuarios");
                  },
                ),

                const SizedBox(height: 20),

                // 3. CÓDIGOS DE INVITACIÓN
                _buildAdminButton(
                  icon: Icons.vpn_key,
                  title: "CÓDIGOS DE ACCESO",
                  subtitle: "Crear claves para nuevos miembros",
                  color: Colors.purpleAccent,
                  onTap: () {
                    // NAVEGACIÓN A LA PANTALLA DE CÓDIGOS
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InviteCodesScreen()),
                    );
                  },
                ),
                
                const Spacer(),
                
                // Marca de agua
                const Center(
                  child: Icon(Icons.security, size: 40, color: Colors.white10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIAR: BOTÓN ADMIN ANCHO
  // He rediseñado esto para que sea una fila (Row) en lugar de una columna.
  Widget _buildAdminButton({
    required IconData icon, 
    required String title, 
    required String subtitle,
    required Color color, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20), // Fondo Cristal
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(100), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 15,
              spreadRadius: -5,
            )
          ],
        ),
        child: Row(
          children: [
            // Icono a la izquierda con fondo tintado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            
            // Textos en el centro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.teko(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Flecha a la derecha
            Icon(Icons.arrow_forward_ios, color: color.withAlpha(150), size: 18),
          ],
        ),
      ),
    );
  }
}