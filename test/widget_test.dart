import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importamos nuestros widgets personalizados
import 'package:be_fit_real/widgets/custom_widgets.dart';

/// PRUEBA DE INTEGRACIÓN DE UI (WIDGET TEST)
/// Mecanismo: Instancia un entorno virtual de Flutter (WidgetTester) sin lanzar 
/// un emulador real. Se montan varios componentes visuales juntos para comprobar 
/// que se comunican correctamente entre ellos y con el teclado del usuario.
void main() {
  testWidgets('Prueba de Integración: Componentes Formulario (BeFitLabel y GlassTextField)', (WidgetTester tester) async {
    
    // 1. ENTRADAS FACILITADAS: Preparamos un controlador y montamos el árbol de UI
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const BeFitLabel("CORREO DE PRUEBA"),
              GlassTextField(
                controller: controller,
                hint: "Escribe aquí",
                icon: Icons.email,
              ),
            ],
          ),
        ),
      ),
    );

    // 2. SALIDAS ESPERADAS (Fase Visual): Comprobamos que el motor ha dibujado todo
    expect(find.text("CORREO DE PRUEBA"), findsOneWidget, reason: 'El BeFitLabel debe renderizarse');
    expect(find.byType(GlassTextField), findsOneWidget, reason: 'El input de cristal debe existir');
    expect(find.byIcon(Icons.email), findsOneWidget, reason: 'El icono de email debe mostrarse');

    // 3. INTEGRACIÓN DINÁMICA: Simulamos al usuario escribiendo en el teclado
    await tester.enterText(find.byType(GlassTextField), 'profesor@dam.com');
    
    // 4. SALIDAS ESPERADAS (Fase Lógica): El controlador debe haber capturado el texto de la UI
    expect(controller.text, 'profesor@dam.com', reason: 'El controlador debe sincronizarse con el input del usuario');
  });
}