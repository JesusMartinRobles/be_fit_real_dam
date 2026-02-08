import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/material_model.dart'; // Importo mi nuevo modelo

// CLASE DATABASE SERVICE
// Se encarga de hablar con Firestore.
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Nombre de la colección en la nube
  final String _materialsCollection = 'materials';

  // 1. AÑADIR MATERIAL (CREATE)
  Future<void> addMaterial(String name) async {
    try {
      // Creo un documento nuevo con ID automático
      await _db.collection(_materialsCollection).add({
        'name': name,
        // Podríamos añadir 'createdAt' si quisiéramos ordenar por fecha
      });
    } catch (e) {
      print("Error al añadir material: $e");
      throw e;
    }
  }

  // 2. LEER MATERIALES (READ - STREAM)
  // Devuelve una lista viva que se actualiza sola.
  Stream<List<MaterialModel>> getMaterials() {
    return _db.collection(_materialsCollection)
      .orderBy('name') // Ordenados alfabéticamente
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MaterialModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
  }

  // 3. BORRAR MATERIAL (DELETE)
  Future<void> deleteMaterial(String materialId) async {
    await _db.collection(_materialsCollection).doc(materialId).delete();
  }
}