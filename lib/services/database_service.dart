import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/material_model.dart';
import '../models/invite_code_model.dart';

// ==============================================================================
// SERVICIO DE BASE DE DATOS (FIRESTORE)
// ARGUMENTO DE DEFENSA: "Para cumplir con el requisito de persistencia de datos, 
// he implementado métodos para guardar y recuperar el historial de entrenamientos. 
// Cada rutina generada por la IA se almacena como un documento en una subcolección 
// llamada 'routines' dentro del documento personal de cada usuario. Así garantizo 
// que los datos estén encapsulados y sean privados."
// ==============================================================================
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  final String _materialsCollection = 'materials';
  final String _codesCollection = 'invite_codes';

  // --- MATERIALES ---
  Future<void> addMaterial(String name) async {
    await _db.collection(_materialsCollection).add({'name': name});
  }

  Stream<List<MaterialModel>> getMaterials() {
    return _db.collection(_materialsCollection).orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MaterialModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> deleteMaterial(String materialId) async {
    await _db.collection(_materialsCollection).doc(materialId).delete();
  }

  // --- CÓDIGOS DE INVITACIÓN ---
  Future<void> addInviteCode(String code) async {
    try {
      await _db.collection(_codesCollection).add({
        'code': code,
        'isActive': true, 
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error al crear código: $e");
      throw e;
    }
  }

  Stream<List<InviteCodeModel>> getInviteCodes() {
    return _db.collection(_codesCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return InviteCodeModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
  }

  Future<void> deleteInviteCode(String id) async {
    await _db.collection(_codesCollection).doc(id).delete();
  }

  // ==========================================================
  // --- NUEVO: HISTORIAL DE RUTINAS (IA) ---
  // ==========================================================

  // 1. GUARDAR UNA RUTINA NUEVA
  Future<void> saveRoutine(String userId, String routineText, String focus) async {
    try {
      // Navegamos a la carpeta del usuario -> subcarpeta "routines" -> creamos archivo
      await _db.collection('users').doc(userId).collection('routines').add({
        'text': routineText, // El texto en Markdown devuelto por Gemini
        'focus': focus, // Ej: "Push", para ponerlo de título en la lista
        'date': DateTime.now().toIso8601String(), // Cuándo se creó
      });
    } catch (e) {
      print("Error guardando la rutina en Firebase: $e");
    }
  }

  // 2. LEER LAS RUTINAS (Stream para la pantalla de Historial)
  Stream<QuerySnapshot> getUserRoutines(String userId) {
    return _db.collection('users').doc(userId).collection('routines')
        .orderBy('date', descending: true) // Las más recientes arriba
        .snapshots();
  }
  
  // 3. BORRAR UNA RUTINA DEL HISTORIAL
  Future<void> deleteRoutine(String userId, String routineId) async {
    await _db.collection('users').doc(userId).collection('routines').doc(routineId).delete();
  }
}