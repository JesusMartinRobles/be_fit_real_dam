import 'package:firebase_auth/firebase_auth.dart';

// CLASE AUTH SERVICE
// Es el intermediario entre la App y Firebase.
// Se encarga de enviar las credenciales y devolver si entraron o no.
class AuthService {
  // Instancia oficial de Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // MÉTODO: Iniciar Sesión
  // Devuelve un String? (null si todo va bien, o el mensaje de error si falla)
  Future<String?> login({required String email, required String password}) async {
    try {
      // Intentamos entrar...
      await _auth.signInWithEmailAndPassword(
        email: email.trim(), // trim() quita espacios accidentales al principio/final
        password: password.trim(),
      );
      return null; // Null significa "Éxito total"
    } on FirebaseAuthException catch (e) {
      // Si Firebase se queja, capturamos el motivo
      return e.message; // Devolvemos el error (ej: "Password incorrecta")
    } catch (e) {
      return "Ha ocurrido un error desconocido.";
    }
  }

  // MÉTODO: Registrar Nuevo Usuario
  // Recibe email y contraseña y crea la cuenta en Firebase.
  Future<String?> register({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Null significa "Todo perfecto, usuario creado"
    } on FirebaseAuthException catch (e) {
      return e.message; // Devolvemos el error (ej: "Email ya en uso")
    } catch (e) {
      return "Error desconocido al registrarse.";
    }
  }

  // MÉTODO: Cerrar Sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // MÉTODO: Obtener usuario actual
  User? get currentUser => _auth.currentUser;
}