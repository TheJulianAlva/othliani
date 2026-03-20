import 'package:flutter/material.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

class GestionTuristasScreen extends StatefulWidget {
  final List<Turista> turistas;
  final VoidCallback onVolver;

  const GestionTuristasScreen({super.key, required this.turistas, required this.onVolver});

  @override
  State<GestionTuristasScreen> createState() => _GestionTuristasScreenState();
}

class _GestionTuristasScreenState extends State<GestionTuristasScreen> {
  late List<Turista> _todosLosTuristas;
  List<Turista> _turistasFiltrados = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _todosLosTuristas = List.from(widget.turistas);
    _turistasFiltrados = List.from(_todosLosTuristas);
    _searchController.addListener(_filtrarTuristas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarTuristas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _turistasFiltrados = _todosLosTuristas.where((t) {
        return t.nombre.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Lista de Turistas (${_todosLosTuristas.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: widget.onVolver,
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda con diseño moderno
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildBuscador(),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // Lista de turistas
          Expanded(
            child: _buildListaTuristas(),
          ),
          // Botón de añadir
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBotonAnadirTurista(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscador() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar turista...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.cancel_rounded, color: Colors.grey.shade400, size: 20),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildListaTuristas() {
    if (_turistasFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No se encontraron coincidencias',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _turistasFiltrados.length,
      itemBuilder: (context, index) {
        final turista = _turistasFiltrados[index];
        final esCritico = turista.vulnerabilidad == NivelVulnerabilidad.critica;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey(turista.id),
            direction: DismissDirection.horizontal,
            background: _buildBackground(
              Alignment.centerLeft,
              Colors.redAccent.shade100,
              Icons.delete_sweep_rounded,
            ),
            secondaryBackground: _buildBackground(
              Alignment.centerRight,
              Colors.blueGrey.shade400,
              Icons.edit_note_rounded,
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                return await _mostrarDialogoConfirmacion(context, turista.nombre);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editar a ${turista.nombre} (Próximamente)')),
                );
                return false;
              }
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                setState(() {
                  _todosLosTuristas.removeWhere((t) => t.id == turista.id);
                  _filtrarTuristas();
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade50),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: esCritico ? Colors.red.shade50 : const Color(0xFFF0FDF4),
                  child: Icon(
                    esCritico ? Icons.priority_high_rounded : Icons.person_rounded,
                    color: esCritico ? Colors.red : const Color(0xFF00AE00),
                    size: 24,
                  ),
                ),
                title: Text(
                  turista.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotonAnadirTurista() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF00AE00), Color(0xFF008900)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00AE00).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'Añadir Turista',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildBackground(Alignment align, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context, String nombre) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Eliminar turista?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Esta acción quitará a $nombre del monitoreo activo del viaje.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
