import 'package:flutter/material.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

/// Tab embebido de gestión de turistas (compacto, sin Scaffold propio).
/// Incluye búsqueda y swipe para editar/eliminar.
class GrupoTuristasTab extends StatefulWidget {
  final List<Turista> turistas;

  const GrupoTuristasTab({super.key, required this.turistas});

  @override
  State<GrupoTuristasTab> createState() => _GrupoTuristasTabState();
}

class _GrupoTuristasTabState extends State<GrupoTuristasTab> {
  late List<Turista> _todos;
  List<Turista> _filtrados = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _todos = List.from(widget.turistas);
    _filtrados = List.from(_todos);
    _searchCtrl.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filtrar() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtrados = _todos.where((t) => t.nombre.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No hay turistas registrados',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Usa el botón + para añadir uno',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Buscador compacto ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar turista...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade400),
                      onPressed: () {
                        _searchCtrl.clear();
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // ── Contador ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${_filtrados.length} turista${_filtrados.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ── Lista ──
        Expanded(
          child: _filtrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Sin coincidencias',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _filtrados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) => _TuristaTile(
                    turista: _filtrados[i],
                    onEliminar: () => _eliminar(_filtrados[i]),
                  ),
                ),
        ),
      ],
    );
  }

  void _eliminar(Turista turista) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar turista?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Se quitará a ${turista.nombre} del monitoreo activo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _todos.removeWhere((t) => t.id == turista.id);
        _filtrar();
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget compacto para cada turista con swipe
// ─────────────────────────────────────────────────────────────────────────────
class _TuristaTile extends StatelessWidget {
  final Turista turista;
  final VoidCallback onEliminar;

  const _TuristaTile({required this.turista, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final esCritico = turista.vulnerabilidad == NivelVulnerabilidad.critica;

    return Dismissible(
      key: ValueKey(turista.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
      ),
      confirmDismiss: (_) async {
        onEliminar();
        return false; // El diálogo maneja la eliminación
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: esCritico ? Colors.red.shade50 : const Color(0xFFF0FDF4),
              child: Icon(
                esCritico ? Icons.priority_high_rounded : Icons.person_rounded,
                color: esCritico ? Colors.red : const Color(0xFF00AE00),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                turista.nombre,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (esCritico)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Prioritario',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
