import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/navigation/routes_agencia.dart';
import 'package:frontend/core/widgets/saving_overlay.dart';

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
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout, color: Colors.redAccent, size: 22),
                SizedBox(width: 10),
                Text('¿Cerrar sesión?'),
              ],
            ),
            content: const Text(
              'Cualquier progreso no guardado se perderá. '
              '¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );

    if (confirmar != true || !context.mounted) return;

    await SavingOverlay.showAndWait(
      context,
      mensaje: 'Cerrando sesión...',
      duration: const Duration(milliseconds: 900),
    );

    if (context.mounted) {
      context.go(RoutesAgencia.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;
    const primaryDark = Color(0xFF1B3B6F);
    const textGray = Color(0xFF5A6B7C);
    const borderGray = Color(0xFFE0E5EC);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: borderGray, width: 1)),
      ),
      child: Column(
        children: [
          // 1. Brand Area (Logo)
          Container(
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: borderGray, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'V',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'VELTUR',
                    style: TextStyle(
                      color: primaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'App',
                    style: TextStyle(
                      color: textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Navigation Menu
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildNavItem(
                      context,
                      icon: Icons.explore_rounded,
                      label: 'Radar Operativo',
                      isActive: currentIndex == 0,
                      onTap: () => _onNavigate(context, 0),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.directions_bus_rounded,
                      label: 'Op. de Viajes',
                      isActive: currentIndex == 1,
                      onTap: () => _onNavigate(context, 1),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.badge_rounded,
                      label: 'Staff / Guías',
                      isActive: currentIndex == 2,
                      onTap: () => _onNavigate(context, 2),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.history_rounded,
                      label: 'Historial PAX',
                      isActive: currentIndex == 3,
                      onTap: () => _onNavigate(context, 3),
                    ),
                    const SizedBox(height: 20),
                    if (!isCollapsed)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'SISTEMA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textGray,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings_rounded,
                      label: 'Configuración',
                      isActive: currentIndex == 4,
                      onTap: () => _onNavigate(context, 4),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          // 3. Sticky Footer (Profile & Logout)
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: borderGray, width: 1)),
            ),
            child: Column(
              children: [
                // Profile Widget
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 0 : 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFE8EEFF),
                          radius: 18,
                          child: const Text(
                            'AD',
                            style: TextStyle(
                              color: primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Admin Juan',
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Agencia Central',
                                  style: TextStyle(
                                    color: textGray,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Logout Widget
                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                    child: InkWell(
                      onTap: () => _handleLogout(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: const [
                            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      onPressed: () => _handleLogout(context),
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
    const primaryDark = Color(0xFF1B3B6F);
    const textGray = Color(0xFF5A6B7C);
    const activeBg = Color(0xFFE8EEFF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: activeBg.withValues(alpha: 0.5),
        child: Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isActive ? primaryDark : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 20),
          alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isActive ? primaryDark : textGray,
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? primaryDark : textGray,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
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
