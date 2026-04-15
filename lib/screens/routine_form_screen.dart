import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/custom_widgets.dart';
import '../services/database_service.dart';
import '../models/material_model.dart';
import '../services/ai_service.dart';
import 'routine_result_screen.dart';

/// PANTALLA: RoutineFormScreen (Formulario de Creación de Rutinas)
///
/// Motor principal de la aplicación. Recolecta los parámetros del usuario
/// (Inputs) para construir un 'Prompt' estructurado que será enviado a Gemini AI.
/// Elección de implementación: La carga de materiales disponibles se realiza
/// dinámicamente mediante un [StreamBuilder] conectado a Firestore, garantizando
/// que el formulario siempre ofrezca opciones actualizadas sin requerir
/// actualizaciones de la app en la tienda.
class RoutineFormScreen extends StatefulWidget {
  const RoutineFormScreen({super.key});

  @override
  State<RoutineFormScreen> createState() => _RoutineFormScreenState();
}

class _RoutineFormScreenState extends State<RoutineFormScreen> {
  // Instancias de servicios (Desacoplamiento de lógica de red)
  final DatabaseService _dbService = DatabaseService();
  final AIService _aiService = AIService();

  // Gestión de Estado: Parámetros del Prompt
  List<String> _selectedMaterials = [];
  String? _selectedGoal;
  String? _selectedFocus;

  final _timeController = TextEditingController();
  final _injuriesController = TextEditingController();

  // Listas estructurales estáticas (No requieren BBDD)
  final List<String> _goalsList = [
    "Fuerza e Hipertrofia",
    "Pérdida de Grasa",
    "Resistencia",
    "Rehabilitación"
  ];

  final List<String> _focusList = [
    "Full Body (Cuerpo Completo)",
    "Tren Superior (Torso)",
    "Tren Inferior (Pierna)",
    "Empuje (Push)",
    "Tracción (Pull)",
    "Core y Cardio",
    "Movilidad"
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
        title: const Text("CONFIGURAR SESIÓN",
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
                ColorFilter.mode(Colors.black.withAlpha(160), BlendMode.darken),
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

                    // --- INPUT: ENFOQUE ---
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

                    // --- INPUT: MATERIAL (Reactivo) ---
                    const BeFitLabel("MATERIAL DISPONIBLE"),
                    const SizedBox(height: 5),

                    StreamBuilder<List<MaterialModel>>(
                        stream: _dbService.getMaterials(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.redAccent.withAlpha(100))),
                              child: const Text(
                                "Error de conexión con la base de datos.",
                                style: TextStyle(
                                    color: Colors.redAccent, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Text(
                                  "El administrador no ha añadido materiales.",
                                  style: TextStyle(color: Colors.white54)),
                            );
                          }

                          final availableMaterialNames =
                              snapshot.data!.map((m) => m.name).toList();

                          return InkWell(
                            onTap: () =>
                                _showMultiSelectDialog(availableMaterialNames),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withAlpha(30)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.fitness_center,
                                      color: Colors.white70),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      _selectedMaterials.isEmpty
                                          ? "Selecciona equipamiento..."
                                          : _selectedMaterials.join(", "),
                                      style: TextStyle(
                                          fontFamily: 'Teko',
                                          color: _selectedMaterials.isEmpty
                                              ? Colors.white38
                                              : Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.white70),
                                ],
                              ),
                            ),
                          );
                        }),

                    const SizedBox(height: 20),

                    // --- INPUT: TIEMPO ---
                    const BeFitLabel("TIEMPO (MIN)"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _timeController,
                      hint: "Ej: 40",
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),

                    // --- INPUT: OBJETIVO ---
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

                    // --- INPUT: LESIONES ---
                    const BeFitLabel("MOLESTIAS / LESIONES"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _injuriesController,
                      hint: "Ej: Menisco, Muñeca derecha...",
                      icon: Icons.healing,
                    ),

                    const SizedBox(height: 40),

                    // --- ACCIÓN PRINCIPAL: GENERAR ---
                    ElevatedButton(
                      onPressed: () async {
                        // 1. Validación de campos obligatorios (Requisito de rúbrica)
                        if (_selectedFocus == null ||
                            _selectedGoal == null ||
                            _timeController.text.trim().isEmpty ||
                            _selectedMaterials.isEmpty) {
                          showBeFitSnackBar(context,
                              "Por favor, rellena todos los campos obligatorios.");
                          return;
                        }

                        showBeFitSnackBar(context,
                            "Diseñando tu entrenamiento... (puede tardar unos segundos)",
                            isError: false);

                        // 2. Transmisión del Prompt a la IA
                        final result = await _aiService.generateRoutine(
                          focus: _selectedFocus!,
                          time: _timeController.text.trim(),
                          materials: _selectedMaterials,
                          goal: _selectedGoal!,
                          injuries: _injuriesController.text.trim(),
                        );

                        // 3. Persistencia de Datos (Guarda el historial)
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          await _dbService.saveRoutine(
                              currentUser.uid, result, _selectedFocus!);
                        } else {
                          // Control de fallo crítico
                          if (mounted) {
                            showBeFitSnackBar(context,
                                "Error de sesión: No se pudo guardar el historial.");
                          }
                          return; // Evita navegar si no hay usuario válido
                        }

                        // 4. Navegación a Resultados
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoutineResultScreen(routineText: result),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: const Text("¡GENERAR RUTINA!",
                          style: TextStyle(
                              fontFamily: 'Teko',
                              fontSize: 32,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
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

  /// Método Auxiliar: Lanza el diálogo de selección múltiple
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

    // Solo actualiza el estado si el usuario confirmó la selección (no canceló)
    if (results != null) {
      setState(() => _selectedMaterials = results);
    }
  }
}

/// WIDGET PRIVADO: _MultiSelectDialog
///
/// Abstrae la lógica de selección múltiple.
/// Elección de implementación: Se crea como un [StatefulWidget] independiente
/// para gestionar una lista temporal (`_tempSelectedItems`). Esto permite al
/// usuario marcar y desmarcar opciones sin alterar el estado real del formulario
/// subyacente hasta que confirme su selección pulsando "Aceptar".
class _MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;
  final Color primaryColor;

  const _MultiSelectDialog(
      {required this.items,
      required this.initialSelectedItems,
      required this.primaryColor});

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    // Clonamos la lista inicial para manipularla de forma aislada
    _tempSelectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("SELECCIONA MATERIAL",
          style: TextStyle(
              fontFamily: 'Teko',
              color: widget.primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
          child: ListBody(
              children: widget.items.map((item) {
        final isChecked = _tempSelectedItems.contains(item);
        return CheckboxListTile(
            value: isChecked,
            title: Text(item,
                style: const TextStyle(
                    fontFamily: 'Teko', color: Colors.white, fontSize: 20)),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return widget.primaryColor;
              }
              return Colors.transparent;
            }),
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
            });
      }).toList())),
      actions: [
        TextButton(
            onPressed: () =>
                Navigator.pop(context), // Descarta los cambios temporales
            child: const Text("CANCELAR",
                style: TextStyle(
                    fontFamily: 'Teko', color: Colors.white54, fontSize: 20))),
        TextButton(
            onPressed: () => Navigator.pop(
                context, _tempSelectedItems), // Devuelve la lista final
            child: Text("ACEPTAR",
                style: TextStyle(
                    fontFamily: 'Teko',
                    color: widget.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
      ],
    );
  }
}
