import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/database_service.dart';
import 'routine_result_screen.dart'; 

// ==============================================================================
// PANTALLA DE HISTORIAL (PERSISTENCIA DE DATOS)
// ARGUMENTO DE DEFENSA: "Para cumplir con el requisito de persistencia de la Tarea 3, 
// he implementado una lectura reactiva de la base de datos usando un StreamBuilder. 
// En lugar de traer todas las rutinas del club, la app consulta exclusivamente 
// la subcolección 'routines' del usuario autenticado actual (currentUser.uid). 
// Esto garantiza la privacidad de los datos. Además, he reutilizado la pantalla 
// 'RoutineResultScreen' para mostrar el detalle de las rutinas guardadas, aplicando 
// el principio de diseño DRY (Don't Repeat Yourself)."
// ==============================================================================
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();

  // MÉTODO AUXILIAR: Formateador de Fechas
  // Convierte el formato máquina (ISO 8601) en algo legible (DD/MM/YYYY - HH:MM)
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Fecha desconocida";
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // Obtenemos el usuario en el momento exacto de construir la pantalla
    // para garantizar que la sesión está activa y evitar fallos de lectura por IDs nulos.
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("MI HISTORIAL", style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      
      // Control de seguridad: Si no hay usuario, bloqueamos la vista
      body: currentUser == null 
        ? const Center(child: Text("Error: No se detecta usuario logueado.", style: TextStyle(color: Colors.redAccent)))
        : StreamBuilder<QuerySnapshot>(
            // Nos suscribimos a los cambios en la BD en tiempo real
            stream: _dbService.getUserRoutines(currentUser.uid),
            builder: (context, snapshot) {
              
              // 1. Estado de carga
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }

              // 2. Control de errores (Ej: Pérdida de conexión o reglas de Firestore)
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "No se pudo cargar el historial.\n${snapshot.error}", 
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // 3. Estado vacío (El usuario aún no ha generado rutinas)
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 80, color: Colors.white.withAlpha(50)),
                      const SizedBox(height: 20),
                      Text("Aún no tienes rutinas guardadas.", style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 18)),
                    ],
                  ),
                );
              }

              // 4. Renderizado de la lista
              final routines = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  // Extraemos los datos del documento JSON
                  final routineData = routines[index].data() as Map<String, dynamic>;
                  final routineId = routines[index].id;
                  
                  final focus = routineData['focus'] ?? 'Entrenamiento';
                  final date = routineData['date'] ?? '';
                  final text = routineData['text'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15), // Diseño Glassmorphism
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withAlpha(50)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Icon(Icons.fitness_center, color: primaryColor, size: 30),
                      
                      title: Text(
                        focus.toUpperCase(), 
                        style: GoogleFonts.teko(color: Colors.white, fontSize: 24, letterSpacing: 1)
                      ),
                      
                      subtitle: Text(
                        _formatDate(date),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ACCIÓN: Ver rutina (Reutiliza RoutineResultScreen)
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RoutineResultScreen(routineText: text),
                                ),
                              );
                            },
                          ),
                          // ACCIÓN: Borrar rutina (Llama al DatabaseService)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              _dbService.deleteRoutine(currentUser.uid, routineId);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}