import 'dart:async'; // Para el Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/viajes/viajes_bloc.dart';
import '../widgets/trips/trips_datagrid.dart'; // Tu tabla existente

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  // Controladores de estado local para la UI
  String _searchQuery = '';
  String _selectedStatus = 'TODOS';
  String _searchField = 'TODO'; // 'TODO', 'GUIA', 'DESTINO', 'ID'
  Timer? _debounce; // Para esperar a que el usuario termine de escribir

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Método centralizado para disparar el evento
  void _applyFilters() {
    context.read<ViajesBloc>().add(
      LoadViajesEvent(
        query: _searchQuery,
        filterStatus: _selectedStatus,
        field: _searchField,
        // filterDate: _selectedDate,
      ),
    );
  }

  String _getSearchHint() {
    switch (_searchField) {
      case 'GUIA':
        return 'Buscar por nombre de guía...';
      case 'DESTINO':
        return 'Buscar por destino...';
      case 'ID':
        return 'Buscar por folio...';
      default:
        return 'Buscar por destino, ID o guía...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. BARRA DE HERRAMIENTAS ---
            _buildToolbar(),

            const SizedBox(height: 16),

            // --- 2. TABLA DE RESULTADOS ---
            Expanded(
              child: BlocBuilder<ViajesBloc, ViajesState>(
                builder: (context, state) {
                  if (state is ViajesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ViajesLoaded) {
                    if (state.viajes.isEmpty) {
                      return _buildEmptyState();
                    }
                    // Pasamos la lista filtrada a tu widget de tabla
                    return TripsDatagrid(viajes: state.viajes);
                  } else if (state is ViajesError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA SUPERIOR: CRITERIO + BUSCADOR + FECHA + CREAR
          Row(
            children: [
              // 1. Selector Criterio + Buscador (Expanded)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Dropdown Criterio (Integrado visualmente)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _searchField,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: Colors.grey,
                            ),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'TODO',
                                child: Text('General'),
                              ),
                              DropdownMenuItem(
                                value: 'GUIA',
                                child: Text('Guía'),
                              ),
                              DropdownMenuItem(
                                value: 'DESTINO',
                                child: Text('Destino'),
                              ),
                              DropdownMenuItem(
                                value: 'ID',
                                child: Text('Folio'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _searchField = val);
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ),

                      // Input Texto
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            hintText: _getSearchHint(),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false)
                              _debounce!.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                _searchQuery = value;
                                _applyFilters();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 2. Botón Fecha
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text("Filtrar Fecha"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Fecha seleccionada: ${picked.toString()}",
                        ),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(width: 16),

              // 3. Botón Crear Viaje
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Nuevo Viaje"),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE96E50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "🚀 Funcionalidad de 'Crear Viaje' en desarrollo",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // FILA INFERIOR: CHIPS DE ESTATUS
          Row(
            children: [
              const Text(
                "Estatus:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterChip('Todos', Colors.grey[800]!, 'TODOS'),
              const SizedBox(width: 8),
              _buildFilterChip('En Curso', Colors.green, 'EN_CURSO'),
              const SizedBox(width: 8),
              _buildFilterChip('Programados', Colors.blue, 'PROGRAMADO'),
              const SizedBox(width: 8),
              _buildFilterChip('Finalizados', Colors.grey, 'FINALIZADO'),

              const Spacer(),

              // Botón Reset (Solo visible si hay filtros activos)
              if (_selectedStatus != 'TODOS' ||
                  _searchQuery.isNotEmpty ||
                  _searchField != 'TODO')
                TextButton.icon(
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text("Limpiar Filtros"),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchQuery =
                          ''; // Nota: necesitas un controller si quieres limpiar el input visualmente
                      _selectedStatus = 'TODOS';
                      _searchField = 'TODO';
                    });
                    _applyFilters();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, String value) {
    final bool isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedStatus = selected ? value : 'TODOS';
        });
        _applyFilters();
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.transparent : color.withOpacity(0.3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No se encontraron viajes con esos filtros.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
