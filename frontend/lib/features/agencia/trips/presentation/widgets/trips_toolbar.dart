import 'package:flutter/material.dart';
import 'new_trip_modal.dart';

class TripsToolbar extends StatefulWidget {
  const TripsToolbar({super.key});

  @override
  State<TripsToolbar> createState() => _TripsToolbarState();
}

class _TripsToolbarState extends State<TripsToolbar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Search Bar
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por Folio, Destino o Guía...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Date Filter
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text('Filtro Fecha'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),

              // Status Filter
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 16),
                label: const Text('Estatus'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 24),

              // New Trip Action (Split Button Simulation)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4C75),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _showNewTripModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: const Text(
                          'NUEVO VIAJE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.white30),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      onSelected: (value) {
                        if (value == 'new') _showNewTripModal(context);
                      },
                      itemBuilder:
                          (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'new',
                              child: Text('Crear desde Cero'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'template',
                              child: Text('Usar Plantilla Guardada'),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewTripModal(BuildContext context) {
    showDialog(context: context, builder: (context) => const NewTripModal());
  }
}
