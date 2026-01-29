import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importo mis propios archivos:
import '../services/auth_service.dart'; // La clase que habla con Firebase (el "Back")
import 'home_screen.dart'; // La pantalla a la que iré si todo sale bien
import 'register_screen.dart';

// NOTA PARA MÍ:
// He cambiado de StatelessWidget a StatefulWidget.
// ¿Por qué? Porque necesito "memoria" (Estado). Una pantalla estática no puede
// recordar si el usuario está escribiendo o si el círculo de carga debe girar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Esta es la clase que guarda los datos (el Estado).
// En Java, esto serían las variables de instancia de mi clase.
class _LoginScreenState extends State<LoginScreen> {
  
  // 1. LOS "MICRÓFONOS" (Controllers)
  // Necesito estos objetos para poder "leer" lo que el usuario escribe en los campos de texto.
  // Sin ellos, los TextFormFields son cajas mudas.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. ESTADO DE LA INTERFAZ
  // Variable booleana para saber si estoy esperando a Firebase.
  // Si es true -> Muestro un spinner. Si es false -> Muestro el botón.
  bool _isLoading = false;

  // 3. MI CONEXIÓN CON EL EXTERIOR
  // Instancio mi servicio de autenticación aquí para usarlo luego.
  final _authService = AuthService();

  // MÉTODO PRINCIPAL: _attemptLogin
  // Esta es la lógica que se ejecuta al pulsar el botón "INICIAR SESIÓN".
  // Uso 'async' porque hablar con Firebase tarda un tiempo y no quiero congelar la app.
  void _attemptLogin() async {
    
    // PASO 1: Aviso a la pantalla de que empiece a cargar.
    // 'setState' es vital: le dice a Flutter "He cambiado una variable, ¡repinta la pantalla!".
    setState(() => _isLoading = true);

    // PASO 2: Llamo a mi servicio (el cerebro) y espero ('await') su respuesta.
    // Mientras espero aquí, la app sigue viva mostrando el spinner.
    final error = await _authService.login(
      email: _emailController.text, // Saco el texto del controlador
      password: _passwordController.text,
    );

    // PASO 3: Ya ha respondido Firebase. Paro la carga.
    // 'mounted' es una seguridad: comprueba si la pantalla sigue abierta antes de pintar nada.
    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      // SI NO HAY ERROR (error es null) -> ÉXITO
      if (mounted) {
        // Navegación: "Mato" la pantalla actual (Login) y pongo la nueva (Home).
        // Uso pushReplacement para que si le da a "Atrás" no vuelva al login.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // SI HAY ERROR -> AVISO AL USUARIO
      if (mounted) {
        // ScaffoldMessenger es la forma estándar de mostrar barritas de aviso abajo (SnackBar).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red, // Rojo para que se vea que es un fallo
          ),
        );
      }
    }
  }

  // MÉTODO BUILD: Aquí defino la parte visual (UI)
  @override
  Widget build(BuildContext context) {
    // Cojo el color verde de mi tema global para no escribir códigos hexadecimales a mano.
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      
      body: Container(
        // FONDO: Uso un Container con decoración para poner la imagen.
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/fondo_bfr.png'),
            fit: BoxFit.cover, // Estirar imagen para cubrir todo
            // Filtro oscuro para que las letras blancas se lean bien.
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(160), // Opacidad ~60%
              BlendMode.darken,
            ),
          ),
        ),
        
        // ZONA SEGURA: Evita que el notch o la batería tapen mi contenido.
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              // SCROLL: Necesario por si la pantalla es pequeña.
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. LOGOTIPO
                    Image.asset(
                      'assets/images/logo_white.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 50),

                    // B. FORMULARIO
                    // Uso mis widgets personalizados (ver abajo) para tener el código limpio.
                    
                    // Email
                    _buildLabel("CORREO ELECTRÓNICO", primaryColor),
                    const SizedBox(height: 8),
                    _buildGlassInput(
                      controller: _emailController, // Le enchufo el microfono
                      hint: "ejemplo@befitreal.com",
                      icon: Icons.alternate_email_rounded,
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 20),

                    // Password
                    _buildLabel("CONTRASEÑA", primaryColor),
                    const SizedBox(height: 8),
                    _buildGlassInput(
                      controller: _passwordController, // Le enchufo el microfono
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      primaryColor: primaryColor,
                      isPassword: true, // Modo secreto activado
                    ),

                    // Enlace Olvidé Contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "¿HAS OLVIDADO LA CONTRASEÑA?",
                          style: GoogleFonts.teko(
                            color: Colors.white54, fontSize: 16, letterSpacing: 1),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // C. BOTÓN DE ACCIÓN (Con lógica condicional)
                    // AQUÍ ESTÁ EL TRUCO VISUAL:
                    // Si _isLoading es verdad -> Muestro ruedita.
                    // Si es falso -> Muestro botón.
                    _isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : ElevatedButton(
                            onPressed: _attemptLogin, // Al pulsar, ejecuto mi lógica
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text(
                              "INICIAR SESIÓN",
                              style: GoogleFonts.teko(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                          ),

                    const SizedBox(height: 16),

                    // Botón Registro
                    OutlinedButton(
                      onPressed: () {
                        // NAVEGACIÓN: Ir a la pantalla de registro
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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

  // --- MIS WIDGETS AUXILIARES ---
  // Los saco fuera del build principal para que el código sea más legible.
  
  // 1. Etiqueta de texto verde encima de los inputs
  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.teko(
          color: color, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2),
    );
  }

  // 2. Input personalizado con efecto cristal (Glassmorphism)
  // ARREGLO VISUAL: Aquí es donde evité el conflicto de bordes.
  Widget _buildGlassInput({
    required TextEditingController controller, // Necesario para leer el texto
    required String hint,
    required IconData icon,
    required Color primaryColor,
    bool isPassword = false,
  }) {
    // Uso TextFormField directamente (sin Container envolvente) para evitar dobles bordes.
    return TextFormField(
      controller: controller, // Conecto el controlador
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white), // Texto blanco al escribir
      
      decoration: InputDecoration(
        // SOBREESCRIBO EL TEMA GLOBAL:
        // El tema global (theme.dart) pone un fondo gris oscuro.
        // Aquí le digo: "No, usa este blanco transparente (Cristal)".
        filled: true,
        fillColor: Colors.white.withAlpha(25), 
        
        // BORDES:
        // Defino todos los bordes con el MISMO radio (12) para que al pulsar
        // no haya un "salto" visual entre el borde de reposo y el de foco.
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(30), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2), // Verde al pulsar
        ),
        
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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