import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../models/material_model.dart';

/// PANTALLA: MaterialsAdminScreen (Gestión de Equipamiento)
///
/// Interfaz exclusiva para administradores que permite realizar operaciones 
/// CRUD (Crear, Leer, Eliminar) sobre la colección de materiales del gimnasio.
/// Elección de implementación: Utiliza un [StreamBuilder] para reflejar 
/// instantáneamente cualquier adición o eliminación en la base de datos sin 
/// necesidad de recargar la vista manualmente.
class MaterialsAdminScreen extends StatefulWidget {
  const MaterialsAdminScreen({super.key});

  @override
  State<MaterialsAdminScreen> createState() => _MaterialsAdminScreenState();
}

class _MaterialsAdminScreenState extends State<MaterialsAdminScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _nameController = TextEditingController();

  /// Método Privado: Cuadro de Diálogo para Adición
  /// 
  /// Despliega un formulario modal para registrar nuevo equipamiento.
  /// Incluye validación local para evitar la inyección de cadenas vacías 
  /// o compuestas únicamente por espacios en blanco en la base de datos.
  void _showAddDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("NUEVO MATERIAL", style: TextStyle(fontFamily: 'Teko', color: Theme.of(context).primaryColor, fontSize: 28)),
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
              // Validación Defensiva: Evita guardar "   " (espacios vacíos)
              if (_nameController.text.trim().isNotEmpty) {
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

  /// Método Privado: Confirmación de Borrado Segura
  /// 
  /// Previene la eliminación accidental de registros en la base de datos.
  /// Altera el flujo normal forzando al usuario a ratificar su decisión 
  /// destructiva mediante una alerta modal.
  void _confirmDelete(BuildContext context, MaterialModel material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("¿BORRAR MATERIAL?", 
          style: TextStyle(fontFamily: 'Teko', color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
        content: Text(
          "Vas a eliminar '${material.name}' de la base de datos. Esta acción no se puede deshacer.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              // Ejecución de la operación destructiva asíncrona
              _dbService.deleteMaterial(material.id);
              Navigator.pop(ctx); 
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
        title: const Text("GESTIONAR MATERIALES", style: TextStyle(fontFamily: 'Teko', color: Colors.white, fontSize: 28)),
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
                  title: Text(material.name, style: const TextStyle(fontFamily: 'Teko', color: Colors.white, fontSize: 22)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
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