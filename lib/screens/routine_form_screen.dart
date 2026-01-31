import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart'; // Importo mis piezas de Lego

class RoutineFormScreen extends StatefulWidget {
  const RoutineFormScreen({super.key});

  @override
  State<RoutineFormScreen> createState() => _RoutineFormScreenState();
}

class _RoutineFormScreenState extends State<RoutineFormScreen> {
  // 1. MEMORIA (ESTADO)
  
  // Para los materiales, uso una LISTA porque el usuario puede elegir varios.
  List<String> _selectedMaterials = [];
  
  // Para las opciones únicas (Objetivo, Enfoque), uso un String simple.
  String? _selectedGoal;
  String? _selectedFocus;

  // Para los campos donde el usuario escribe libremente, uso Controladores.
  final _timeController = TextEditingController();
  final _injuriesController = TextEditingController();

  // 2. DATOS DE LOS MENÚS
  // Defino aquí las opciones que salen en los desplegables.
  
  final List<String> _materialsList = [
    "Gimnasio Completo", "Mancuernas", "Barra y Discos",
    "Barra de Dominadas", "Bandas Elásticas", "Peso Corporal", "Kettlebells"
  ];

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
          onPressed: () => Navigator.of(context).pop(), // Volver al menú
        ),
        title: Text("CONFIGURAR SESIÓN", 
          style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      body: Container(
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

                    // --- CAMPO 2: MATERIAL (ESPECIAL) ---
                    // Este no usa GlassDropdown porque necesita lógica Multi-Select (InkWell + Diálogo).
                    const BeFitLabel("MATERIAL DISPONIBLE"),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: _showMultiSelectDialog,
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
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 3: TIEMPO ---
                    const BeFitLabel("TIEMPO (MIN)"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _timeController,
                      hint: "Ej: 40",
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
                      hint: "Ej: Menisco, Muñeca...",
                      icon: Icons.healing,
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN GENERAR
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Aquí llamaremos a Gemini AI
                        debugPrint("Enfoque: $_selectedFocus");
                        debugPrint("Material: $_selectedMaterials");
                        debugPrint("Tiempo: ${_timeController.text}");
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

  // DIÁLOGO MULTI-SELECCIÓN (Lógica específica de esta pantalla)
  void _showMultiSelectDialog() async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _MultiSelectDialog(
          items: _materialsList,
          initialSelectedItems: _selectedMaterials,
          primaryColor: Theme.of(context).primaryColor,
        );
      },
    );
    if (results != null) setState(() => _selectedMaterials = results);
  }
}

// Widget privado para el diálogo de selección múltiple (Checkboxes)
class _MultiSelectDialog extends StatefulWidget {
  final List<String> items; final List<String> initialSelectedItems; final Color primaryColor;
  const _MultiSelectDialog({required this.items, required this.initialSelectedItems, required this.primaryColor});
  @override State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _tempSelectedItems;
  @override void initState() { super.initState(); _tempSelectedItems = List.from(widget.initialSelectedItems); }
  @override Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("SELECCIONA MATERIAL", style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: ListBody(children: widget.items.map((item) {
            final isChecked = _tempSelectedItems.contains(item);
            return CheckboxListTile(value: isChecked, title: Text(item, style: GoogleFonts.teko(color: Colors.white, fontSize: 20)), activeColor: widget.primaryColor, checkColor: Colors.black, controlAffinity: ListTileControlAffinity.leading, onChanged: (bool? checked) { setState(() { if (checked == true) { _tempSelectedItems.add(item); } else { _tempSelectedItems.remove(item); } }); }); }).toList())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR", style: GoogleFonts.teko(color: Colors.white54, fontSize: 20))),
        TextButton(onPressed: () => Navigator.pop(context, _tempSelectedItems), child: Text("ACEPTAR", style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 20, fontWeight: FontWeight.bold))),
      ],
    );
  }
}