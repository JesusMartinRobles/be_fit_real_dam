// CLASE MATERIAL MODEL
// Este es el objeto que representa una herramienta de entrenamiento.
// Ej: "Mancuernas", "Barra Olímpica", "Bandas Elásticas".

class MaterialModel {
  final String id; // Identificador único en Firebase
  final String name; // El nombre que verá el usuario (ej: "Mancuernas")
  
  // Constructor
  MaterialModel({
    required this.id,
    required this.name,
  });

  // DE DART A FIREBASE (Para guardar)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // DE FIREBASE A DART (Para leer)
  factory MaterialModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MaterialModel(
      id: documentId,
      name: map['name'] ?? 'Material desconocido',
    );
  }
}