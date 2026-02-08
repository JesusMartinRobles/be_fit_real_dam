import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar al portapapeles
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para generar aleatorios
import '../services/database_service.dart';
import '../models/invite_code_model.dart';


class InviteCodesScreen extends StatefulWidget {
  const InviteCodesScreen({super.key});

  @override
  State<InviteCodesScreen> createState() => _InviteCodesScreenState();
}

class _InviteCodesScreenState extends State<InviteCodesScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _codeController = TextEditingController();

  // GENERADOR ALEATORIO
  // Crea un string tipo "BFR-X92Z"
  void _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    // Genero 6 caracteres al azar
    String randomString = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    
    // Lo pongo en el campo de texto
    _codeController.text = "BFR-$randomString";
  }

  // DIÁLOGO PARA CREAR
  void _showAddDialog() {
    _codeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("NUEVO CÓDIGO", style: GoogleFonts.teko(color: Theme.of(context).primaryColor, fontSize: 28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "Ej: VIP_2026",
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFAAD816))),
              ),
            ),
            const SizedBox(height: 10),
            // BOTÓN DE "GENERAR ALEATORIO"
            TextButton.icon(
              onPressed: _generateRandomCode,
              icon: const Icon(Icons.shuffle, color: Colors.cyanAccent),
              label: const Text("GENERAR AUTOMÁTICO", style: TextStyle(color: Colors.cyanAccent)),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (_codeController.text.isNotEmpty) {
                // Guardo el código en mayúsculas para evitar líos
                _dbService.addInviteCode(_codeController.text.trim().toUpperCase());
                Navigator.pop(context);
              }
            },
            child: Text("GUARDAR", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // COPIAR AL PORTAPAPELES
  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copiado: $code"), duration: const Duration(seconds: 1)),
    );
  }

  // BORRAR CÓDIGO
  void _deleteCode(String id) {
    _dbService.deleteInviteCode(id);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("CÓDIGOS DE ACCESO", style: GoogleFonts.teko(color: Colors.white, fontSize: 24)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.purpleAccent, // Morado para diferenciarlo
        child: const Icon(Icons.vpn_key, color: Colors.black),
      ),

      body: StreamBuilder<List<InviteCodeModel>>(
        stream: _dbService.getInviteCodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay códigos creados.", style: TextStyle(color: Colors.white.withAlpha(100))));
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
                  border: Border.all(color: Colors.purpleAccent.withAlpha(50)), // Borde moradito
                ),
                child: ListTile(
                  // Al pulsar, se copia
                  onTap: () => _copyToClipboard(codeItem.code),
                  leading: const Icon(Icons.confirmation_number, color: Colors.purpleAccent),
                  title: Text(
                    codeItem.code, 
                    style: GoogleFonts.teko(color: Colors.white, fontSize: 24, letterSpacing: 2),
                  ),
                  subtitle: Text(
                    "Creado: ${codeItem.createdAt.day}/${codeItem.createdAt.month}/${codeItem.createdAt.year}",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deleteCode(codeItem.id),
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