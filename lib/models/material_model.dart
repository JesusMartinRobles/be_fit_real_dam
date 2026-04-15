/// CLASE DE MODELO: MaterialModel
///
/// Representa una herramienta o equipamiento de entrenamiento disponible en el club.
/// Elección de implementación: Se aplica el patrón DTO. La estructura se mantiene
/// intencionadamente minimalista (solo ID y nombre) para aligerar la carga de red
/// y optimizar el rendimiento, dado que estos documentos se descargarán mediante un
/// StreamBuilder cada vez que el usuario entre al formulario de rutinas.
class MaterialModel {
  /// Identificador único del material (se corresponde con el ID del documento en Firebase).
  final String id;

  /// Nombre descriptivo del equipamiento (ej: "Mancuernas", "Barra Olímpica").
  final String name;

  MaterialModel({
    required this.id,
    required this.name,
  });

  /// Serializa el objeto a un formato JSON para su persistencia en la base de datos.
  ///
  /// Salida: Un [Map] de pares clave-valor.
  /// Nota de arquitectura: Guardar el [id] explícitamente en el cuerpo del documento
  /// agiliza las operaciones CRUD posteriores (como el borrado desde el panel de admin).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Factoría para instanciar un [MaterialModel] a partir de un documento NoSQL.
  ///
  /// Entradas:
  /// - [map]: Diccionario de datos crudos obtenido de la red (Firestore).
  /// - [documentId]: El ID real del documento en la colección.
  ///
  /// Salida: Una instancia validada de [MaterialModel].
  /// Seguridad (Defensive Programming): Si el documento se ha corrompido en la
  /// nube y carece de la clave 'name', se inyecta la cadena 'Material desconocido'
  /// mediante el operador '??' para evitar una excepción de nulos y la caída de la UI.
  factory MaterialModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MaterialModel(
      id: documentId,
      name: map['name'] ?? 'Material desconocido',
    );
  }
}
