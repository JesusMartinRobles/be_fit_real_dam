import 'package:flutter/foundation.dart'; // Importante para debugPrint
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/material_model.dart';
import '../models/invite_code_model.dart';

/// SERVICIO: DatabaseService (Capa de Persistencia de Datos)
///
/// Abstrae todas las operaciones CRUD (Create, Read, Update, Delete) contra Cloud Firestore.
/// Elección de implementación (Seguridad y Privacidad): El historial de
/// entrenamientos generados por la IA no se guarda en una colección pública,
/// sino que se almacena como documentos en una subcolección dinámica ('routines')
/// anidada dentro del documento personal de cada usuario (`users/{uid}/routines`).
/// Esto garantiza la encapsulación de datos y facilita la aplicación de reglas
/// de seguridad estrictas en el servidor.
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Constantes de colecciones globales
  final String _materialsCollection = 'materials';
  final String _codesCollection = 'invite_codes';

  // ===========================================================================
  // MÓDULO 1: GESTIÓN DE MATERIALES (ADMINISTRACIÓN)
  // ===========================================================================

  /// Añade un nuevo material a la colección global.
  Future<void> addMaterial(String name) async {
    await _db.collection(_materialsCollection).add({'name': name});
  }

  /// Retorna un flujo (Stream) reactivo de materiales, ordenados alfabéticamente.
  Stream<List<MaterialModel>> getMaterials() {
    return _db
        .collection(_materialsCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MaterialModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Elimina un material específico mediante su ID de documento.
  Future<void> deleteMaterial(String materialId) async {
    await _db.collection(_materialsCollection).doc(materialId).delete();
  }

  // ===========================================================================
  // MÓDULO 2: GESTIÓN DE CÓDIGOS DE INVITACIÓN (ADMINISTRACIÓN)
  // ===========================================================================

  /// Genera un nuevo documento de código de acceso, activado por defecto.
  Future<void> addInviteCode(String code) async {
    try {
      await _db.collection(_codesCollection).add({
        'code': code,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Error en capa de datos (addInviteCode): $e");
      rethrow; // Relanza la excepción original conservando el StackTrace
    }
  }

  /// Retorna un flujo (Stream) de los códigos existentes, del más reciente al más antiguo.
  Stream<List<InviteCodeModel>> getInviteCodes() {
    return _db
        .collection(_codesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InviteCodeModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Invalida y elimina un código de la base de datos.
  Future<void> deleteInviteCode(String id) async {
    await _db.collection(_codesCollection).doc(id).delete();
  }

  // ===========================================================================
  // MÓDULO 3: HISTORIAL DE RUTINAS (PERSISTENCIA DE USUARIO)
  // ===========================================================================

  /// CREATE: Almacena un nuevo entrenamiento en la subcolección privada del usuario.
  Future<void> saveRoutine(
      String userId, String routineText, String focus) async {
    try {
      await _db.collection('users').doc(userId).collection('routines').add({
        'text': routineText, // Texto Markdown limpio o crudo
        'focus': focus, // Etiqueta principal (Ej: "Push")
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Error guardando la rutina en Firebase: $e");
    }
  }

  /// READ: Retorna un flujo reactivo del historial del usuario autenticado.
  Stream<QuerySnapshot> getUserRoutines(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('routines')
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// DELETE: Elimina un entrenamiento específico del historial personal.
  Future<void> deleteRoutine(String userId, String routineId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('routines')
        .doc(routineId)
        .delete();
  }
}
