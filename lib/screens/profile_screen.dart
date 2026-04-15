import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_widgets.dart';

/// PANTALLA: ProfileScreen (Gestión de Perfil y Preferencias)
///
/// Interfaz que permite al usuario visualizar y modificar su configuración personal.
/// Elección de implementación: Satisface las operaciones Read y Update (CRUD).
/// Se utiliza [SetOptions(merge: true)] en la escritura para asegurar que solo se
/// modifiquen los campos expuestos en este formulario, preservando datos críticos
/// del usuario (como 'uid', 'role' o 'createdAt') completamente intactos en Firestore.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores de estado para los campos de entrada
  final _ageController = TextEditingController();
  final _timeController = TextEditingController();
  final _injuriesController = TextEditingController();

  // Variable de estado para preferencias booleanas
  bool _includeMeditation = true;

  // Bandera de carga para la lectura inicial asíncrona
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Método Privado: Lectura de Datos (READ)
  ///
  /// Se ejecuta durante el ciclo de vida inicial de la vista para poblar
  /// los controladores de texto con la información persistente del usuario.
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              // Operadores de coalescencia nula previenen crasheos si faltan campos
              _ageController.text = data['age']?.toString() ?? '';
              _timeController.text = data['defaultTime']?.toString() ?? '';
              _injuriesController.text = data['injuries']?.toString() ?? '';
              _includeMeditation = data['meditation'] ?? true;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        debugPrint("Error leyendo perfil: $e");
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Método Privado: Actualización de Datos (UPDATE)
  ///
  /// Recopila la información sanitizada de los controladores y la envía a la nube.
  Future<void> _saveUserData() async {
    // Retiro del foco para ocultar el teclado virtual mejorando la UX
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        showBeFitSnackBar(context, "Guardando perfil...", isError: false);

        // Ejecución de la escritura en BBDD con sanitización (.trim())
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'age': _ageController.text.trim(),
          'defaultTime': _timeController.text.trim(),
          'injuries': _injuriesController.text.trim(),
          'meditation': _includeMeditation,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        if (mounted) {
          showBeFitSnackBar(context, "¡Perfil actualizado correctamente!",
              isError: false);
        }
      } catch (e) {
        if (mounted) {
          showBeFitSnackBar(context, "Error al guardar el perfil.");
        }
      }
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _timeController.dispose();
    _injuriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("MI PERFIL",
            style: TextStyle(
                fontFamily: 'Teko', color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(Colors.black.withAlpha(180), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // --- CABECERA ESTÉTICA ---
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: primaryColor.withAlpha(50),
                            child: Icon(Icons.person,
                                size: 60, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            FirebaseAuth.instance.currentUser?.email ??
                                "Atleta",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- FORMULARIO DE DATOS ---

                        const BeFitLabel("EDAD"),
                        const SizedBox(height: 5),
                        GlassTextField(
                          controller: _ageController,
                          hint: "Ej: 42",
                          icon: Icons.cake,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),

                        const BeFitLabel("TIEMPO PREFERIDO (MIN)"),
                        const SizedBox(height: 5),
                        GlassTextField(
                          controller: _timeController,
                          hint: "Ej: 40",
                          icon: Icons.timer,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),

                        const BeFitLabel("LESIONES CRÓNICAS A PROTEGER"),
                        const SizedBox(height: 5),
                        GlassTextField(
                          controller: _injuriesController,
                          hint: "Ej: Menisco y muñeca derecha",
                          icon: Icons.healing,
                        ),
                        const SizedBox(height: 20),

                        // --- PREFERENCIAS DE ENTRENAMIENTO ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.white.withAlpha(30)),
                          ),
                          child: SwitchListTile(
                            title: const Text("5 MIN. DE MEDITACIÓN AL FINAL",
                                style: TextStyle(
                                    fontFamily: 'Teko',
                                    color: Colors.white,
                                    fontSize: 22)),
                            subtitle: const Text(
                              "Añade un bloque de relajación a tus rutinas.",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            value: _includeMeditation,
                            activeTrackColor: primaryColor,
                            activeThumbColor: Colors.black,
                            onChanged: (bool value) {
                              setState(() {
                                _includeMeditation = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- ACCIÓN DE GUARDADO ---
                        ElevatedButton(
                          onPressed: _saveUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, color: Colors.black),
                              SizedBox(width: 10),
                              Text("GUARDAR PERFIL",
                                  style: TextStyle(
                                      fontFamily: 'Teko',
                                      fontSize: 28,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
