import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Para poder cerrar sesión
import '../services/auth_service.dart';

// PANTALLA PRINCIPAL (HOME)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. MEMORIA DE LA PANTALLA
  List<String> _selectedMaterials = []; 
  String? _selectedGoal;
  
  // Controladores de texto libre
  final _timeController = TextEditingController();
  final _injuriesController = TextEditingController();

  // 2. DATOS DE OPCIONES
  final List<String> _materialsList = [
    "Gimnasio Completo",
    "Mancuernas",
    "Barra y Discos",
    "Barra de Dominadas",
    "Bandas Elásticas",
    "Peso Corporal (Calistenia)",
    "Kettlebells"
  ];
  
  final List<String> _goalsList = [
    "Fuerza e Hipertrofia",
    "Pérdida de Grasa",
    "Resistencia",
    "Rehabilitación",
    "Movilidad"
  ];

  // MÉTODO PARA CERRAR SESIÓN
  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // LÓGICA DEL MULTI-SELECT
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

    if (results != null) {
      setState(() {
        _selectedMaterials = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(160),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // --- CABECERA ---
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: _logout, 
                        icon: const Icon(Icons.logout, color: Colors.white70),
                        tooltip: "Cerrar Sesión",
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/logo_white.png', height: 100),
                        const SizedBox(width: 15),
                        // Flexible evita que el texto se salga si la pantalla es estrecha
                        Flexible(
                          child: Text(
                            "GENERA TU\nRUTINA",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.teko(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.5, // Líneas juntas
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // --- FORMULARIO ---
                    
                    // 1. SELECTOR DE MATERIAL
                    _buildLabel("MATERIAL DISPONIBLE (Varios)", primaryColor),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. TIEMPO
                    _buildLabel("TIEMPO DISPONIBLE (MIN)", primaryColor),
                    const SizedBox(height: 5),
                    _buildGlassInput(
                      controller: _timeController,
                      hint: "Ej: 40",
                      icon: Icons.timer,
                      primaryColor: primaryColor,
                      keyboardType: TextInputType.number, 
                    ),

                    const SizedBox(height: 20),

                    // 3. OBJETIVO
                    _buildLabel("OBJETIVO", primaryColor),
                    const SizedBox(height: 5),
                    _buildGlassDropdown(
                      hint: "Ej: Fuerza",
                      value: _selectedGoal,
                      items: _goalsList,
                      icon: Icons.flag,
                      onChanged: (val) => setState(() => _selectedGoal = val),
                    ),

                    const SizedBox(height: 20),

                    // 4. MOLESTIAS
                    _buildLabel("MOLESTIAS / LESIONES", primaryColor),
                    const SizedBox(height: 5),
                    _buildGlassInput(
                      controller: _injuriesController,
                      hint: "Ej: Menisco, Muñeca...",
                      icon: Icons.healing,
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 40),

                    // --- BOTÓN GENERAR ---
                    ElevatedButton(
                      onPressed: () {
                        // CAMBIO: Uso 'debugPrint' en lugar de 'print'
                        // Esto quita los avisos azules y es más profesional.
                        debugPrint("Generando rutina...");
                        debugPrint("Materiales: $_selectedMaterials");
                        debugPrint("Tiempo: ${_timeController.text}");
                        debugPrint("Objetivo: $_selectedGoal");
                        debugPrint("Molestias: ${_injuriesController.text}");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: Text("¡GENERAR!", 
                        style: GoogleFonts.teko(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    Center(
                      child: TextButton(
                        onPressed: () {}, 
                        child: Text("PANEL DE ADMINISTRADOR", 
                          style: GoogleFonts.teko(fontSize: 20, color: Colors.white54)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildLabel(String text, Color color) {
    return Text(text, style: GoogleFonts.teko(color: color, fontSize: 18));
  }

  Widget _buildGlassDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(hint, style: GoogleFonts.teko(color: Colors.white38, fontSize: 20)),
                dropdownColor: const Color(0xFF1E1E1E),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                isExpanded: true,
                style: GoogleFonts.teko(color: Colors.white, fontSize: 20),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.teko(color: Colors.white, fontSize: 20),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(30), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        hintText: hint,
        hintStyle: GoogleFonts.teko(color: Colors.white38, fontSize: 20),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
    );
  }
}

// --- CLASE PRIVADA: DIÁLOGO MULTI-SELECCIÓN ---
class _MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;
  final Color primaryColor;

  const _MultiSelectDialog({
    required this.items,
    required this.initialSelectedItems,
    required this.primaryColor,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
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
      title: Text("SELECCIONA MATERIAL", 
        style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
      
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
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("CANCELAR", style: GoogleFonts.teko(color: Colors.white54, fontSize: 20)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelectedItems),
          child: Text("ACEPTAR", style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}