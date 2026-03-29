import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- IMPORTACIONES DE ARQUITECTURA ---
import '../widgets/custom_widgets.dart'; 
import '../services/database_service.dart'; 
import '../models/material_model.dart'; 

// 🟢 NUEVAS IMPORTACIONES: El cerebro de la IA y la pantalla de resultados
import '../services/ai_service.dart';
import 'routine_result_screen.dart';

class RoutineFormScreen extends StatefulWidget {
  const RoutineFormScreen({super.key});

  @override
  State<RoutineFormScreen> createState() => _RoutineFormScreenState();
}

class _RoutineFormScreenState extends State<RoutineFormScreen> {
  // 1. SERVICIOS
  // Instanciamos el servicio de base de datos para no mezclar lógica de red con UI.
  final DatabaseService _dbService = DatabaseService();
  
  // 🟢 Instanciamos nuestro servicio de IA
  final AIService _aiService = AIService();

  // 2. GESTIÓN DEL ESTADO (STATE)
  // Utilizamos una Lista para los materiales porque es una relación N:M (El usuario puede tener varios)
  List<String> _selectedMaterials = [];
  
  // Variables simples (String) para selecciones únicas
  String? _selectedGoal;
  String? _selectedFocus;

  // Controladores para capturar el texto libre introducido por el usuario
  final _timeController = TextEditingController();
  final _injuriesController = TextEditingController();

  // 3. DATOS ESTÁTICOS
  // Opciones predefinidas que no requieren base de datos por ser estructurales de la app
  final List<String> _goalsList = [
    "Fuerza e Hipertrofia", "Pérdida de Grasa", "Resistencia", "Rehabilitación"
  ];

  final List<String> _focusList = [
    "Full Body (Cuerpo Completo)", "Tren Superior (Torso)", "Tren Inferior (Pierna)",
    "Empuje (Push)", "Tracción (Pull)", "Core y Cardio", "Movilidad"
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(), 
        ),
        title: Text("CONFIGURAR SESIÓN", 
          style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      body: Container(
        // FONDO: Implementación del patrón Glassmorphism
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withAlpha(160), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // --- CAMPO 1: ENFOQUE ---
                    const BeFitLabel("ENFOQUE DEL DÍA"),
                    const SizedBox(height: 5),
                    GlassDropdown(
                      hint: "Ej: Empuje, Pierna...",
                      value: _selectedFocus,
                      items: _focusList,
                      icon: Icons.accessibility_new,
                      onChanged: (val) => setState(() => _selectedFocus = val),
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 2: MATERIAL (CONEXIÓN A BACKEND) ---
                    // ARGUMENTO DE DEFENSA: 
                    // "Aquí usamos un StreamBuilder. Esto abre un canal de datos asíncrono 
                    // con Firestore. Si el Admin añade un material nuevo en la base de datos, 
                    // esta lista se actualiza en el dispositivo del usuario en tiempo real."
                    const BeFitLabel("MATERIAL DISPONIBLE"),
                    const SizedBox(height: 5),
                    
                    StreamBuilder<List<MaterialModel>>(
                      stream: _dbService.getMaterials(),
                      builder: (context, snapshot) {
                        
                        // Control de Errores (Ej: Reglas de seguridad de Firebase fallan)
                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(30), 
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.redAccent.withAlpha(100))
                            ),
                            child: const Text(
                              "Error de conexión con la base de datos.", 
                              style: TextStyle(color: Colors.redAccent, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        // Estado de carga inicial
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }

                        // Validación: Base de datos vacía
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                            child: const Text("El administrador no ha añadido materiales.", style: TextStyle(color: Colors.white54)),
                          );
                        }

                        // Mapeo: Extraemos solo los nombres (Strings) del modelo para pasarlos a la UI
                        final availableMaterialNames = snapshot.data!.map((m) => m.name).toList();

                        // Renderizado del botón dinámico
                        return InkWell(
                          onTap: () => _showMultiSelectDialog(availableMaterialNames),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withAlpha(30)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.fitness_center, color: Colors.white70),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    _selectedMaterials.isEmpty 
                                      ? "Selecciona equipamiento..."
                                      : _selectedMaterials.join(", "),
                                    style: GoogleFonts.teko(
                                      color: _selectedMaterials.isEmpty ? Colors.white38 : Colors.white,
                                      fontSize: 20, fontWeight: FontWeight.w400
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.white70),
                              ],
                            ),
                          ),
                        );
                      }
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 3: TIEMPO ---
                    const BeFitLabel("TIEMPO (MIN)"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _timeController,
                      hint: "Ej: 40", // Valor recomendado por defecto
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 4: OBJETIVO ---
                    const BeFitLabel("OBJETIVO"),
                    const SizedBox(height: 5),
                    GlassDropdown(
                      hint: "Ej: Fuerza",
                      value: _selectedGoal,
                      items: _goalsList,
                      icon: Icons.flag,
                      onChanged: (val) => setState(() => _selectedGoal = val),
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 5: MOLESTIAS ---
                    const BeFitLabel("MOLESTIAS / LESIONES"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _injuriesController,
                      hint: "Ej: Menisco, Muñeca derecha...", // Ejemplos muy personalizados
                      icon: Icons.healing,
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN GENERAR
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedFocus == null || _selectedGoal == null || _timeController.text.isEmpty || _selectedMaterials.isEmpty) {
                          showBeFitSnackBar(context, "Por favor, rellena todos los campos obligatorios.");
                          return;
                        }

                        showBeFitSnackBar(context, "Diseñando tu entrenamiento... (puede tardar unos segundos)", isError: false);
                        
                        // 1. Llamamos a Gemini
                        final result = await _aiService.generateRoutine(
                          focus: _selectedFocus!,
                          time: _timeController.text,
                          materials: _selectedMaterials,
                          goal: _selectedGoal!,
                          injuries: _injuriesController.text,
                        );

                        // 2. GUARDAR EN FIREBASE (PERSISTENCIA)
                        // Buscamos quién es el usuario actual
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          // ¡AQUÍ ESTÁ LA MAGIA QUE GUARDA EN LA BASE DE DATOS!
                          await _dbService.saveRoutine(currentUser.uid, result, _selectedFocus!);
                        } else {
                          print("Error crítico: No hay usuario logueado.");
                        }

                        // 3. Navegamos a la pantalla de resultados
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RoutineResultScreen(routineText: result),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: Text("¡GENERAR RUTINA!", 
                        style: GoogleFonts.teko(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MÉTODO CONTROLADOR DEL DIÁLOGO
  // Abre el widget separado y espera el resultado asíncrono (await)
  void _showMultiSelectDialog(List<String> materials) async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _MultiSelectDialog(
          items: materials, 
          initialSelectedItems: _selectedMaterials,
          primaryColor: Theme.of(context).primaryColor,
        );
      },
    );
    // Actualizamos el estado de la pantalla principal si el usuario aceptó
    if (results != null) setState(() => _selectedMaterials = results);
  }
}

// ==============================================================================
// WIDGET PRIVADO: DIÁLOGO MULTI-SELECCIÓN
// ARGUMENTO DE DEFENSA: "He extraído el diálogo a un StatefulWidget privado. 
// Es necesario porque los Checkboxes necesitan mantener su propio estado (marcado/desmarcado) 
// internamente antes de devolver el resultado final a la pantalla principal."
// ==============================================================================
class _MultiSelectDialog extends StatefulWidget {
  final List<String> items; 
  final List<String> initialSelectedItems; 
  final Color primaryColor;
  
  const _MultiSelectDialog({required this.items, required this.initialSelectedItems, required this.primaryColor});
  
  @override 
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  // Lista temporal para no modificar la real hasta que el usuario pulse "Aceptar"
  late List<String> _tempSelectedItems;
  
  @override 
  void initState() { 
    super.initState(); 
    _tempSelectedItems = List.from(widget.initialSelectedItems); 
  }
  
  @override 
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("SELECCIONA MATERIAL", style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            final isChecked = _tempSelectedItems.contains(item);
            return CheckboxListTile(
              value: isChecked, 
              title: Text(item, style: GoogleFonts.teko(color: Colors.white, fontSize: 20)), 
              activeColor: widget.primaryColor, 
              checkColor: Colors.black, 
              controlAffinity: ListTileControlAffinity.leading, 
              onChanged: (bool? checked) { 
                setState(() { 
                  if (checked == true) { 
                    _tempSelectedItems.add(item); 
                  } else { 
                    _tempSelectedItems.remove(item); 
                  } 
                }); 
              }
            ); 
          }).toList()
        )
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text("CANCELAR", style: GoogleFonts.teko(color: Colors.white54, fontSize: 20))
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelectedItems), 
          child: Text("ACEPTAR", style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 20, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }
}