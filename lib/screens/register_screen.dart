import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import '../widgets/custom_widgets.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool _isLoading = false;
  final _authService = AuthService();

  void _attemptRegister() async {
    // 1. VALIDACIÓN DE VACÍOS (Nueva defensa)
    if (_emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty || 
        _confirmPasswordController.text.trim().isEmpty) {
      if (mounted) {
        showBeFitSnackBar(context, "RELLENA TODOS LOS CAMPOS");
      }
      return;
    }

    // 2. VALIDACIÓN DE CONTRASEÑAS
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        showBeFitSnackBar(context, "LAS CONTRASEÑAS NO COINCIDEN");
      }
      return;
    }

    setState(() => _isLoading = true);
    
    final error = await _authService.register(
      email: _emailController.text,
      password: _passwordController.text,
    );
    
    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      if (mounted) {
        showBeFitSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Usamos el Stack para arreglar lo del teclado aquí también
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/fondo_bfr.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withAlpha(160), BlendMode.darken),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
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
        ],
      ),
    );
  }
}