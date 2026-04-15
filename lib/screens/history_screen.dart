import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/database_service.dart';
import 'routine_result_screen.dart';

/// PANTALLA: HistoryScreen (Historial de Entrenamientos)
///
/// Mecanismo de persistencia de datos (Requisito Tarea 3).
/// Elección de implementación: Se emplea un [StreamBuilder] para establecer un
/// canal reactivo con la base de datos (Cloud Firestore). Las consultas se filtran
/// obligatoriamente por el 'uid' del usuario autenticado actual, garantizando
/// un aislamiento total de la información (Privacidad de datos).
/// Además, se aplica el principio DRY (Don't Repeat Yourself) reciclando la
/// clase [RoutineResultScreen] para renderizar el detalle de las rutinas pasadas.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Instancia del servicio que actúa como capa de abstracción sobre Firestore
  final DatabaseService _dbService = DatabaseService();

  /// Método Auxiliar: Formateador de Fechas
  ///
  /// Entradas: Un String con la fecha en formato ISO 8601 puro.
  /// Salidas: Un String amigable para el usuario (DD/MM/YYYY - HH:MM).
  /// Manejo de errores: Si la fecha está corrupta en la BBDD, devuelve una cadena segura.
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Fecha desconocida";
    }
  }

  /// Diálogo de Confirmación Destructiva
  ///
  /// Evita que el usuario borre un entrenamiento del historial por accidente.
  void _confirmDelete(BuildContext context, String userId, String routineId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("¿BORRAR RUTINA?",
            style: TextStyle(
                fontFamily: 'Teko',
                color: Colors.redAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        content: const Text(
          "Se eliminará este entrenamiento de tu historial permanentemente.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              _dbService.deleteRoutine(userId, routineId);
              Navigator.pop(ctx);
            },
            child: const Text("ELIMINAR",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Extracción temprana del estado de sesión para evitar NullPointerExceptions
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("MI HISTORIAL",
            style: TextStyle(
                fontFamily: 'Teko', color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),

      // Control de acceso: Fallback seguro si el usuario cierra sesión abruptamente
      body: currentUser == null
          ? const Center(
              child: Text("Error: No se detecta usuario logueado.",
                  style: TextStyle(color: Colors.redAccent)))
          : StreamBuilder<QuerySnapshot>(
              // Suscripción al stream filtrado por UID
              stream: _dbService.getUserRoutines(currentUser.uid),
              builder: (context, snapshot) {
                // Estado 1: Latencia de red
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                }

                // Estado 2: Error de servidor o reglas de seguridad
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No se pudo cargar el historial.\n${snapshot.error}",
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // Estado 3: Base de datos vacía (Usuario nuevo)
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off,
                            size: 80, color: Colors.white.withAlpha(50)),
                        const SizedBox(height: 20),
                        Text("Aún no tienes rutinas guardadas.",
                            style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 18)),
                      ],
                    ),
                  );
                }

                // Estado 4: Renderizado de la estructura de datos
                final routines = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    // Deserialización superficial (JSON a Mapa local)
                    final routineData =
                        routines[index].data() as Map<String, dynamic>;
                    final routineId = routines[index].id;

                    final focus = routineData['focus'] ?? 'Entrenamiento';
                    final date = routineData['date'] ?? '';
                    final text = routineData['text'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withAlpha(50)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        leading: Icon(Icons.fitness_center,
                            color: primaryColor, size: 30),
                        title: Text(focus.toUpperCase(),
                            style: const TextStyle(
                                fontFamily: 'Teko',
                                color: Colors.white,
                                fontSize: 24,
                                letterSpacing: 1)),
                        subtitle: Text(
                          _formatDate(date),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ACCIÓN: Visualización de la rutina
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RoutineResultScreen(routineText: text),
                                  ),
                                );
                              },
                            ),
                            // ACCIÓN: Borrado (Con confirmación previa obligatoria)
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => _confirmDelete(
                                  context, currentUser.uid, routineId),
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
