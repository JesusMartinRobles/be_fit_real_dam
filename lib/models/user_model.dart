/// CLASE DE MODELO: UserModel
///
/// Representa el perfil de un usuario registrado en la plataforma.
/// Elección de implementación: Arquitectura basada en DTO (Data Transfer Object).
/// Separa estrictamente la lógica de la vista del modelo de datos de Firebase,
/// facilitando la serialización/deserialización y centralizando la estructura
/// de la colección 'users'.
class UserModel {
  /// Identificador único (DNI) proporcionado por Firebase Authentication.
  final String uid;

  /// Correo electrónico vinculado a la cuenta.
  final String email;

  /// Rol de privilegios en la plataforma ('admin', 'user', 'banned').
  final String role;

  /// Marca temporal del momento exacto del registro.
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  /// Convierte la instancia actual en un formato JSON compatible con Firestore.
  ///
  /// Salidas esperadas: Un [Map] de claves [String] y valores dinámicos.
  /// Nota de implementación: Las fechas en Dart ([DateTime]) se transforman a
  /// String (formato ISO 8601) para garantizar compatibilidad universal e
  /// indexación óptima en bases de datos NoSQL.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Factoría para instanciar un [UserModel] desde un documento de Firestore.
  ///
  /// Entradas facilitadas: Un [Map] con datos crudos JSON obtenidos de la nube.
  /// Salidas esperadas: Una instancia de [UserModel] tipada de forma segura.
  ///
  /// Mecanismo de Seguridad (Programación Defensiva):
  /// Se utilizan operadores de coalescencia nula ('??') para asignar valores
  /// por defecto ('user' para roles no definidos, y la fecha actual para fechas nulas).
  /// Esto protege a la aplicación de bloqueos fatales (crashes) si la base de datos
  /// envía registros incompletos o corruptos.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      // Blindaje extra: Si falla la fecha, inyectamos la fecha actual en lugar de romper la app.
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
