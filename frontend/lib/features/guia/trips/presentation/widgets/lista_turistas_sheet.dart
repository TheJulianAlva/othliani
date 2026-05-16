import 'package:flutter/material.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

class ListaTuristasSheet extends StatefulWidget {
  final List<Turista> turistas;

  const ListaTuristasSheet({super.key, required this.turistas});

  @override
  State<ListaTuristasSheet> createState() => _ListaTuristasSheetState();
}

class _ListaTuristasSheetState extends State<ListaTuristasSheet> {
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
      _turistasFiltrados =
          _todosLosTuristas.where((t) {
            return t.nombre.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
      height:
          MediaQuery.of(context).size.height * 0.75 +
          (bottomInset > 0 ? bottomInset / 2 : 0),
      child: Column(
        children: [
          Text(
            "Gestión de Grupo (${_todosLosTuristas.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          _buildBuscador(),
          const Divider(height: 24),
          Expanded(child: _buildListaTuristas()),
          SafeArea(child: _buildBotonAnadirTurista()),
        ],
      ),
    );
  }

  Widget _buildBuscador() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar turista...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildListaTuristas() {
    if (_turistasFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron turistas',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _turistasFiltrados.length,
      itemBuilder: (context, index) {
        final turista = _turistasFiltrados[index];
        final esCritico = turista.vulnerabilidad == NivelVulnerabilidad.critica;

        return Dismissible(
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
                SnackBar(
                  content: Text('Editar a ${turista.nombre} (Próximamente)'),
                ),
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 8,
            ),
            leading: CircleAvatar(
              backgroundColor:
                  esCritico ? Colors.red.shade50 : const Color(0xFFE8F5E9),
              child: Icon(
                esCritico ? Icons.warning_rounded : Icons.person,
                color: esCritico ? Colors.red : const Color(0xFF00AE00),
              ),
            ),
            title: Text(
              turista.nombre,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotonAnadirTurista() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      child: ElevatedButton.icon(
        onPressed: () {
          // Lógica para añadir turista
        },
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Añadir Turista',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00AE00),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Helpers para Dismissible
  Widget _buildBackground(Alignment align, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion(
    BuildContext context,
    String nombre,
  ) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('¿Eliminar turista?'),
            content: Text('Esto quitará a "$nombre" de la lista del viaje.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCELAR'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade200,
                ),
                child: const Text(
                  'ELIMINAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
