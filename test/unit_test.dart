import 'package:flutter_test/flutter_test.dart';

// Importamos los modelos de nuestra aplicación
import 'package:be_fit_real/models/user_model.dart';
import 'package:be_fit_real/models/material_model.dart';
import 'package:be_fit_real/models/invite_code_model.dart';

/// BATERÍA DE PRUEBAS UNITARIAS
/// Mecanismo: Se utiliza el framework 'flutter_test' para aislar y validar 
/// el comportamiento de los modelos de datos (Serialización/Deserialización).
void main() {
  group('Pruebas Unitarias - Módulo de Datos (Modelos)', () {
    
    // =========================================================================
    // TESTS DE USER MODEL (Pruebas 1 a 4)
    // =========================================================================

    /// PRUEBA 1: Serialización de UserModel a Map
    /// Entradas: Un objeto [UserModel] instanciado con datos simulados.
    /// Salidas esperadas: Un [Map] válido para Firebase con el uid '123'.
    test('1. UserModel convierte correctamente a Map (Dart a Firebase)', () {
      final date = DateTime(2026, 1, 1);
      final user = UserModel(uid: '123', email: 'test@test.com', role: 'admin', createdAt: date);
      
      final map = user.toMap();
      
      expect(map['uid'], '123');
      expect(map['role'], 'admin');
    });

    /// PRUEBA 2: Deserialización de Map a UserModel
    /// Entradas: Un [Map] simulando un JSON recibido desde Firestore.
    /// Salidas esperadas: Un objeto [UserModel] con el email 'user@test.com'.
    test('2. UserModel se crea correctamente desde Map (Firebase a Dart)', () {
      final map = {'uid': '456', 'email': 'user@test.com', 'role': 'user', 'createdAt': '2026-01-01T00:00:00.000'};
      
      final user = UserModel.fromMap(map);
      
      expect(user.uid, '456');
      expect(user.email, 'user@test.com');
    });

    /// PRUEBA 3: Asignación de Rol por Defecto (Seguridad)
    /// Entradas: Un [Map] incompleto sin el campo 'role' (Simula error en BD).
    /// Salidas esperadas: El modelo debe autoprotegerse y asignar el rol 'user'.
    test('3. UserModel asigna rol "user" por defecto si falta en la BBDD', () {
      final map = {'uid': '789', 'email': 'nolead@test.com', 'createdAt': '2026-01-01T00:00:00.000'};
      
      final user = UserModel.fromMap(map);
      
      expect(user.role, 'user');
    });

    /// PRUEBA 4: Formateo de Fecha ISO 8601
    /// Entradas: Un [DateTime] nativo de Dart.
    /// Salidas esperadas: Un String en formato ISO 8601 compatible con Firebase.
    test('4. UserModel guarda la fecha en formato String compatible', () {
      final date = DateTime(2026, 5, 10);
      final user = UserModel(uid: '1', email: 'a@a.com', role: 'user', createdAt: date);
      
      expect(user.toMap()['createdAt'], date.toIso8601String());
    });

    // =========================================================================
    // TESTS DE MATERIAL MODEL (Pruebas 5 a 7)
    // =========================================================================

    /// PRUEBA 5: Serialización de MaterialModel
    /// Entradas: Objeto [MaterialModel] "Mancuernas 10kg".
    /// Salidas esperadas: Map con claves 'id' y 'name' correctas.
    test('5. MaterialModel convierte a Map correctamente', () {
      final material = MaterialModel(id: 'mat1', name: 'Mancuernas 10kg');
      expect(material.toMap(), {'id': 'mat1', 'name': 'Mancuernas 10kg'});
    });

    /// PRUEBA 6: Deserialización de MaterialModel
    /// Entradas: Map JSON con nombre y un ID de documento inyectado externamente.
    /// Salidas esperadas: Objeto [MaterialModel] bien construido.
    test('6. MaterialModel se construye desde Map', () {
      final map = {'name': 'Barra Olímpica'};
      final material = MaterialModel.fromMap(map, 'mat2');
      
      expect(material.id, 'mat2');
      expect(material.name, 'Barra Olímpica');
    });

    /// PRUEBA 7: Tolerancia a fallos en MaterialModel
    /// Entradas: Un Map vacío (Corrupción de datos).
    /// Salidas esperadas: El modelo sobrevive asignando 'Material desconocido'.
    test('7. MaterialModel asigna nombre por defecto ante datos corruptos', () {
      final map = <String, dynamic>{}; 
      final material = MaterialModel.fromMap(map, 'mat3');
      
      expect(material.name, 'Material desconocido');
    });

    // =========================================================================
    // TESTS DE INVITE CODE MODEL (Pruebas 8 a 10)
    // =========================================================================

    /// PRUEBA 8: Serialización de Códigos
    /// Entradas: Objeto [InviteCodeModel] activo.
    /// Salidas esperadas: JSON validado con el booleano 'isActive' en true.
    test('8. InviteCodeModel convierte a Map correctamente', () {
      final date = DateTime.now();
      final code = InviteCodeModel(id: 'c1', code: 'PROYECTO10', isActive: true, createdAt: date);
      
      expect(code.toMap()['code'], 'PROYECTO10');
      expect(code.toMap()['isActive'], true);
    });

    /// PRUEBA 9: Validación de Estados Lógicos
    /// Entradas: JSON de un código caducado.
    /// Salidas esperadas: La propiedad 'isActive' del objeto es false.
    test('9. InviteCodeModel detecta si un código está inactivo', () {
      final map = {'code': 'CADUCADO', 'isActive': false, 'createdAt': '2025-01-01T00:00:00.000'};
      final code = InviteCodeModel.fromMap(map, 'c2');
      
      expect(code.isActive, false);
    });

    /// PRUEBA 10: Prevención de inyección nula
    /// Entradas: JSON donde falta el campo fundamental 'code'.
    /// Salidas esperadas: El modelo asigna la cadena 'INVALID' para evitar crasheos.
    test('10. InviteCodeModel marca "INVALID" si falta el código en el JSON', () {
      final map = {'isActive': true, 'createdAt': '2026-01-01T00:00:00.000'};
      final code = InviteCodeModel.fromMap(map, 'c3');
      
      expect(code.code, 'INVALID');
    });
  });
}