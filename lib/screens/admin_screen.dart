import 'package:flutter/material.dart';

// Importación de las pantallas de destino
import 'materials_admin_screen.dart';
import 'invite_codes_screen.dart';

/// PANTALLA: AdminScreen (Panel de Control)
///
/// Actúa como un hub central (dashboard) exclusivo para usuarios con rol 'admin'.
/// Elección de implementación: Se ha diseñado una interfaz basada en tarjetas
/// expansivas (utilizando un método constructor privado) para mantener el código
/// limpio, cumplir el principio DRY y facilitar la escalabilidad futura si se
/// añaden nuevos módulos de administración.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extracción de la paleta corporativa desde el tema global
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
        title: const Text("PANEL DE CONTROL",
            style: TextStyle(
                fontFamily: 'Teko', color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      body: Container(
        // Renderizado del fondo corporativo con filtro de oscurecimiento
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- CABECERA DE LA VISTA ---
                Text("GESTIÓN GLOBAL",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Teko',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
                const Text("ADMINISTRACIÓN DEL SISTEMA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Teko',
                        fontSize: 22,
                        color: Colors.white70)),

                const SizedBox(height: 50),

                // --- MÓDULOS DE ADMINISTRACIÓN (Mapeo de Rutas) ---

                // 1. Módulo de Materiales
                _buildAdminButton(
                  icon: Icons.construction,
                  title: "GESTIONAR MATERIALES",
                  subtitle: "Añadir o eliminar equipamiento del club",
                  color: Colors.cyanAccent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const MaterialsAdminScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 2. Módulo de Códigos de Invitación
                _buildAdminButton(
                  icon: Icons.vpn_key,
                  title: "CÓDIGOS DE ACCESO",
                  subtitle: "Crear claves para nuevos miembros",
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const InviteCodesScreen()),
                    );
                  },
                ),

                const Spacer(),

                // Sello o marca de agua inferior para equilibrar el diseño
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

  /// Método Factoría Privado: _buildAdminButton
  ///
  /// Renderiza un botón estandarizado para las opciones del panel de control
  /// aplicando efectos de 'Glassmorphism' (Transparencias y desenfoques simulados).
  ///
  /// Entradas:
  /// - [icon]: Iconografía representativa del módulo.
  /// - [title]: Texto principal.
  /// - [subtitle]: Descripción secundaria.
  /// - [color]: Color de acento para la tarjeta (Bordes e iconos).
  /// - [onTap]: Función de tipo callback (VoidCallback) que ejecuta la navegación.
  Widget _buildAdminButton(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20), // Fondo cristalino
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
            // Icono destacado con contenedor tintado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),

            // Cuerpo de texto (Título y subtítulo)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Teko',
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

            // Indicador visual de interacción (Chevron)
            Icon(Icons.arrow_forward_ios,
                color: color.withAlpha(150), size: 18),
          ],
        ),
      ),
    );
  }
}
