import 'package:flutter_test/flutter_test.dart';

// Importaciones de los modelos del dominio
import 'package:be_fit_real/models/user_model.dart';
import 'package:be_fit_real/models/material_model.dart';
import 'package:be_fit_real/models/invite_code_model.dart';

/// BATERÍA DE PRUEBAS UNITARIAS: Módulo de Datos
///
/// Mecanismo de validación: Se utiliza el framework [flutter_test] para aislar
/// y garantizar el comportamiento determinista de los modelos de datos de la
/// aplicación. Estas pruebas aseguran que las operaciones de Serialización (a JSON)
/// y Deserialización (desde JSON) sean seguras y tolerantes a fallos, previniendo
/// regresiones en la capa de persistencia.
void main() {
  group('Pruebas Unitarias - Serialización y Programación Defensiva', () {
    // =========================================================================
    // SUITE 1: UserModel (Gestión de Identidad)
    // =========================================================================

    /// PRUEBA 1: Serialización de UserModel a formato NoSQL (Map)
    /// Objetivo: Verificar que los datos tipados en Dart se mapean correctamente
    /// a primitivas compatibles con Firestore.
    test('1. UserModel: Serialización correcta a Map (Dart -> Firebase)', () {
      final date = DateTime(2026, 1, 1);
      final user = UserModel(
          uid: '123', email: 'test@test.com', role: 'admin', createdAt: date);

      final map = user.toMap();

      expect(map['uid'], '123');
      expect(map['role'], 'admin');
    });

    /// PRUEBA 2: Deserialización estándar desde payload de red
    /// Objetivo: Validar la reconstrucción del objeto desde un JSON simulado.
    test('2. UserModel: Deserialización correcta desde Map (Firebase -> Dart)',
        () {
      final map = {
        'uid': '456',
        'email': 'user@test.com',
        'role': 'user',
        'createdAt': '2026-01-01T00:00:00.000'
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, '456');
      expect(user.email, 'user@test.com');
    });

    /// PRUEBA 3: Tolerancia a fallos (Control de Roles nulos)
    /// Objetivo: Comprobar el mecanismo Fail-Safe que asigna el privilegio
    /// mínimo ('user') si la base de datos devuelve un documento corrupto.
    test('3. UserModel: Asignación de rol "user" por defecto ante datos corruptos',
        () {
      final map = {
        'uid': '789',
        'email': 'nolead@test.com',
        'createdAt': '2026-01-01T00:00:00.000'
      };

      final user = UserModel.fromMap(map);

      expect(user.role, 'user');
    });

    /// PRUEBA 4: Estandarización de Fechas (ISO 8601)
    /// Objetivo: Asegurar que el timestamp no se envíe como un objeto nativo Dart.
    test('4. UserModel: Transformación de DateTime a estándar ISO 8601', () {
      final date = DateTime(2026, 5, 10);
      final user =
          UserModel(uid: '1', email: 'a@a.com', role: 'user', createdAt: date);

      expect(user.toMap()['createdAt'], date.toIso8601String());
    });

    // =========================================================================
    // SUITE 2: MaterialModel (Gestión de Inventario)
    // =========================================================================

    /// PRUEBA 5: Serialización estándar
    test('5. MaterialModel: Serialización correcta a formato Map', () {
      final material = MaterialModel(id: 'mat1', name: 'Mancuernas 10kg');
      expect(material.toMap(), {'id': 'mat1', 'name': 'Mancuernas 10kg'});
    });

    /// PRUEBA 6: Deserialización con ID inyectado
    /// Objetivo: Validar el patrón DTO donde el ID del documento NoSQL
    /// se inyecta en el objeto durante su construcción.
    test('6. MaterialModel: Deserialización con inyección de Document ID', () {
      final map = {'name': 'Barra Olímpica'};
      final material = MaterialModel.fromMap(map, 'mat2');

      expect(material.id, 'mat2');
      expect(material.name, 'Barra Olímpica');
    });

    /// PRUEBA 7: Tolerancia a nulos (Crash Prevention)
    test('7. MaterialModel: Fallback a "Material desconocido" ante map vacío',
        () {
      final map = <String, dynamic>{};
      final material = MaterialModel.fromMap(map, 'mat3');

      expect(material.name, 'Material desconocido');
    });

    // =========================================================================
    // SUITE 3: InviteCodeModel (Seguridad y Control de Acceso)
    // =========================================================================

    /// PRUEBA 8: Serialización de estados booleanos
    test('8. InviteCodeModel: Serialización de estados lógicos (isActive)', () {
      final date = DateTime.now();
      final code = InviteCodeModel(
          id: 'c1', code: 'PROYECTO10', isActive: true, createdAt: date);

      expect(code.toMap()['code'], 'PROYECTO10');
      expect(code.toMap()['isActive'], true);
    });

    /// PRUEBA 9: Validación de expiración
    test('9. InviteCodeModel: Detección correcta de códigos inactivos/caducados',
        () {
      final map = {
        'code': 'CADUCADO',
        'isActive': false,
        'createdAt': '2025-01-01T00:00:00.000'
      };
      final code = InviteCodeModel.fromMap(map, 'c2');

      expect(code.isActive, false);
    });

    /// PRUEBA 10: Prevención de inyección nula en credenciales
    test('10. InviteCodeModel: Asignación de "INVALID" ante ausencia de clave "code"',
        () {
      final map = {'isActive': true, 'createdAt': '2026-01-01T00:00:00.000'};
      final code = InviteCodeModel.fromMap(map, 'c3');

      expect(code.code, 'INVALID');
    });
  });
}
