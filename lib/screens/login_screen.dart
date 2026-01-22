import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// PANTALLA DE LOGIN
// Soy un StatelessWidget porque mi estructura visual no cambia por sí sola.
// (Aunque los campos de texto cambien cuando escribes, eso lo manejan ellos internamente).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // MÉTODO BUILD:
  // Este es mi método principal. Flutter me llama y me dice: "¡Píntate!".
  @override
  Widget build(BuildContext context) {
    // 1. RECUPERANDO EL TEMA
    // Le pregunto al contexto: "¿Cuál es el color primario que definimos en theme.dart?".
    // Así, si mañana cambias el verde por rojo en la configuración, yo me actualizo solo.
    final primaryColor = Theme.of(context).primaryColor;

    // 2. SCAFFOLD (El Andamio)
    // Soy la base de la pantalla.
    return Scaffold(
      // IMPORTANTE:
      // Con 'false', le digo al móvil que NO me deforme cuando salga el teclado.
      // Dejo que el fondo se quede quieto y bonito detrás.
      resizeToAvoidBottomInset: false,

      // 3. CONTAINER DE FONDO
      // Uso un Container porque el Scaffold no tiene propiedad directa para imagen de fondo.
      body: Container(
        decoration: BoxDecoration(
          // Aquí cargo tu imagen 'fondo_bfr.png'
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover, // "Cover" significa: estírate hasta cubrir todo, aunque te cortes.
            
            // FILTRO DE OSCURECIMIENTO:
            // Pongo una capa negra semitransparente encima de la foto.
            // Si no hiciera esto, el texto blanco no se leería bien sobre las zonas claras de la foto.
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(160), // 160 es la opacidad (de 0 a 255)
              BlendMode.darken, // Modo de mezcla: oscurecer
            ),
          ),
        ),

        // 4. SAFE AREA (Zona Segura)
        // Me aseguro de no pintar nada debajo de la cámara (notch) o la barra de batería.
        child: SafeArea(
          child: Padding(
            // Dejo un margen de 24 píxeles a los lados para que no se pegue al borde.
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            
            // 5. CENTRADO
            // Centro todo el contenido en la pantalla.
            child: Center(
              
              // 6. SINGLE CHILD SCROLL VIEW (Scroll)
              // ¡Vital! Si tu móvil es pequeño y sale el teclado, necesito poder hacer scroll
              // para ver el botón de abajo. Si quitas esto, saldría error de píxeles amarillos.
              child: SingleChildScrollView(
                // Le pongo un rebote suave típico de iOS/Android moderno.
                physics: const BouncingScrollPhysics(),
                
                // 7. COLUMN (Columna Vertical)
                // Aquí apilo mis elementos uno debajo de otro.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrados verticalmente
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Estirados a lo ancho
                  children: [
                    
                    // --- A. LOGOTIPO ---
                    Image.asset(
                      'assets/images/logo_white.png',
                      height: 250, // Le doy un tamaño generoso
                      fit: BoxFit.contain, // Que se vea entero sin recortarse
                    ),

                    const SizedBox(height: 50), // Un separador invisible

                    // --- B. INPUTS (FORMULARIO) ---
                    
                    // Etiqueta personalizada (ver método _buildLabel abajo)
                    _buildLabel("CORREO ELECTRÓNICO", primaryColor),
                    const SizedBox(height: 8),
                    
                    // Input personalizado (ver método _buildGlassInput abajo)
                    _buildGlassInput(
                        hint: "ejemplo@befitreal.com",
                        icon: Icons.alternate_email_rounded,
                        primaryColor: primaryColor),

                    const SizedBox(height: 20),

                    _buildLabel("CONTRASEÑA", primaryColor),
                    const SizedBox(height: 8),
                    _buildGlassInput(
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      primaryColor: primaryColor,
                      isPassword: true, // Le digo que oculte el texto
                    ),

                    // ENLACE "OLVIDÉ CONTRASEÑA"
                    // Uso Align para pegarlo a la derecha, porque la Columna lo centra todo.
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
                    
                    // BOTÓN 1: INICIAR SESIÓN (Relleno)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Fondo verde del tema
                        foregroundColor: Colors.black, // Letras negras
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0, // Sin sombra (diseño plano)
                      ),
                      child: Text(
                        "INICIAR SESIÓN",
                        style: GoogleFonts.teko(
                            fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // BOTÓN 2: CREAR CUENTA (Borde)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        // Borde del color primario
                        side: BorderSide(color: primaryColor, width: 2),
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
                            color: Colors.white,
                            letterSpacing: 1),
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

  // MÉTODO AUXILIAR: _buildLabel
  // Creo este método pequeño para no repetir código arriba.
  // Simplemente devuelve un Texto con la fuente Teko y el color verde.
  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.teko(
          color: color, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2),
    );
  }

  // MÉTODO AUXILIAR: _buildGlassInput (EL ARREGLO VISUAL)
  // Aquí es donde solucionamos el problema del "doble borde".
  // En lugar de meter el Input dentro de una caja (Container), aplicamos
  // el estilo directamente al Input.
  Widget _buildGlassInput({
    required String hint,
    required IconData icon,
    required Color primaryColor,
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: isPassword, // Si es password, pongo puntitos
      style: const TextStyle(color: Colors.white), // Lo que escribes sale en blanco
      
      // AQUÍ ESTÁ LA MAGIA DEL DISEÑO:
      decoration: InputDecoration(
        
        // 1. EL FONDO (Glassmorphism)
        // "filled: true" activa el color de fondo.
        filled: true,
        // Uso blanco muy transparente (25 de 255) para el efecto cristal.
        // Esto anula el gris oscuro que venía por defecto en el tema global.
        fillColor: Colors.white.withAlpha(25), 
        
        // 2. LOS BORDES
        // Defino todos los bordes con el MISMO radio (12) para que no haya saltos visuales.
        
        // Borde en reposo (cuando no escribes): Blanco muy sutil
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(30), width: 1),
        ),
        
        // Borde con foco (cuando pulsas para escribir): Verde Volt
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        
        // Ajustes de espaciado interno
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        
        // Textos de ayuda e iconos
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70),
        
        // El ojo para ver la contraseña (solo si es password)
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off_outlined, color: Colors.white38)
            : null,
      ),
    );
  }
}