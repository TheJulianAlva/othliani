import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/navigation/routes_agencia.dart'; // Mantener Rutas constants si se usan
import 'package:frontend/core/services/unsaved_changes_service.dart';
import 'package:frontend/core/di/service_locator.dart' as di;

class AgencySidebar extends StatelessWidget {
  final bool isCollapsed;
  final StatefulNavigationShell navigationShell;

  const AgencySidebar({
    super.key,
    this.isCollapsed = false,
    required this.navigationShell,
  });

  void _onNavigate(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final unsavedService = di.sl<UnsavedChangesService>();

    if (unsavedService.isDirty) {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("⚠️ Cambios sin guardar"),
              content: const Text(
                "Tienes trabajo pendiente. Si sales ahora, podrías perder los cambios del borrador actual.\n\n¿Estás seguro de cerrar sesión?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancelar"),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    unsavedService.setDirty(false); // Forzar limpieza
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Salir de todas formas"),
                ),
              ],
            ),
      );

      if (shouldLogout != true) return;
    }

    // Proceder con logout
    if (context.mounted) {
      context.go(RoutesAgencia.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;

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

          // Scrollable Content
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

                if (isCollapsed)
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // 3. Navigation Menu
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      isActive: currentIndex == 0,
                      onTap: () => _onNavigate(context, 0),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.flight,
                      label: 'Gestión Viajes',
                      isActive: currentIndex == 1,
                      onTap: () => _onNavigate(context, 1),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.people,
                      label: 'Usuarios',
                      isActive: currentIndex == 2,
                      onTap: () => _onNavigate(context, 2),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.assignment,
                      label: 'Auditoría/Logs',
                      isActive: currentIndex == 3,
                      onTap: () => _onNavigate(context, 3),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings,
                      label: 'Configuración',
                      isActive: currentIndex == 4,
                      onTap: () => _onNavigate(context, 4),
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
                          onTap: () => _handleLogout(context),
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
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          isActive
              ? const Color(0xFF1B263B)
              : Colors.transparent, // Active Check
      child: InkWell(
        onTap: onTap,
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
