import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
// Importo mis herramientas:
import '../widgets/custom_widgets.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. LOS MICRÓFONOS
  // Necesito 4 controladores porque tengo 4 campos en el diseño de registro.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  // 2. ESTADO
  bool _isLoading = false;
  final _authService = AuthService();

  // LÓGICA: INTENTAR REGISTRARSE
  void _attemptRegister() async {
    // Paso A: Validación Local.
    // Antes de molestar al servidor, compruebo si las contraseñas coinciden.
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Las contraseñas no coinciden"), backgroundColor: Colors.red));
      }
      return; // Si no coinciden, paro aquí.
    }

    // Paso B: Activo carga y llamo a Firebase.
    setState(() => _isLoading = true);
    final error = await _authService.register(
      email: _emailController.text,
      password: _passwordController.text,
    );
    
    // Paso C: Apago carga.
    if (mounted) setState(() => _isLoading = false);

    // Paso D: Resultado.
    if (error == null) {
      // ÉXITO: Usuario creado. Vamos al Home.
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      // ERROR: Aviso al usuario.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Extiendo el cuerpo para que el fondo cubra también la barra de estado.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Botón de atrás para volver al Login.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
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
                    // CABECERA CON LOGO PEQUEÑO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo_white.png', height: 80),
                        const SizedBox(width: 20),
                        Flexible(
                          child: Text("PANTALLA DE\nREGISTRO", textAlign: TextAlign.right, style: GoogleFonts.teko(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // --- FORMULARIO REUTILIZABLE ---
                    
                    const BeFitLabel("E-MAIL"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _emailController,
                      hint: "ejemplo@befitreal.com",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 15),

                    const BeFitLabel("CONTRASEÑA"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _passwordController,
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 15),

                    const BeFitLabel("CONFIRMAR CONTRASEÑA"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _confirmPasswordController,
                      hint: "••••••••",
                      icon: Icons.lock_reset,
                      isPassword: true,
                    ),

                    const SizedBox(height: 15),

                    const BeFitLabel("CÓDIGO DE INVITACIÓN"),
                    const SizedBox(height: 5),
                    GlassTextField(
                      controller: _inviteCodeController,
                      hint: "Opcional",
                      icon: Icons.confirmation_number_outlined,
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN FINAL
                    _isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : ElevatedButton(
                            onPressed: _attemptRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("REGISTRARSE", style: GoogleFonts.teko(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1)),
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