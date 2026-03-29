import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==============================================================================
// PANTALLA DE HISTORIAL (ESQUELETO)
// ARGUMENTO DE DEFENSA: "Para construir la navegación de la app, utilizo un 
// enfoque de desarrollo iterativo. Primero creo los 'esqueletos' de las pantallas 
// para asegurar que las rutas funcionan sin romper el hilo principal. 
// En la siguiente fase, esta pantalla se conectará a la colección 'routines' de 
// Firebase para cargar las rutinas guardadas del usuario usando un StreamBuilder."
// ==============================================================================
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("MI HISTORIAL", style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Text(
          "En desarrollo:\nAquí se listarán tus rutinas generadas.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 18),
        ),
      ),
    );
  }
}