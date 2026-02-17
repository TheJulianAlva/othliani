import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_agencia.dart';
import 'package:frontend/presentation_agencia/viewmodels/search_result.dart';
import 'package:frontend/features/agencia/shared/data/datasources/mock_agencia_datasource.dart';
import 'package:frontend/features/agencia/shared/domain/entities/alerta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/shared/blocs/sync/sync_bloc.dart';

class AgencyHeader extends StatefulWidget {
  final VoidCallback onMenuPressed;
  final bool isSidebarCollapsed;

  const AgencyHeader({
    super.key,
    required this.onMenuPressed,
    required this.isSidebarCollapsed,
  });

  @override
  State<AgencyHeader> createState() => _AgencyHeaderState();
}

class _AgencyHeaderState extends State<AgencyHeader> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  List<Alerta> _recentAlertas = [];

  // Filtros de tipo
  final Set<SearchResultType> _selectedFilters = {
    SearchResultType.guide,
    SearchResultType.tourist,
    SearchResultType.trip,
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    _loadRecentAlertas();
  }

  Future<void> _loadRecentAlertas() async {
    final alertas = await MockAgenciaDataSource().getRecentAlertas(limit: 3);
    setState(() {
      _recentAlertas = alertas;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text;

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      // Mostrar filtros incluso sin resultados
      if (_searchFocusNode.hasFocus) {
        _showOverlay();
      }
      return;
    }

    // Limpiar resultados anteriores ANTES de buscar
    setState(() {
      _searchResults = [];
      _isSearching = true;
    });

    // NO mostrar overlay aquí - esperar a que lleguen los resultados

    // Buscar en MockDatabase
    final results = await MockAgenciaDataSource().searchAll(query);

    // Convertir a SearchResult
    final searchResults =
        results.map((data) {
          final type = data['type'] as String;
          if (type == 'guide') {
            return SearchResult.guide(
              id: data['id'],
              name: data['nombre'],
              status: data['status'],
              viajesAsignados: data['viajesAsignados'],
              viajeEstado: data['viajeEstado'], // Pasar estado del viaje
            );
          } else if (type == 'tourist') {
            return SearchResult.tourist(
              id: data['id'],
              name: data['nombre'],
              viajeId: data['viajeId'],
              status: data['status'],
            );
          } else {
            return SearchResult.trip(
              id: data['id'],
              destino: data['destino'],
              estado: data['estado'],
              turistas: data['turistas'],
            );
          }
        }).toList();

    setState(() {
      _searchResults = searchResults;
      _isSearching = false;
    });

    // AHORA SÍ mostrar overlay con los resultados correctos
    if (_searchFocusNode.hasFocus) {
      _showOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      // NO cerrar automáticamente - solo cerrar cuando se hace click fuera
      // El delay causaba que el scroll cerrara el overlay
      return;
    } else {
      // Mostrar overlay al obtener foco (con o sin resultados)
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // Barrera invisible para detectar clicks fuera del overlay
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    // Click fuera del overlay - cerrarlo
                    _removeOverlay();
                  },
                  behavior: HitTestBehavior.translucent,
                ),
              ),
              // El overlay real
              Positioned(
                width: 350,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 45),
                  child: Listener(
                    onPointerDown: (_) {
                      // Capturar todos los eventos de puntero (incluyendo scroll)
                      // para evitar que se pierda el foco
                      _searchFocusNode.requestFocus();
                    },
                    child: GestureDetector(
                      onTap: () {
                        // Absorber clicks para evitar que se cierre el overlay
                        // Mantener el foco en el campo de búsqueda
                        _searchFocusNode.requestFocus();
                      },
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: StatefulBuilder(
                          builder: (context, setOverlayState) {
                            return Container(
                              constraints: const BoxConstraints(maxHeight: 450),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Filtros de tipo
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Filtrar:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterChip(
                                          'Viajes',
                                          SearchResultType.trip,
                                          Icons.directions_bus,
                                          Colors.orange,
                                          setOverlayState,
                                        ),
                                        const SizedBox(width: 6),
                                        _buildFilterChip(
                                          'Guías',
                                          SearchResultType.guide,
                                          Icons.person_pin,
                                          Colors.blue,
                                          setOverlayState,
                                        ),
                                        const SizedBox(width: 6),
                                        _buildFilterChip(
                                          'Turistas',
                                          SearchResultType.tourist,
                                          Icons.person,
                                          Colors.green,
                                          setOverlayState,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  // Resultados filtrados
                                  Flexible(child: _buildFilteredResults()),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onResultSelected(SearchResult result) {
    _searchController.clear();
    _removeOverlay();
    _searchFocusNode.unfocus();
    _navigateToResult(result);
  }

  void _navigateToResult(SearchResult result) {
    switch (result.type) {
      case SearchResultType.guide:
        context.go('/usuarios?tab=guias&search=${result.name}');
        break;
      case SearchResultType.tourist:
        context.go('/usuarios?tab=clientes&search=${result.name}');
        break;
      case SearchResultType.trip:
        context.push('/viajes/${result.id}');
        break;
    }
  }

  Widget _buildFilterChip(
    String label,
    SearchResultType type,
    IconData icon,
    Color color,
    StateSetter setOverlayState,
  ) {
    final isSelected = _selectedFilters.contains(type);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Mantener el foco para evitar que se cierre
          _searchFocusNode.requestFocus();

          // Actualizar estado del widget principal
          setState(() {
            if (isSelected) {
              _selectedFilters.remove(type);
            } else {
              _selectedFilters.add(type);
            }
          });

          // Actualizar estado del overlay SIN reconstruirlo
          setOverlayState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredResults() {
    // Si no hay búsqueda activa, mostrar mensaje
    if (_searchController.text.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Escribe para buscar',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'guías, turistas o viajes',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final filteredResults =
        _searchResults
            .where((result) => _selectedFilters.contains(result.type))
            .toList();

    if (filteredResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'No hay resultados',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Intenta con otros filtros',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) {
        // Mantener foco al entrar en la lista
        _searchFocusNode.requestFocus();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: filteredResults.length,
        itemBuilder: (context, index) {
          final result = filteredResults[index];
          return _buildSearchResultItem(result);
        },
      ),
    );
  }

  Widget _buildSearchResultItem(SearchResult result) {
    return InkWell(
      onTap: () => _onResultSelected(result),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Icono con color según tipo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: result.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(result.icon, color: result.color, size: 20),
            ),
            const SizedBox(width: 12),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge de tipo
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: result.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          result.typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: result.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final segments = currentPath.split('/').where((s) => s.isNotEmpty).toList();
    String matchingPath = '';

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de menú (hamburguesa)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: widget.onMenuPressed,
            tooltip: 'Menú',
          ),

          const SizedBox(width: 16),

          // Breadcrumbs
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.go(RoutesAgencia.dashboard),
                    borderRadius: BorderRadius.circular(4),
                    hoverColor: Colors.grey.shade100,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Inicio',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                  for (var i = 0; i < segments.length; i++) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) {
                        final segment = segments[i];
                        matchingPath += '/$segment';
                        final isLast = i == segments.length - 1;
                        final targetPath = matchingPath;
                        final displaySegment = segment.split('?')[0];

                        return InkWell(
                          onTap: isLast ? null : () => context.go(targetPath),
                          borderRadius: BorderRadius.circular(4),
                          hoverColor: isLast ? null : Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              _capitalize(displaySegment),
                              style: TextStyle(
                                color: isLast ? Colors.black : Colors.grey,
                                fontSize: 13,
                                fontWeight:
                                    isLast
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(),

          // --- ÍCONO DE ESTATUS REAL (CONNECTIVITY PLUS) ---
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getSyncBgColor(state.status),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getSyncColor(state.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    state.status == SyncStatus.syncing
                        ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _getSyncColor(state.status),
                          ),
                        )
                        : Icon(
                          _getSyncIcon(state.status),
                          size: 18,
                          color: _getSyncColor(state.status),
                        ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.status == SyncStatus.offline
                              ? "SIN CONEXIÓN"
                              : "CONECTADO",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: _getSyncColor(state.status),
                          ),
                        ),
                        Text(
                          state.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),

          // --- BUSCADOR GLOBAL CON OVERLAY MANUAL ---
          CompositedTransformTarget(
            link: _layerLink,
            child: SizedBox(
              width: 350,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar guía, turista o destino...',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey,
                  ),
                  suffixIcon:
                      _isSearching
                          ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // --- CAMPANITA DE NOTIFICACIONES ---
          PopupMenuButton<void>(
            offset: const Offset(0, 50),
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.black87,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'Notificaciones Recientes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Generar items dinámicamente desde _recentAlertas
                  ..._recentAlertas.map((alerta) {
                    return PopupMenuItem(
                      onTap: () {
                        // Usar Future.microtask para navegar después de que el popup se cierre
                        Future.microtask(() {
                          if (mounted) {
                            // Navegación inteligente con resaltado contextual
                            // Si la alerta tiene turistaId, resaltar ese turista
                            final focusParam =
                                alerta.turistaId != null
                                    ? '?alert_focus=${alerta.turistaId}&return_to=dashboard'
                                    : '?return_to=dashboard';

                            // ignore: use_build_context_synchronously
                            context.go('/viajes/${alerta.viajeId}$focusParam');
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getAlertColor(alerta),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alerta.mensaje,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  _getTimeAgo(alerta.hora),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () => context.go('/auditoria'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver todas',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  // Helper: Get color based on alert type
  Color _getAlertColor(Alerta alerta) {
    if (alerta.esCritica || alerta.tipo == 'PANICO') {
      return Colors.red;
    } else if (alerta.tipo == 'BATERIA_BAJA') {
      return Colors.orange[700]!;
    } else if (alerta.tipo == 'LEJANIA') {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  // Helper: Format time ago
  String _getTimeAgo(DateTime hora) {
    final now = DateTime.now();
    final difference = now.difference(hora);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} d';
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Helpers visuales para Sync
  Color _getSyncColor(SyncStatus s) {
    if (s == SyncStatus.online) return Colors.green[700]!;
    if (s == SyncStatus.syncing) return Colors.blue[700]!;
    return Colors.orange[800]!;
  }

  Color _getSyncBgColor(SyncStatus s) {
    if (s == SyncStatus.online) return Colors.green[50]!;
    if (s == SyncStatus.syncing) return Colors.blue[50]!;
    return Colors.orange[50]!;
  }

  IconData _getSyncIcon(SyncStatus s) {
    if (s == SyncStatus.online) return Icons.cloud_done;
    if (s == SyncStatus.offline) return Icons.cloud_off;
    return Icons.sync;
  }
}
