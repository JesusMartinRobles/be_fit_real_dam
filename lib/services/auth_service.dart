import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LOGIN
  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      // Si el error no es de Firebase (ej: error de programación), devolvemos esto
      return "Error desconocido: ${e.toString()}";
    }
  }

  // REGISTRO
  Future<String?> register({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email.trim(),
          role: 'user', 
          createdAt: DateTime.now(),
        );

        await _db.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      return "Error al crear usuario: ${e.toString()}";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
  
  User? get currentUser => _auth.currentUser;

  // ------------------------------------------------------------------
  // EL DICCIONARIO DE ERRORES (Actualizado 2025)
  // ------------------------------------------------------------------
  String _mapFirebaseError(String code) {
    switch (code) {
      // Errores de Login
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': // <--- ¡NUEVO! Google ahora usa este para todo
        return 'Credenciales incorrectas (Email o contraseña mal).';
      
      // Errores de Registro
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      
      // Errores Técnicos
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'channel-error': // <--- El error raro que te salía
        return 'Por favor, rellena todos los campos.'; 
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
        
      default:
        return 'Error del servidor: $code';
    }
  }
}