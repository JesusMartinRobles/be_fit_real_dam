import 'package:flutter/material.dart';

void main() {
  runApp(const BeFitRealApp());
}

class BeFitRealApp extends StatelessWidget {
  const BeFitRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be Fit Real',
      debugShowCheckedModeBanner: false, // Quita la etiqueta "Debug" de la esquina
      theme: ThemeData(
        // Aquí definiremos tus colores corporativos más adelante
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Be Fit Real\nInicializando...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}