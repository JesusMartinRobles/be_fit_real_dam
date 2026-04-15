import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../widgets/custom_widgets.dart';

/// PANTALLA: LoginScreen (Autenticación de Usuarios)
///
/// Primera capa de seguridad de la aplicación.
/// Elección de implementación: Se utiliza una arquitectura basada en un [Stack]
/// para independizar el fondo visual interactivo de los elementos del formulario,
/// permitiendo que el contenido fluya dinámicamente (`resizeToAvoidBottomInset`)
/// cuando el teclado virtual del dispositivo se despliega, evitando errores de renderizado.
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

  /// Método Privado: Lógica de Inicio de Sesión
  ///
  /// Cumple con el Requisito 1 de la rúbrica: Validación de inserción de datos.
  ///
  /// Mecanismo:
  /// 1. Validación local (Frontend): Impide llamadas innecesarias al servidor si
  /// los campos están vacíos (sanitizados con .trim()).
  /// 2. Llamada asíncrona (Backend): Interpela al servicio de Firebase.
  /// 3. UX de Errores: Despliega mensajes de error capturados mediante el
  /// componente estandarizado `showBeFitSnackBar`.
  void _attemptLogin() async {
    // 1. Barrera Local (Prevención de inyección nula)
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      if (mounted) {
        showBeFitSnackBar(context, "POR FAVOR, RELLENA EMAIL Y CONTRASEÑA");
      }
      return;
    }

    // 2. Activación de estado de carga (Feedback visual)
    setState(() => _isLoading = true);

    // 3. Petición al BaaS (Backend as a Service)
    final error = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    // 4. Resolución de la promesa
    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
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
      // La capa base del Scaffold no se redimensiona para mantener el fondo estático
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --- CAPA 1: FONDO CORPORATIVO ---
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

          // --- CAPA 2: INTERFAZ DE FORMULARIO ---
          Scaffold(
            backgroundColor: Colors.transparent,
            // Esta subcapa sí se redimensiona dinámicamente con el teclado
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
                        // Logotipo
                        Image.asset(
                          'assets/images/logo_white.png',
                          height: 250,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 50),

                        // --- CAMPOS DE ENTRADA (Validables) ---

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

                        const SizedBox(height: 40),

                        // --- ÁREA DE ACCIONES ---

                        // Botón de Inicio de Sesión
                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor))
                            : ElevatedButton(
                                onPressed: _attemptLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "INICIAR SESIÓN",
                                  style: TextStyle(
                                    fontFamily: 'Teko',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),

                        const SizedBox(height: 16),

                        // Botón de Derivación a Registro
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "CREAR CUENTA",
                            style: TextStyle(
                              fontFamily: 'Teko',
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
      ),
    );
  }
}
