import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importación de componentes bajo prueba (System Under Test)
import 'package:be_fit_real/widgets/custom_widgets.dart';

/// PRUEBA DE INTEGRACIÓN DE UI: Componentes de Formulario
///
/// Mecanismo: Se utiliza [WidgetTester] para instanciar un entorno de renderizado
/// virtual. Esta prueba valida la jerarquía del árbol de widgets y la integridad
/// de los datos durante la interacción del usuario.
///
/// Objetivos de Calidad:
/// 1. Verificar el renderizado correcto de widgets personalizados ([BeFitLabel]).
/// 2. Validar la bidireccionalidad de datos entre la UI ([GlassTextField])
///    y su controlador lógico ([TextEditingController]).
void main() {
  testWidgets(
      'Integración UI: Validación de sincronización Label-Input-Controller',
      (WidgetTester tester) async {
    // --- FASE 1: ARRANGE (Preparación del entorno) ---
    // Instanciamos el controlador que servirá como fuente de verdad lógica.
    final controller = TextEditingController();

    // Montamos el árbol de widgets dentro de un entorno MaterialApp para
    // heredar los estilos de texto y temas necesarios.
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

    // --- FASE 2: ASSERT (Verificación estática) ---
    // Comprobamos que los elementos críticos han sido dibujados en el árbol.
    expect(find.text("CORREO DE PRUEBA"), findsOneWidget,
        reason: 'El componente BeFitLabel debe ser visible para el usuario.');

    expect(find.byType(GlassTextField), findsOneWidget,
        reason:
            'El componente GlassTextField debe estar instanciado en el árbol.');

    expect(find.byIcon(Icons.email), findsOneWidget,
        reason: 'El glifo decorativo (Icon) debe renderizarse correctamente.');

    // --- FASE 3: ACT (Interacción simulada) ---
    // Simulamos la entrada de texto por parte de un usuario final.
    await tester.enterText(find.byType(GlassTextField), 'profesor@dam.com');

    // Forzamos al motor a procesar los cambios de estado (Rebuild)
    await tester.pump();

    // --- FASE 4: ASSERT (Verificación dinámica) ---
    // Validamos que el flujo de datos (Data Binding) entre el widget
    // y el controlador es íntegro y no presenta fugas ni retrasos.
    expect(controller.text, 'profesor@dam.com',
        reason:
            'El controlador lógico debe reflejar inmediatamente el valor introducido en la UI.');
  });
}
