import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import '../widgets/custom_widgets.dart';

/// PANTALLA: RegisterScreen (Registro de Nuevos Usuarios)
///
/// Componente encargado de la creación de cuentas.
/// Elección de implementación: Incorpora validaciones locales estrictas
/// (campos obligatorios y coincidencia de contraseñas) para evitar peticiones
/// malformadas al servidor. Exige un "Código de Invitación" activo consultando
/// una colección separada en Firestore, implementando un control de acceso
/// para mantener la exclusividad de la aplicación.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de estado para capturar la entrada del usuario
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  // Bandera de estado para el indicador de carga asíncrona
  bool _isLoading = false;

  // Instancia del servicio de autenticación (desacoplado de la vista)
  final _authService = AuthService();

  /// Método Privado: Lógica de Registro
  ///
  /// Cumple con el requisito de "validación de correcta inserción".
  /// Ejecuta comprobaciones secuenciales en el cliente antes de invocar el backend.
  void _attemptRegister() async {
    // 1. Barrera de Seguridad Local: Campos vacíos
    // Se utiliza .trim() para evitar que el usuario inserte solo espacios en blanco.
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _inviteCodeController.text.trim().isEmpty) {
      if (mounted) {
        showBeFitSnackBar(context, "RELLENA TODOS LOS CAMPOS");
      }
      return; // Interrupción temprana (Early Return)
    }

    // 2. Barrera de Seguridad Local: Coincidencia de credenciales
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        showBeFitSnackBar(context, "LAS CONTRASEÑAS NO COINCIDEN");
      }
      return; // Interrupción temprana (Early Return)
    }

    setState(() => _isLoading = true);

    // 3. Ejecución del Servicio (Backend)
    // Se fuerza la sanitización a mayúsculas del código para garantizar
    // coincidencias exactas (case-insensitive) con la base de datos.
    final error = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      inviteCode: _inviteCodeController.text.trim().toUpperCase(),
    );

    if (mounted) setState(() => _isLoading = false);

    // 4. Resolución de Promesa (Navegación o Error)
    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()));
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
      // Uso de Stack para mantener la imagen de fondo estática mientras el
      // SingleChildScrollView se desplaza al invocar el teclado virtual.
      body: Stack(
        children: [
          // --- CAPA FONDO ---
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/fondo_bfr.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withAlpha(160), BlendMode.darken),
              ),
            ),
          ),

          // --- CAPA FORMULARIO (Desplazable) ---
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
                        // CABECERA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/logo_white.png',
                                height: 80),
                            const SizedBox(width: 20),
                            const Flexible(
                              child: Text("PANTALLA DE\nREGISTRO",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Teko',
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.0)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // --- CAMPOS DE ENTRADA ---

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
                          hint:
                              "Introduce tu código (Ej: VIP_2026)", // Corrección UX (obligatorio)
                          icon: Icons.confirmation_number_outlined,
                        ),

                        const SizedBox(height: 40),

                        // --- BOTÓN DE ACCIÓN ---
                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor))
                            : ElevatedButton(
                                onPressed: _attemptRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("REGISTRARSE",
                                    style: TextStyle(
                                        fontFamily: 'Teko',
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
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
