import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../models/material_model.dart';

// PANTALLA DE GESTIÓN DE MATERIALES
class MaterialsAdminScreen extends StatefulWidget {
  const MaterialsAdminScreen({super.key});

  @override
  State<MaterialsAdminScreen> createState() => _MaterialsAdminScreenState();
}

class _MaterialsAdminScreenState extends State<MaterialsAdminScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _nameController = TextEditingController();

  // MÉTODO: AÑADIR (Diálogo)
  void _showAddDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("NUEVO MATERIAL", style: GoogleFonts.teko(color: Theme.of(context).primaryColor, fontSize: 28)),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Ej: Barra Olímpica",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFAAD816))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                _dbService.addMaterial(_nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text("GUARDAR", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // MÉTODO NUEVO: CONFIRMAR BORRADO
  // Antes de borrar, pregunto. Es asíncrono porque espero a que el usuario pulse.
  void _confirmDelete(BuildContext context, MaterialModel material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("¿BORRAR MATERIAL?", 
          style: GoogleFonts.teko(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
        content: Text(
          "Vas a eliminar '${material.name}' de la base de datos. Esta acción no se puede deshacer.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cerrar sin hacer nada
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              // AQUÍ ES DONDE OCURRE EL BORRADO REAL
              _dbService.deleteMaterial(material.id);
              Navigator.pop(ctx); // Cierro la alerta
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
        title: Text("GESTIONAR MATERIALES", style: GoogleFonts.teko(color: Colors.white, fontSize: 28)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: StreamBuilder<List<MaterialModel>>(
        stream: _dbService.getMaterials(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay materiales definidos.", style: TextStyle(color: Colors.white.withAlpha(100))));
          }

          final materials = snapshot.data!;
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final material = materials[index];
              
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: ListTile(
                  leading: Icon(Icons.fitness_center, color: primaryColor),
                  title: Text(material.name, style: GoogleFonts.teko(color: Colors.white, fontSize: 22)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      // CAMBIO: Ahora llamo a mi función de seguridad en vez de borrar directo
                      _confirmDelete(context, material);
                    },
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