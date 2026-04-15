/// CLASE DE MODELO: InviteCodeModel
///
/// Representa una "llave" o código de acceso exclusivo a la aplicación.
/// Elección de implementación: Se utiliza el patrón de diseño "Data Transfer
/// Object" (DTO) para desacoplar la estructura de datos interna de la app
/// de la implementación específica de la base de datos (Cloud Firestore).
class InviteCodeModel {
  /// Identificador único del documento en Firebase.
  final String id;

  /// El código alfanumérico visible para el usuario (ej: "DAM_PROYECTO").
  final String code;

  /// Bandera booleana que determina si el código ha sido invalidado o sigue vigente.
  final bool isActive;

  /// Fecha de generación para control de caducidad y auditoría.
  final DateTime createdAt;

  InviteCodeModel({
    required this.id,
    required this.code,
    required this.isActive,
    required this.createdAt,
  });

  /// Serializa el objeto a un formato JSON compatible con bases de datos NoSQL.
  ///
  /// Salida: Un [Map] de pares clave-valor (String: dynamic).
  /// Nota de arquitectura: El campo [id] no se incluye en el mapa porque
  /// Firestore lo gestiona como el nombre del propio documento en la colección.
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Factoría para deserializar un documento JSON proveniente de la base de datos.
  ///
  /// Entradas:
  /// - [map]: El diccionario de datos crudos obtenido de Firestore.
  /// - [documentId]: El ID del documento inyectado desde la consulta de red.
  ///
  /// Salida: Una instancia tipada y validada de [InviteCodeModel].
  /// Seguridad (Defensive Programming): Se asignan valores por defecto
  /// ('INVALID', true, fecha actual) mediante el operador coalescente nulo '??'
  /// para garantizar que la app no crashee si la base de datos devuelve campos corruptos.
  factory InviteCodeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return InviteCodeModel(
      id: documentId,
      code: map['code'] ?? 'INVALID',
      isActive: map['isActive'] ?? true,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
