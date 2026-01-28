import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importo mis servicios y pantallas
import '../services/auth_service.dart';
import 'home_screen.dart';

// NOTA PARA MÍ:
// Uso StatefulWidget porque esta pantalla tiene vida propia:
// 1. Necesita leer lo que escribo en tiempo real.
// 2. Necesita cambiar su aspecto (mostrar rueda de carga) cuando pulso el botón.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. LOS MICRÓFONOS (Controllers)
  // He creado 4 controladores, uno para cada campo que me pide el diseño.
  // Sin esto, no tengo forma de saber qué ha escrito el usuario.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController(); // Este es para el código VIP

  // 2. ESTADO DE CARGA
  // Variable para saber si estoy "pensando" (conectando con Firebase).
  bool _isLoading = false;

  // 3. EL CEREBRO
  // Instancio mi servicio para poder llamar al método 'register' que creé antes.
  final _authService = AuthService();

  // --- LÓGICA DE REGISTRO ---
  // Esta función se activa cuando el usuario pulsa "REGISTRARSE".
  void _attemptRegister() async {
    
    // PASO A: Validaciones de seguridad antes de molestar al servidor.
    // Compruebo si las contraseñas son iguales. Si no, corto el proceso.
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Las contraseñas no coinciden"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // ¡Alto! No sigo ejecutando.
    }

    // PASO B: Si todo pinta bien, activo el modo carga.
    // El 'setState' repinta la pantalla y mostrará el círculo girando.
    setState(() => _isLoading = true);

    // PASO C: Llamo a Firebase.
    // Le paso el email y la contraseña. El código de invitación por ahora no lo
    // valido en Firebase, pero ya lo tengo capturado para el futuro.
    final error = await _authService.register(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // PASO D: Ya tengo respuesta. Apago el modo carga.
    if (mounted) setState(() => _isLoading = false);

    // PASO E: Decido qué hacer según la respuesta.
    if (error == null) {
      // ÉXITO: El usuario se ha creado.
      // Borro el historial de pantallas y me voy al Home.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // ERROR: Algo falló (ej: email repetido). Se lo digo al usuario.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- DISEÑO VISUAL (UI) ---
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Truco: Extiendo el cuerpo detrás de la barra superior para aprovechar toda la pantalla
      extendBodyBehindAppBar: true,
      
      // Barra superior transparente solo para el botón de "Atrás"
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Invisible
        elevation: 0, // Sin sombra
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // Acción: Volver a la pantalla anterior (Login)
            Navigator.of(context).pop();
          },
        ),
      ),
      
      // Mismo fondo que en el Login para mantener coherencia (Brand consistency)
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // --- CABECERA PERSONALIZADA ---
                    // He usado una Row (fila) para poner el logo y el texto lado a lado,
                    // tal y como aparecía en mi boceto de papel.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logo_white.png',
                          height: 100, // Más pequeño que en el login
                        ),

                        // Flexible evita que el texto se salga si la pantalla es estrecha
                        Flexible(
                          child: Text(
                            "PANTALLA DE\nREGISTRO",
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
                    
                    const SizedBox(height: 100),

                    // --- FORMULARIO ---
                    // Reutilizo mis métodos auxiliares para no repetir código 4 veces.
                    
                    // 1. Email
                    _buildLabel("E-MAIL", primaryColor),
                    const SizedBox(height: 5),
                    _buildGlassInput(
                      controller: _emailController,
                      hint: "ejemplo@befitreal.com",
                      icon: Icons.email_outlined,
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 15),

                    // 2. Contraseña
                    _buildLabel("CONTRASEÑA", primaryColor),
                    const SizedBox(height: 5),
                    _buildGlassInput(
                      controller: _passwordController,
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      primaryColor: primaryColor,
                      isPassword: true,
                    ),

                    const SizedBox(height: 15),

                    // 3. Confirmar Contraseña (Nuevo campo)
                    _buildLabel("CONFIRMAR CONTRASEÑA", primaryColor),
                    const SizedBox(height: 5),
                    _buildGlassInput(
                      controller: _confirmPasswordController,
                      hint: "••••••••",
                      icon: Icons.lock_reset,
                      primaryColor: primaryColor,
                      isPassword: true,
                    ),

                    const SizedBox(height: 15),

                    // 4. Código de Invitación
                    _buildLabel("CÓDIGO DE INVITACIÓN", primaryColor),
                    const SizedBox(height: 5),
                    _buildGlassInput(
                      controller: _inviteCodeController,
                      hint: "Opcional",
                      icon: Icons.confirmation_number_outlined,
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 40),

                    // --- BOTÓN DE ACCIÓN ---
                    // Si estoy cargando -> Rueda. Si no -> Botón.
                    _isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : ElevatedButton(
                            onPressed: _attemptRegister, // Ejecuta la lógica de arriba
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              "REGISTRARSE",
                              style: GoogleFonts.teko(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
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

  // --- MIS HERRAMIENTAS DE DISEÑO ---
  // He copiado esto del Login para que el estilo sea idéntico (Glassmorphism).
  
  Widget _buildLabel(String text, Color color) {
    return Text(text, style: GoogleFonts.teko(color: color, fontSize: 18));
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    bool isPassword = false,
  }) {
    // Aquí está el truco del diseño: uso el propio input para pintar el fondo
    // y me ahorro problemas de bordes dobles.
    return TextFormField(
      controller: controller, // ¡Importante! Conecto el microfono aquí
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(25), // Fondo transparente
        
        // Bordes sincronizados (todos con radio 12)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(30), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2), // Verde al tocar
        ),
        
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
    );
  }
}