import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_widgets.dart'; // Importamos tus textfields de cristal

// ==============================================================================
// PANTALLA DE PERFIL (CRUD DE USUARIO)
// ARGUMENTO DE DEFENSA: "Para completar la gestión de usuarios y cumplir con las 
// operaciones CRUD de la base de datos, he implementado esta pantalla de Perfil. 
// Al inicializarse (initState), realiza una operación de Lectura (Read) del documento 
// del usuario en Firestore. Al pulsar guardar, realiza una operación de Actualización 
// (Update), permitiendo al usuario personalizar sus datos físicos y preferencias, 
// como incluir tiempo de meditación o proteger lesiones específicas por defecto."
// ==============================================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para los campos de texto
  final _ageController = TextEditingController();
  final _timeController = TextEditingController();
  final _injuriesController = TextEditingController();
  
  // Variable para el switch de meditación
  bool _includeMeditation = true;
  
  // Estado de carga para mostrar un "ruedita" mientras lee de Firebase
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargamos los datos nada más abrir la pantalla
  }

  // 1. LECTURA DE DATOS (READ)
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            // Si el dato existe lo ponemos, si no, lo dejamos vacío (o con valores por defecto)
            _ageController.text = data['age']?.toString() ?? ''; // Tu edad
            _timeController.text = data['defaultTime']?.toString() ?? ''; // Tus 40 min
            _injuriesController.text = data['injuries']?.toString() ?? '';
            _includeMeditation = data['meditation'] ?? true; // Tus 5 min de meditación
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error leyendo perfil: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. ACTUALIZACIÓN DE DATOS (UPDATE)
  Future<void> _saveUserData() async {
    // Cerramos el teclado por estética
    FocusScope.of(context).unfocus();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        showBeFitSnackBar(context, "Guardando perfil...", isError: false);
        
        // Actualizamos (Update) o creamos (Set con merge) los campos en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'age': _ageController.text,
          'defaultTime': _timeController.text,
          'injuries': _injuriesController.text,
          'meditation': _includeMeditation,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true)); // merge: true actualiza sin borrar el campo 'role'

        if (mounted) {
          showBeFitSnackBar(context, "¡Perfil actualizado correctamente!", isError: false);
          // Opcional: Podríamos hacer Navigator.pop(context) para volver al menú
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
        title: Text("MI PERFIL", style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withAlpha(180), BlendMode.darken),
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
                      
                      // Avatar estético
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryColor.withAlpha(50),
                          child: Icon(Icons.person, size: 60, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          FirebaseAuth.instance.currentUser?.email ?? "Atleta",
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // --- CAMPO: EDAD ---
                      const BeFitLabel("EDAD"),
                      const SizedBox(height: 5),
                      GlassTextField(
                        controller: _ageController,
                        hint: "Ej: 42",
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      // --- CAMPO: TIEMPO POR DEFECTO ---
                      const BeFitLabel("TIEMPO PREFERIDO (MIN)"),
                      const SizedBox(height: 5),
                      GlassTextField(
                        controller: _timeController,
                        hint: "Ej: 40",
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      // --- CAMPO: MOLESTIAS ---
                      const BeFitLabel("LESIONES CRÓNICAS A PROTEGER"),
                      const SizedBox(height: 5),
                      GlassTextField(
                        controller: _injuriesController,
                        hint: "Ej: Menisco y muñeca derecha",
                        icon: Icons.healing,
                      ),
                      const SizedBox(height: 20),

                      // --- CAMPO: MEDITACIÓN (Switch) ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(30)),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            "5 MIN. DE MEDITACIÓN AL FINAL", 
                            style: GoogleFonts.teko(color: Colors.white, fontSize: 22)
                          ),
                          subtitle: const Text(
                            "Añade un bloque de relajación a tus rutinas.",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          value: _includeMeditation,
                          activeColor: primaryColor,
                          onChanged: (bool value) {
                            setState(() {
                              _includeMeditation = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- BOTÓN GUARDAR ---
                      ElevatedButton(
                        onPressed: _saveUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save, color: Colors.black),
                            const SizedBox(width: 10),
                            Text("GUARDAR PERFIL", 
                              style: GoogleFonts.teko(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
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