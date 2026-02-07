import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../widgets/custom_widgets.dart';

// PANTALLA DE LOGIN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  void _attemptLogin() async {
    setState(() => _isLoading = true);
    final error = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // TRUCO DE DISEÑO: Usamos un Stack para separar el fondo de la lógica de scroll
    return Stack(
      children: [
        // CAPA 1: EL FONDO (Se queda quieto siempre)
        // Al ponerlo aquí fuera del Scaffold, el teclado no lo deforma.
        Container(
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
        ),

        // CAPA 2: LA INTERFAZ (Responde al teclado)
        Scaffold(
          backgroundColor: Colors.transparent, // ¡Transparente para ver el fondo!
          resizeToAvoidBottomInset: true, // IMPORTANTE: Ahora sí dejamos que el teclado empuje
          
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      // LOGO
                      Image.asset(
                        'assets/images/logo_white.png',
                        height: 250,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 50),

                      // INPUTS
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
                        isPassword: true,
                      ),

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

                      // BOTONES
                      _isLoading
                          ? Center(child: CircularProgressIndicator(color: primaryColor))
                          : ElevatedButton(
                              onPressed: _attemptLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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

                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
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
      ],
    );
  }
}