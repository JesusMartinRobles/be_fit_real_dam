import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- IMPORTACIÓN NUEVA
import '../models/user_model.dart'; // Importo mi molde de usuario

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instancia de la Base de Datos
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LOGIN (Igual que antes)
  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error desconocido en login.";
    }
  }

  // REGISTRO (¡MEJORADO!)
  // Ahora, además de crear la cuenta, guarda la ficha en la base de datos.
  Future<String?> register({required String email, required String password}) async {
    try {
      // 1. Crear el usuario en el sistema de autenticación (Google)
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Si llegamos aquí, el usuario se creó bien. Ahora guardamos sus datos.
      User? user = result.user;

      if (user != null) {
        // 2. Crear mi objeto "Ficha de Usuario"
        // Por defecto, todos nacen con el rol 'user'.
        // Tú luego cambiarás el tuyo a 'admin' manualmente en la consola.
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email.trim(),
          role: 'user', 
          createdAt: DateTime.now(),
        );

        // 3. Guardar la ficha en la colección 'users' de Firestore
        // Uso .set() para crear el documento con el mismo ID que el usuario.
        await _db.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return null; // Todo perfecto
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error al guardar datos en Firestore: $e";
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
  
  // OBTENER USUARIO ACTUAL
  User? get currentUser => _auth.currentUser;
}