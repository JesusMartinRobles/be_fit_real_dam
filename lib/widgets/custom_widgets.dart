import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ... (Aquí siguen BeFitLabel, GlassTextField y GlassDropdown igual que antes) ...
// ... (No los borres, solo añade esto al final del archivo) ...

// 1. ETIQUETA VERDE (BeFitLabel)
class BeFitLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const BeFitLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    return Text(
      text,
      style: GoogleFonts.teko(
        color: themeColor, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2
      ),
    );
  }
}

// 2. INPUT DE CRISTAL (GlassTextField)
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off_outlined, color: Colors.white38)
            : null,
      ),
    );
  }
}

// 3. DESPLEGABLE DE CRISTAL (GlassDropdown)
class GlassDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final IconData icon;
  final Function(String?) onChanged;

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
}

// 4. AVISO PERSONALIZADO (SNACKBAR) - ¡NUEVO!
// Esta función muestra un mensaje bonito en lugar del estándar.
void showBeFitSnackBar(BuildContext context, String message, {bool isError = true}) {
  // Saco los colores del tema
  final primaryColor = Theme.of(context).primaryColor;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // El contenido es texto con fuente Teko
      content: Text(
        message, 
        style: GoogleFonts.teko(
          color: Colors.white, 
          fontSize: 20, 
          fontWeight: FontWeight.w500
        ),
        textAlign: TextAlign.center,
      ),
      // Si es error -> Rojo oscuro. Si es éxito -> Verde corporativo.
      backgroundColor: isError ? const Color(0xFFB71C1C) : primaryColor.withAlpha(200),
      
      // Diseño flotante con bordes redondos
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isError ? Colors.redAccent : primaryColor, 
          width: 1
        ),
      ),
      margin: const EdgeInsets.all(20), // Separado de los bordes
      duration: const Duration(seconds: 4), // Dura un poco más para leer
    ),
  );
}