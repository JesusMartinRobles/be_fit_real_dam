import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. RECUPERAMOS EL COLOR VERDE VOLT DEL TEMA
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Evita que el fondo se achuche al salir el teclado
      resizeToAvoidBottomInset: false,

      body: Container(
        // FONDO DE PANTALLA
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              // Oscurecemos bastante (85%) para que resalte el neón
              Colors.black.withAlpha(160),
              BlendMode.darken,
            ),
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              // Scroll para teclados pequeños
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Estira todo a lo ancho
                  children: [
                    // --- A. LOGOTIPO ---
                    Image.asset(
                      'assets/images/logo_white.png',
                      height: 250, // Tamaño controlado
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 50), // Espacio antes del formulario

                    // --- B. INPUTS PERSONALIZADOS (Etiquetas Fuera) ---

                    // 1. EMAIL
                    _buildLabel("CORREO ELECTRÓNICO", primaryColor),
                    const SizedBox(height: 8),
                    _buildGlassInput(
                        hint: "ejemplo@befitreal.com",
                        icon: Icons.alternate_email_rounded,
                        primaryColor: primaryColor),

                    const SizedBox(height: 20),

                    // 2. CONTRASEÑA
                    _buildLabel("CONTRASEÑA", primaryColor),
                    const SizedBox(height: 8),
                    _buildGlassInput(
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      primaryColor: primaryColor,
                      isPassword: true,
                    ),

                    // Link Olvidé contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "¿HAS OLVIDADO LA CONTRASEÑA?",
                          style: GoogleFonts.teko(
                            color: Colors.white54,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- C. BOTONES ---

                    // BOTÓN 1: INICIAR SESIÓN (Sólido)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Fondo Verde
                        foregroundColor: Colors.black, // Texto Negro
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Bordes redondeados pero no mucho
                        ),
                        elevation: 0, // Plano
                      ),
                      child: Text(
                        "INICIAR SESIÓN",
                        style: GoogleFonts.teko(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BOTÓN 2: REGISTRO (Borde)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: primaryColor, width: 2), // Borde Verde
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "CREAR CUENTA",
                        style: GoogleFonts.teko(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Texto Blanco
                          letterSpacing: 1,
                        ),
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

  // --- WIDGETS AUXILIARES (Para limpiar el código principal) ---

  // 1. Etiqueta Verde Pequeña (Encima del input)
  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.teko(
        color: color, // Verde Volt
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  // 2. Input Estilo Cristal (Glassmorphism)
  Widget _buildGlassInput({
    required String hint,
    required IconData icon,
    required Color primaryColor,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Fondo semitransparente (Blanco al 10%)
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        // Borde muy sutil
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: TextFormField(
        obscureText: isPassword,
        style:
            const TextStyle(color: Colors.white), // Lo que escribes es blanco
        decoration: InputDecoration(
          border: InputBorder.none, // Quitamos el borde por defecto de Flutter
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white38), // Placeholder grisáceo
          prefixIcon: Icon(icon, color: Colors.white70),
          // Si es password, ponemos el ojo
          suffixIcon: isPassword
              ? Icon(Icons.visibility_off_outlined, color: Colors.white38)
              : null,
        ),
      ),
    );
  }
}
