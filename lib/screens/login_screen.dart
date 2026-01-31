import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importo mis piezas clave:
import '../services/auth_service.dart';
import 'home_screen.dart'; 
import 'register_screen.dart';
// ¡IMPORTANTE! Aquí importo mis ladrillos personalizados para usarlos.
import '../widgets/custom_widgets.dart'; 

// NOTA PARA MÍ:
// Soy un StatefulWidget porque tengo "memoria":
// 1. Recuerdo lo que el usuario escribe.
// 2. Recuerdo si estoy cargando (mostrando el spinner) o no.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. MIS MICRÓFONOS (Controllers)
  // Necesarios para extraer el texto de los inputs cuando pulse el botón.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. ESTADO DE LA PANTALLA
  // ¿Estoy ocupado hablando con Firebase?
  bool _isLoading = false;

  // 3. MI CEREBRO (El servicio)
  final _authService = AuthService();

  // LÓGICA: INTENTAR INICIAR SESIÓN
  void _attemptLogin() async {
    // Paso 1: Aviso a la pantalla de que se ponga en modo "pensando".
    setState(() => _isLoading = true);

    // Paso 2: Llamo al servicio y espero (await) a que Google conteste.
    final error = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Paso 3: Ya ha contestado. Quito el modo "pensando".
    // Uso 'mounted' para asegurarme de que la pantalla sigue existiendo (por seguridad).
    if (mounted) setState(() => _isLoading = false);

    // Paso 4: Compruebo el resultado.
    if (error == null) {
      // ÉXITO: El usuario existe.
      if (mounted) {
        // Navego al Home y BORRO el Login del historial (pushReplacement)
        // para que no pueda volver atrás.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // ERROR: Contraseña mal o usuario no existe.
      if (mounted) {
        // Muestro una barrita roja abajo avisando.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Mantengo el fondo quieto al salir el teclado.
      resizeToAvoidBottomInset: false,
      
      body: Container(
        // FONDO DE PANTALLA
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
                    // LOGO GRANDE
                    Image.asset('assets/images/logo_white.png', height: 250, fit: BoxFit.contain),
                    
                    const SizedBox(height: 50),

                    // --- AQUÍ USO MIS WIDGETS REUTILIZABLES ---
                    // Fíjate qué limpio queda el código ahora.
                    
                    const BeFitLabel("CORREO ELECTRÓNICO"),
                    const SizedBox(height: 8),
                    GlassTextField(
                      controller: _emailController,
                      hint: "ejemplo@befitreal.com",
                      icon: Icons.alternate_email_rounded,
                    ),

                    const SizedBox(height: 20),

                    const BeFitLabel("CONTRASEÑA"),
                    const SizedBox(height: 8),
                    GlassTextField(
                      controller: _passwordController,
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true, // ¡Es secreto!
                    ),

                    // Botón "Olvidé contraseña"
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text("¿HAS OLVIDADO LA CONTRASEÑA?", style: GoogleFonts.teko(color: Colors.white54, fontSize: 16, letterSpacing: 1)),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN PRINCIPAL
                    // Uso un operador ternario (? :) para decidir qué mostrar:
                    // ¿Está cargando? -> Muestra Rueda.
                    // ¿No? -> Muestra Botón.
                    _isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : ElevatedButton(
                            onPressed: _attemptLogin, // Al pulsar, lanzo la lógica.
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text("INICIAR SESIÓN", style: GoogleFonts.teko(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),

                    const SizedBox(height: 16),

                    // BOTÓN REGISTRO
                    OutlinedButton(
                      onPressed: () {
                        // Navegación normal (push) para poder volver atrás si quiero.
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("CREAR CUENTA", style: GoogleFonts.teko(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
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
}