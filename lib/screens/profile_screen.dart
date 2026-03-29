import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==============================================================================
// PANTALLA DE PERFIL (ESQUELETO)
// ARGUMENTO DE DEFENSA: "Al igual que el historial, esta pantalla sirve como 
// ancla de navegación temporal. El objetivo técnico aquí será crear un CRUD 
// (Create, Read, Update, Delete) donde el usuario pueda actualizar sus datos de 
// la colección 'users' de Firebase (como cambiar sus lesiones predeterminadas)."
// ==============================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("MI PERFIL", style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Text(
          "En desarrollo:\nGestión de datos de usuario y configuración.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 18),
        ),
      ),
    );
  }
}