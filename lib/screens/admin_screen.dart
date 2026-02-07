import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// PANTALLA DE ADMINISTRACIÓN
// Aquí es donde gestionaré los datos de la app (Ejercicios, Materiales, Usuarios).
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
        // Botón atrás blanco para volver al Home
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("PANEL DE CONTROL", 
          style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      
      body: Container(
        // FONDO (Mismo que el resto de la app)
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(180), // Un poco más oscuro para seriedad
              BlendMode.darken,
            ),
          ),
        ),
        
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // TÍTULO DE BIENVENIDA
                Text(
                  "GESTIÓN GLOBAL",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.teko(
                    fontSize: 40, 
                    fontWeight: FontWeight.bold, 
                    color: primaryColor
                  ),
                ),
                Text(
                  "SELECCIONA UNA CATEGORÍA",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.teko(
                    fontSize: 20, 
                    color: Colors.white70
                  ),
                ),

                const SizedBox(height: 40),

                // GRILLA DE BOTONES (2 Columnas)
                // Uso Expanded para que la rejilla ocupe el espacio restante.
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // 2 columnas
                    crossAxisSpacing: 16, // Espacio horizontal entre botones
                    mainAxisSpacing: 16, // Espacio vertical entre botones
                    children: [
                      // 1. EJERCICIOS
                      _buildAdminCard(
                        icon: Icons.fitness_center,
                        title: "EJERCICIOS",
                        color: primaryColor,
                        onTap: () {
                          debugPrint("Ir a gestión de ejercicios");
                        },
                      ),

                      // 2. MATERIALES
                      _buildAdminCard(
                        icon: Icons.construction, // O dumbbell
                        title: "MATERIALES",
                        color: Colors.cyanAccent, // Color distinto para diferenciar
                        onTap: () {
                          debugPrint("Ir a gestión de materiales");
                        },
                      ),

                      // 3. USUARIOS
                      _buildAdminCard(
                        icon: Icons.group,
                        title: "USUARIOS",
                        color: Colors.orangeAccent,
                        onTap: () {
                          debugPrint("Ir a gestión de usuarios");
                        },
                      ),

                      // 4. CÓDIGOS INVITACIÓN
                      _buildAdminCard(
                        icon: Icons.vpn_key,
                        title: "CÓDIGOS",
                        color: Colors.purpleAccent,
                        onTap: () {
                          debugPrint("Ir a gestión de códigos");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIAR: TARJETA DE ADMINISTRACIÓN
  // Crea un botón cuadrado grande con icono y texto.
  Widget _buildAdminCard({
    required IconData icon, 
    required String title, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25), // Fondo Cristal
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(100), width: 2), // Borde del color de la sección
          boxShadow: [
            // Pequeño resplandor del color de la sección
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color), // Icono grande
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.teko(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}