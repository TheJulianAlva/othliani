import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes_agencia.dart';

class AgencyHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final bool isSidebarCollapsed;

  const AgencyHeader({
    super.key,
    required this.onMenuPressed,
    required this.isSidebarCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    // Basic Breadcrumb Logic
    final String currentPath = GoRouterState.of(context).uri.toString();
    List<String> pathSegments =
        currentPath.split('/').where((s) => s.isNotEmpty).toList();
    if (pathSegments.isEmpty) pathSegments = ['Dashboard'];

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sidebar Toggle
          IconButton(
            icon: Icon(isSidebarCollapsed ? Icons.menu_open : Icons.menu),
            onPressed: onMenuPressed,
            tooltip: 'Alternar Menú',
          ),

          const SizedBox(width: 16),

          // Breadcrumbs
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Builder(
                builder: (context) {
                  final String currentPath =
                      GoRouterState.of(context).uri.toString();
                  // Remove leading slash and split
                  final segments =
                      currentPath
                          .split('/')
                          .where((s) => s.isNotEmpty)
                          .toList();

                  String matchingPath = ''; // To build cumulative path

                  return Row(
                    children: [
                      InkWell(
                        onTap: () => context.go(RoutesAgencia.dashboard),
                        borderRadius: BorderRadius.circular(4),
                        hoverColor: Colors.grey.shade100,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
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
                            final targetPath =
                                matchingPath; // Capture for closure

                            // Clean display text (remove query params)
                            final displaySegment = segment.split('?')[0];

                            return InkWell(
                              onTap:
                                  isLast ? null : () => context.go(targetPath),
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
                                    color:
                                        isLast
                                            ? const Color(0xFF0F4C75)
                                            : Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight:
                                        isLast
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),

          // System Status (Cloud)
          Tooltip(
            message: 'Todos los datos sincronizados',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_done,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                  if (MediaQuery.of(context).size.width > 900) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Sincronizado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Search Field (Responsive)
          if (MediaQuery.of(context).size.width > 750)
            SizedBox(
              width: 200,
              height: 36,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                style: const TextStyle(fontSize: 13),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {},
            ),

          const SizedBox(width: 16),

          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  size: 24,
                  color: Colors.grey,
                ),
                onPressed: () {
                  // Show notifications panel
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
