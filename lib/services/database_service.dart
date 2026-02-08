import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/material_model.dart';
import '../models/invite_code_model.dart'; // <--- IMPORTACIÓN NUEVA

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  final String _materialsCollection = 'materials';
  final String _codesCollection = 'invite_codes'; // Nueva colección

  // --- MATERIALES (Ya lo tenías, lo dejo igual) ---
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

  // --- CÓDIGOS DE INVITACIÓN (NUEVO) ---

  // 1. AÑADIR CÓDIGO
  Future<void> addInviteCode(String code) async {
    try {
      await _db.collection(_codesCollection).add({
        'code': code,
        'isActive': true, // Por defecto nace activo
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error al crear código: $e");
      throw e;
    }
  }

  // 2. LEER CÓDIGOS
  Stream<List<InviteCodeModel>> getInviteCodes() {
    return _db.collection(_codesCollection)
      .orderBy('createdAt', descending: true) // Los más nuevos primero
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return InviteCodeModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
  }

  // 3. BORRAR CÓDIGO
  Future<void> deleteInviteCode(String id) async {
    await _db.collection(_codesCollection).doc(id).delete();
  }
}