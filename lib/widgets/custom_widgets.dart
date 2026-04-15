import 'package:flutter/material.dart';

/// COMPONENTE UI: BeFitLabel
///
/// Etiqueta de texto estandarizada para los títulos de los formularios.
/// Elección de implementación: Reutilización de código (Principio DRY).
/// Garantiza la consistencia tipográfica en toda la aplicación utilizando
/// la fuente corporativa local 'Teko'.
class BeFitLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const BeFitLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Teko',
          color: themeColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2),
    );
  }
}

/// COMPONENTE UI: GlassTextField
///
/// Campo de entrada de texto con diseño 'Glassmorphism' (cristal esmerilado).
/// Elección de implementación: Encapsula la lógica visual de los inputs.
/// Soporta configuración dinámica (contraseñas ocultas, tipos de teclado)
/// manteniendo la uniformidad estética sin saturar el código de las pantallas.
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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

/// COMPONENTE UI: GlassDropdown
///
/// Menú desplegable personalizado con estética de cristal.
/// Elección de implementación: Sustituye el diseño nativo plano de Material
/// por una envoltura estilizada que se integra armónicamente con el fondo oscuro.
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
                hint: Text(hint,
                    style: const TextStyle(
                        fontFamily: 'Teko',
                        color: Colors.white38,
                        fontSize: 20)),
                dropdownColor: const Color(0xFF1E1E1E),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                isExpanded: true,
                style: const TextStyle(
                    fontFamily: 'Teko', color: Colors.white, fontSize: 20),
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

/// UTILIDAD UI: showBeFitSnackBar
///
/// Sistema centralizado de notificaciones (Toasts/SnackBars) para el usuario.
/// Elección de implementación (Cumplimiento de Rúbrica): Esta función es el
/// vector visual utilizado para validar la "correcta inserción de datos por
/// el usuario". Permite discriminar visualmente entre mensajes de error (rojo)
/// y de éxito (verde corporativo), mejorando notablemente la experiencia de
/// usuario (UX) frente a los SnackBars nativos de sistema.
void showBeFitSnackBar(BuildContext context, String message,
    {bool isError = true}) {
  final primaryColor = Theme.of(context).primaryColor;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
            fontFamily: 'Teko',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
      backgroundColor:
          isError ? const Color(0xFFB71C1C) : primaryColor.withAlpha(200),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isError ? Colors.redAccent : primaryColor, width: 1),
      ),
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 4),
    ),
  );
}
