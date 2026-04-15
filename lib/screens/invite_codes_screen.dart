import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para Clipboard
import 'dart:math';

import '../services/database_service.dart';
import '../models/invite_code_model.dart';

/// PANTALLA: InviteCodesScreen (Gestión de Códigos de Acceso)
///
/// Módulo exclusivo de administración. Permite crear, listar y eliminar
/// los códigos requeridos para el registro de nuevos usuarios en la plataforma.
/// Elección de implementación: Se utiliza [StreamBuilder] para reflejar los
/// cambios de la base de datos en tiempo real. Se incorpora funcionalidad del
/// sistema (Clipboard) para facilitar la distribución de códigos.
class InviteCodesScreen extends StatefulWidget {
  const InviteCodesScreen({super.key});

  @override
  State<InviteCodesScreen> createState() => _InviteCodesScreenState();
}

class _InviteCodesScreenState extends State<InviteCodesScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _codeController = TextEditingController();

  /// Método Privado: Generador Aleatorio de Códigos
  ///
  /// Utiliza la clase [Random] de Dart para generar una cadena alfanumérica
  /// segura de 6 caracteres, anteponiendo el prefijo corporativo "BFR-".
  void _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    String randomString =
        List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();

    _codeController.text = "BFR-$randomString";
  }

  /// Método Privado: Cuadro de Diálogo de Creación
  ///
  /// Despliega una alerta modal que permite al administrador escribir un
  /// código manual o generar uno automáticamente.
  void _showAddDialog() {
    _codeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("NUEVO CÓDIGO",
            style: TextStyle(
                fontFamily: 'Teko',
                color: Theme.of(context).primaryColor,
                fontSize: 28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "Ej: VIP_2026",
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFAAD816))),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _generateRandomCode,
              icon: const Icon(Icons.shuffle, color: Colors.cyanAccent),
              label: const Text("GENERAR AUTOMÁTICO",
                  style: TextStyle(color: Colors.cyanAccent)),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (_codeController.text.isNotEmpty) {
                // Validación: Se fuerza mayúsculas y limpieza de espacios en blanco
                // para evitar errores de coincidencia durante el registro de usuarios.
                _dbService
                    .addInviteCode(_codeController.text.trim().toUpperCase());
                Navigator.pop(context);
              }
            },
            child: Text("GUARDAR",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Método Privado: Interacción con el Portapapeles
  ///
  /// Copia el código seleccionado al portapapeles del dispositivo del usuario
  /// y muestra un [SnackBar] de confirmación visual.
  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Copiado: $code"),
          duration: const Duration(seconds: 1)),
    );
  }

  /// Método Privado: Confirmación de Borrado
  ///
  /// Previene la eliminación accidental de un código de invitación activo.
  void _confirmDelete(BuildContext context, String id, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("¿ELIMINAR CÓDIGO?",
            style: TextStyle(
                fontFamily: 'Teko',
                color: Colors.redAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        content: Text(
          "El código '$code' dejará de funcionar para nuevos registros. ¿Estás seguro?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              _dbService.deleteInviteCode(id);
              Navigator.pop(ctx);
            },
            child: const Text("ELIMINAR",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("CÓDIGOS DE ACCESO",
            style: TextStyle(
                fontFamily: 'Teko', color: Colors.white, fontSize: 24)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.vpn_key, color: Colors.black),
      ),
      body: StreamBuilder<List<InviteCodeModel>>(
        stream: _dbService.getInviteCodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text("No hay códigos creados.",
                    style: TextStyle(color: Colors.white.withAlpha(100))));
          }

          final codes = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: codes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final codeItem = codes[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purpleAccent.withAlpha(50)),
                ),
                child: ListTile(
                  onTap: () => _copyToClipboard(codeItem.code),
                  leading: const Icon(Icons.confirmation_number,
                      color: Colors.purpleAccent),
                  title: Text(
                    codeItem.code,
                    style: const TextStyle(
                        fontFamily: 'Teko',
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 2),
                  ),
                  subtitle: Text(
                    "Creado: ${codeItem.createdAt.day.toString().padLeft(2, '0')}/${codeItem.createdAt.month.toString().padLeft(2, '0')}/${codeItem.createdAt.year}",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: () =>
                        _confirmDelete(context, codeItem.id, codeItem.code),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
