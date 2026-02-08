// CLASE INVITE CODE MODEL
// Representa una "llave" de acceso a la aplicación.

class InviteCodeModel {
  final String id; // El ID del documento en Firebase
  final String code; // El código visible (ej: "AMIGO_VIP" o "A7X92")
  final bool isActive; // ¿Se puede usar?
  final DateTime createdAt; // Para saber cuándo lo creé

  InviteCodeModel({
    required this.id,
    required this.code,
    required this.isActive,
    required this.createdAt,
  });

  // PARA GUARDAR EN FIREBASE
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // PARA LEER DE FIREBASE
  factory InviteCodeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return InviteCodeModel(
      id: documentId,
      code: map['code'] ?? 'INVALID',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}