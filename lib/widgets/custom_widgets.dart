import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// NOTA PARA MÍ:
// He creado este archivo para cumplir el principio DRY (Don't Repeat Yourself).
// En lugar de escribir el código de un input 20 veces en toda la app,
// lo escribo aquí UNA vez y lo llamo desde donde quiera. ¡Ingeniería inteligente!

// ---------------------------------------------------------------------------
// 1. ETIQUETA VERDE (BeFitLabel)
// ---------------------------------------------------------------------------
// Este es el título que pongo encima de los campos (ej: "CORREO ELECTRÓNICO").
// Lo he sacado aquí para asegurarme de que TODOS los títulos de la app
// tengan exactamente el mismo tamaño, fuente y color. Coherencia visual.
class BeFitLabel extends StatelessWidget {
  final String text;
  final Color? color; // Opcional: por si un día quiero que sea blanco en vez de verde.

  const BeFitLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    // Si no me pasan un color específico, uso el verde de mi tema global.
    final themeColor = color ?? Theme.of(context).primaryColor;

    return Text(
      text,
      style: GoogleFonts.teko(
        color: themeColor, 
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        letterSpacing: 1.2
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. INPUT DE CRISTAL (GlassTextField)
// ---------------------------------------------------------------------------
// Esta es mi joya de la corona. Es un campo de texto con diseño "Glassmorphism".
// He unificado aquí la lógica de los bordes y el fondo para evitar el problema
// visual de los "dobles bordes" que tenía antes.
class GlassTextField extends StatelessWidget {
  // Necesito pedir estas cosas para que el input funcione:
  final TextEditingController controller; // El "micrófono" para leer lo que escriben.
  final String hint; // La pista (ej: "ejemplo@gmail.com").
  final IconData icon; // El dibujito de la izquierda.
  final bool isPassword; // ¿Debo ocultar el texto con puntitos?
  final TextInputType keyboardType; // ¿Saco teclado de letras o de números?

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false, // Por defecto asumo que NO es contraseña.
    this.keyboardType = TextInputType.text, // Por defecto asumo que es texto.
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white), // Lo que escribo siempre es blanco.
      
      decoration: InputDecoration(
        // FONDO: Aquí aplico el efecto cristal (blanco muy transparente).
        // 'filled: true' es vital para que se pinte el color de fondo.
        filled: true,
        fillColor: Colors.white.withAlpha(25), 
        
        // BORDES: Defino todos los estados con el mismo radio (12) para que
        // al pulsar no haya "saltos" visuales extraños.
        
        // Estado reposo (borde blanco sutil)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(30), width: 1),
        ),
        
        // Estado foco (borde verde brillante)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        
        // Espaciado interno para que el texto no toque los bordes.
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        
        // Textos y Iconos decorativos
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70),
        
        // Si es contraseña, muestro el icono del ojo (aunque por ahora no hace nada, queda pro).
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off_outlined, color: Colors.white38)
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. DESPLEGABLE DE CRISTAL (GlassDropdown)
// ---------------------------------------------------------------------------
// Como los menús desplegables en Flutter son feos por defecto, he creado este
// envoltorio para que parezcan iguales a mis Inputs de Cristal.
class GlassDropdown extends StatelessWidget {
  final String? value; // La opción seleccionada actualmente.
  final List<String> items; // La lista de opciones posibles.
  final String hint; // Texto de ayuda ("Selecciona...").
  final IconData icon; // Icono.
  final Function(String?) onChanged; // La función que avisa a la pantalla padre cuando algo cambia.

  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Uso un Container para imitar el diseño del Input (mismo color y borde).
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
          // Expanded obliga al desplegable a ocupar todo el ancho disponible.
          Expanded(
            child: DropdownButtonHideUnderline( // Quito la línea fea por defecto del Dropdown.
              child: DropdownButton<String>(
                value: value,
                hint: Text(hint, style: GoogleFonts.teko(color: Colors.white38, fontSize: 20)),
                dropdownColor: const Color(0xFF1E1E1E), // El menú desplegable será GRIS OSCURO.
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                isExpanded: true,
                style: GoogleFonts.teko(color: Colors.white, fontSize: 20),
                
                // Magia de Flutter: convierto mi lista de Strings en una lista de Items visuales.
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
}