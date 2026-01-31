import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart'; // Importo esto por si necesito referencias

// NOTA PARA MÍ:
// Uso un StatefulWidget porque esta pantalla no es estática.
// Necesita "recordar" qué opciones he seleccionado en los menús.
// Si fuera Stateless, se olvidaría de todo cada vez que toco la pantalla.
class RoutineFormScreen extends StatefulWidget {
  const RoutineFormScreen({super.key});

  @override
  State<RoutineFormScreen> createState() => _RoutineFormScreenState();
}

class _RoutineFormScreenState extends State<RoutineFormScreen> {
  // 1. MI "MEMORIA" (VARIABLES DE ESTADO)
  // Aquí es donde guardo las respuestas del usuario.
  
  // Para los materiales uso una LISTA, porque quiero permitir elegir
  // "Mancuernas" Y "Bandas" a la vez.
  List<String> _selectedMaterials = [];
  
  // Para el objetivo y el enfoque uso un String simple (puede ser nulo al principio).
  String? _selectedGoal;
  String? _selectedFocus; // Este es nuevo: ¿Qué entreno hoy? (Empuje, Pierna...)

  // Para el tiempo y las molestias uso CONTROLADORES, porque son campos de texto libre
  // donde el usuario escribe lo que quiera.
  final _timeController = TextEditingController();
  final _injuriesController = TextEditingController();

  // 2. MIS DATOS (LAS OPCIONES DEL MENÚ)
  // Defino aquí las listas para no ensuciar el método build.
  
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
    "Rehabilitación"
  ];

  // Lista de divisiones musculares (Splits) para que la IA sepa qué mandarme.
  final List<String> _focusList = [
    "Full Body (Cuerpo Completo)",
    "Tren Superior (Torso)",
    "Tren Inferior (Pierna)",
    "Empuje (Push - Pecho/Hombro/Tríceps)",
    "Tracción (Pull - Espalda/Bíceps)",
    "Core y Cardio",
    "Movilidad y Recuperación"
  ];

  // 3. MI DISEÑO (MÉTODO BUILD)
  @override
  Widget build(BuildContext context) {
    // Saco el color verde de mi tema para usarlo fácil.
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // TRUCO: Dejo que el cuerpo se meta detrás de la barra de arriba
      // para que el fondo cubra TODA la pantalla.
      extendBodyBehindAppBar: true,
      
      // BARRA SUPERIOR (APPBAR)
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Invisible
        elevation: 0, // Sin sombra
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // Acción: Volver al menú anterior (el Home)
            Navigator.of(context).pop();
          },
        ),
        title: Text("CONFIGURAR SESIÓN", 
          style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      
      // FONDO DE PANTALLA
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover, // Estirar imagen
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(160), // Oscurecer para leer bien
              BlendMode.darken,
            ),
          ),
        ),
        
        // CONTENIDO SEGURO
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              // Pongo scroll por si la pantalla es pequeña
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    const SizedBox(height: 20),

                    // --- CAMPO 1: ENFOQUE DEL DÍA (NUEVO) ---
                    // Uso mi widget artesano '_buildLabel' para el título verde.
                    _buildLabel("ENFOQUE DEL DÍA", primaryColor),
                    const SizedBox(height: 5),
                    // Uso mi widget artesano '_buildGlassDropdown' para el menú.
                    _buildGlassDropdown(
                      hint: "Ej: Empuje, Pierna...",
                      value: _selectedFocus, // Le paso el valor actual
                      items: _focusList, // Le paso la lista de opciones
                      icon: Icons.accessibility_new,
                      // Cuando el usuario elige algo, actualizo mi memoria (estado)
                      onChanged: (val) => setState(() => _selectedFocus = val),
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 2: MATERIAL (MULTI-SELECCIÓN) ---
                    _buildLabel("MATERIAL DISPONIBLE", primaryColor),
                    const SizedBox(height: 5),
                    // Como elegir varios es complejo, uso un InkWell que parece un input,
                    // pero al tocarlo abre un diálogo especial (ver _showMultiSelectDialog abajo).
                    InkWell(
                      onTap: _showMultiSelectDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25), // Efecto cristal
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(30)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.white70),
                            const SizedBox(width: 15),
                            Expanded(
                              // Aquí muestro qué ha elegido el usuario.
                              // Si la lista está vacía -> Muestro texto de ayuda.
                              // Si hay cosas -> Las uno con comas (join).
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
                                overflow: TextOverflow.ellipsis, // Si es muy largo pongo "..."
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 3: TIEMPO (TEXTO LIBRE) ---
                    _buildLabel("TIEMPO (MIN)", primaryColor),
                    const SizedBox(height: 5),
                    // Uso mi widget '_buildGlassInput' configurado para números.
                    _buildGlassInput(
                      controller: _timeController,
                      hint: "Ej: 40",
                      icon: Icons.timer,
                      primaryColor: primaryColor,
                      keyboardType: TextInputType.number, // ¡Saca el teclado numérico!
                    ),

                    const SizedBox(height: 20),

                    // --- CAMPO 4: OBJETIVO ---
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

                    // --- CAMPO 5: MOLESTIAS ---
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
                        // AQUÍ ES DONDE LLAMARÉ A LA IA MÁS ADELANTE.
                        // Por ahora, imprimo los datos para ver que funciona.
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

  // ==========================================
  //      MIS WIDGETS ARTESANOS (HELPERS)
  // ==========================================
  
  // 1. DIÁLOGO MULTI-SELECCIÓN
  // Esta función abre una ventana flotante para elegir varios materiales.
  void _showMultiSelectDialog() async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Llamo a mi clase privada _MultiSelectDialog (definida abajo del todo)
        return _MultiSelectDialog(
          items: _materialsList,
          initialSelectedItems: _selectedMaterials,
          primaryColor: Theme.of(context).primaryColor,
        );
      },
    );
    // Si el usuario dio a "Aceptar", guardo la lista que me devuelve.
    if (results != null) setState(() => _selectedMaterials = results);
  }

  // 2. ETIQUETA DE TEXTO (Para no repetir estilo mil veces)
  Widget _buildLabel(String text, Color color) {
    return Text(text, style: GoogleFonts.teko(color: color, fontSize: 18));
  }

  // 3. DESPLEGABLE DE CRISTAL (DROPDOWN)
  // Diseño una caja semitransparente que contiene un DropdownButton estándar.
  Widget _buildGlassDropdown({
    required String? value, // Valor actual
    required List<String> items, // Lista de opciones
    required String hint, // Texto de ayuda
    required IconData icon, // Icono
    required Function(String?) onChanged, // Qué hacer al cambiar
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25), // Fondo cristal
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline( // Quito la línea fea por defecto
              child: DropdownButton<String>(
                value: value,
                hint: Text(hint, style: GoogleFonts.teko(color: Colors.white38, fontSize: 20)),
                dropdownColor: const Color(0xFF1E1E1E), // El menú que se abre es oscuro
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                isExpanded: true,
                style: GoogleFonts.teko(color: Colors.white, fontSize: 20), // Estilo del texto seleccionado
                // Aquí convierto mis Strings en opciones de menú
                items: items.map((String item) => DropdownMenuItem<String>(
                  value: item, 
                  child: Text(item),
                )).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. INPUT DE CRISTAL (TEXT FIELD)
  // Igual que en el Login: fondo transparente y bordes suaves.
  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller, // Conecto mi micrófono
      style: GoogleFonts.teko(color: Colors.white, fontSize: 20),
      keyboardType: keyboardType, // Numérico o texto según toque
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        // Defino bordes idénticos para reposo y foco (para que no salte)
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

// ==============================================================
// CLASE PRIVADA: EL DIÁLOGO DE SELECCIÓN MÚLTIPLE
// ==============================================================
// Es un StatefulWidget aparte porque necesita gestionar sus propios checkboxes
// antes de devolver la lista final a la pantalla principal.
class _MultiSelectDialog extends StatefulWidget {
  final List<String> items; // Todas las opciones
  final List<String> initialSelectedItems; // Lo que ya estaba marcado
  final Color primaryColor;

  const _MultiSelectDialog({
    required this.items, 
    required this.initialSelectedItems, 
    required this.primaryColor
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  // Lista temporal para jugar con los checkboxes sin guardar todavía
  late List<String> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    // Hago una copia de la lista original para no modificarla por referencia
    _tempSelectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E), // Fondo oscuro
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("SELECCIONA MATERIAL", 
        style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
      
      // Lista con Scroll de Checkboxes
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            final isChecked = _tempSelectedItems.contains(item);
            return CheckboxListTile(
              value: isChecked,
              title: Text(item, style: GoogleFonts.teko(color: Colors.white, fontSize: 20)),
              activeColor: widget.primaryColor,
              checkColor: Colors.black,
              controlAffinity: ListTileControlAffinity.leading, // Casilla a la izquierda
              onChanged: (bool? checked) {
                // Lógica: Si marco, añado. Si desmarco, quito.
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
      // Botones de abajo
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cerrar (devuelve null)
          child: Text("CANCELAR", style: GoogleFonts.teko(color: Colors.white54, fontSize: 20)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelectedItems), // Cerrar y devolver la lista nueva
          child: Text("ACEPTAR", style: GoogleFonts.teko(color: widget.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}