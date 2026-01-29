import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes_agencia.dart';

class AgencySidebar extends StatelessWidget {
  final bool isCollapsed;
  final String activeItem;

  const AgencySidebar({
    super.key,
    this.isCollapsed = false,
    this.activeItem = '',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 250,
      color: const Color(0xFF0D1B2A), // Dark Sidebar Background
      child: Column(
        children: [
          // 1. Brand Area (Logo)
          Container(
            height: 64,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child:
                isCollapsed
                    ? const Icon(Icons.business, color: Colors.white)
                    : const Text(
                      'OTHLIANI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
          ),

          // Scrollable Content with Sticky Footer behavior
          Expanded(
            child: CustomScrollView(
              slivers: [
                // 2. User Widget
                if (!isCollapsed)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 20,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Julian XD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Super Admin',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Spacer if User Widget is hidden (Optional, or just styling)
                if (isCollapsed)
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // 3. Navigation Menu
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      path: RoutesAgencia.dashboard,
                      labelToCheck: 'Dashboard',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.flight,
                      label: 'Gestión Viajes',
                      path: RoutesAgencia.viajes,
                      labelToCheck: 'Viajes',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.people,
                      label: 'Usuarios',
                      path: RoutesAgencia.usuarios,
                      labelToCheck: 'Usuarios',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.assignment,
                      label: 'Auditoría/Logs',
                      path: RoutesAgencia.auditoria,
                      labelToCheck: 'Auditoría',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings,
                      label: 'Configuración',
                      path: RoutesAgencia.configuracion,
                      labelToCheck: 'Configuración',
                    ),
                  ]),
                ),

                // 4. Sticky Footer (Logout)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSimpleItem(
                          icon: Icons.logout,
                          label: 'Cerrar Sesión',
                          onTap: () {
                            context.go(RoutesAgencia.login);
                          },
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
    required String labelToCheck, // New param to match activeItem
  }) {
    final bool isActive = activeItem == labelToCheck;

    return Material(
      color:
          isActive
              ? const Color(0xFF1B263B)
              : Colors.transparent, // Active Check
      child: InkWell(
        onTap: () => context.go(path),
        hoverColor: const Color(0xFF415A77).withValues(alpha: 0.3),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration:
              isActive
                  ? const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.blueAccent, width: 4),
                    ),
                  )
                  : null,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.blueAccent : Colors.white70,
                  size: 24,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
        ), // Already inside padding
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Icon(icon, color: color ?? Colors.white70, size: 24),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: color ?? Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
