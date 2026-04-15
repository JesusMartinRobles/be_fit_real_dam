import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// SERVICIO: AuthService (Autenticación y Seguridad de Acceso)
///
/// Actúa como capa de abstracción entre la interfaz de usuario y [FirebaseAuth].
/// Elección de implementación: Centraliza toda la lógica de validación de
/// identidad y captura de excepciones. Incluye una arquitectura de traducción
/// de errores (`_mapFirebaseError`) para convertir códigos técnicos de servidor
/// en mensajes comprensibles para el usuario final, mejorando la UX.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Método Asíncrono: Inicio de Sesión (Login)
  ///
  /// Autentica a un usuario existente. Retorna `null` si es exitoso,
  /// o un [String] con el mensaje de error traducido si falla.
  Future<String?> login(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      return "Error desconocido: ${e.toString()}";
    }
  }

  /// Método Asíncrono: Registro (Sign Up) con Control de Acceso
  ///
  /// Crea una nueva cuenta verificando previamente un código de invitación.
  /// Mecanismo de Seguridad: La consulta a Firestore (`invite_codes`) se
  /// realiza *antes* de invocar a Firebase Auth. Esto evita la creación
  /// de "usuarios fantasma" si el código resulta ser inválido.
  Future<String?> register(
      {required String email,
      required String password,
      required String inviteCode}) async {
    try {
      // 1. Verificación del Código de Invitación (Control de Acceso)
      final codeSnapshot = await _db
          .collection('invite_codes')
          .where('code', isEqualTo: inviteCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      // Validación: Si no hay coincidencias, se bloquea el registro
      if (codeSnapshot.docs.isEmpty) {
        return "El código de invitación no es válido o ha caducado.";
      }

      // 2. Creación de Credenciales en FirebaseAuth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = result.user;

      if (user != null) {
        // 3. Generación del perfil estructurado (UserModel) en Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email.trim(),
          role: 'user', // Rol base por defecto por motivos de seguridad
          createdAt: DateTime.now(),
        );

        await _db.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return null; // Operación completada con éxito
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      return "Error al procesar el registro: $e";
    }
  }

  /// Método Asíncrono: Cierre de Sesión (Logout)
  ///
  /// Invalida el token JWT actual y limpia el estado de autenticación local.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Getter: Retorna la instancia del usuario actualmente autenticado (o null).
  User? get currentUser => _auth.currentUser;

  /// Método Privado: Diccionario de Traducción de Errores
  ///
  /// Mapea los códigos de error estandarizados de Firebase a cadenas de texto
  /// amigables para el usuario en español.
  String _mapFirebaseError(String code) {
    switch (code) {
      // Errores de Autenticación General
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': // Código unificado en recientes versiones de Firebase
        return 'Credenciales incorrectas (Email o contraseña erróneos).';

      // Errores de Creación de Cuenta
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';

      // Errores de Infraestructura y Red
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'channel-error':
        return 'Por favor, rellena todos los campos obligatorios.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera unos minutos por seguridad.';

      default:
        return 'Error del servidor: $code';
    }
  }
}
