// CLASE USER MODEL
// Esta clase es el "molde" de la ficha de mis usuarios.
// Sirve para convertir los datos de Dart a JSON (para Firebase) y viceversa.

class UserModel {
  final String uid; // El DNI único de Firebase Auth
  final String email;
  final String role; // 'admin', 'user', 'banned'
  final DateTime createdAt; // Fecha de registro

  // Constructor: Obligo a que estos datos existan al crear un usuario
  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // MÉTODO: TO MAP (De Dart a Firebase)
  // Convierte mi objeto bonito en un diccionario (Map) que Firebase entiende.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(), // Las fechas se guardan como texto
    };
  }

  // MÉTODO: FROM MAP (De Firebase a Dart)
  // Coge el diccionario feo que me da Firebase y lo convierte en mi objeto bonito.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user', // Si no tiene rol, por defecto es 'user'
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}