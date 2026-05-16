import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/trips/presentation/blocs/viajes/viajes_bloc.dart';
import '../../domain/entities/viaje.dart';

import '../widgets/master_trip_list.dart';
import '../widgets/quick_detail_card.dart';
import '../widgets/full_detail_grid.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  final Set<String> _selectedStatuses = {'TODOS'};
  DateTimeRange? _selectedDateRange;
  Timer? _debounce;
  
  Viaje? _selectedViaje; // Viaje seleccionado en la master list

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ViajesBloc>().add(
      LoadViajesEvent(
        query: _searchQuery,
        filterStatuses: _selectedStatuses.toList(),
        field: 'TODO', // General search
        filterDateRange: _selectedDateRange,
      ),
    );
  }
  
  void _onViajeSelected(Viaje viaje) {
    setState(() {
      _selectedViaje = viaje;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PARTE SUPERIOR: Header y Master-Detail ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO
                  const Text(
                    "Viajes y Operaciones",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF004A75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Gestión rápida mediante Master-Detail View. Clic en un viaje sin salir de la lista.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  
                  // TOOLBAR (Filtros visualmente fieles a la maqueta)
                  _buildToolbar(),
                  const SizedBox(height: 24),
                  
                  // MASTER - DETAIL LAYOUT
                  SizedBox(
                    height: 550, // Altura fija para no explotar el scroll
                    child: BlocBuilder<ViajesBloc, ViajesState>(
                      builder: (context, state) {
                        if (state is ViajesLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ViajesLoaded) {
                          if (state.viajes.isEmpty) {
                            return const Center(child: Text("No se encontraron viajes."));
                          }
                          
                          // Autoseleccionar el primero si no hay selección
                          if (_selectedViaje == null || !state.viajes.any((v) => v.id == _selectedViaje!.id)) {
                            // Usamos Future.microtask para evitar llamar setState durante el build
                            Future.microtask(() => setState(() {
                              _selectedViaje = state.viajes.first;
                            }));
                          }
                          
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // LISTA MASTER (Izquierda)
                              Expanded(
                                flex: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: MasterTripList(
                                    viajes: state.viajes,
                                    selectedViajeId: _selectedViaje?.id,
                                    onViajeSelected: _onViajeSelected,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              // QUICK DETAIL (Derecha)
                              Expanded(
                                flex: 4,
                                child: _selectedViaje != null
                                  ? QuickDetailCard(
                                      viaje: _selectedViaje!,
                                      onAbrirPantallaCompleta: _scrollToBottom,
                                    )
                                  : const Center(child: Text("Seleccione un viaje")),
                              ),
                            ],
                          );
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
            
            // Separador visual
            Container(height: 8, color: Colors.grey.shade300),
            
            // --- PARTE INFERIOR: Pantalla Completa del Detalle ---
            if (_selectedViaje != null)
              FullDetailGrid(viaje: _selectedViaje!),
              
            const SizedBox(height: 48), // Padding inferior
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text("ESTATUS:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 12),
          _buildPill("Todos", true, null),
          const SizedBox(width: 8),
          _buildPill("En Curso", false, 4),
          const SizedBox(width: 8),
          _buildPill("Programados", false, null),
          
          const Spacer(),
          
          // Search box
          Container(
            width: 250,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: InputDecoration(
                icon: const Icon(Icons.search, size: 18, color: Colors.grey),
                hintText: "Buscar folio, destino o guía...",
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _searchQuery = val;
                  _applyFilters();
                });
              },
            ),
          ),
          
          const SizedBox(width: 16),
          Container(height: 24, width: 1, color: Colors.grey.shade300),
          const SizedBox(width: 16),
          
          // Date Range
          InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => _selectedDateRange = picked);
                _applyFilters();
              }
            },
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                Text(
                  _selectedDateRange == null ? "01/Mar - 15/Mar" : "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 13),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPill(String label, bool isSelected, int? count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B3B6F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
              child: Text(count.toString(), style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ]
        ],
      ),
    );
  }
}
