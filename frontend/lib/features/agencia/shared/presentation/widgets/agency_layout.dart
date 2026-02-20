import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend/core/di/service_locator.dart' as di;
import 'package:frontend/core/services/unsaved_changes_service.dart';
import 'agency_sidebar.dart';
import 'agency_header.dart';

class AgencyLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AgencyLayout({super.key, required this.navigationShell});

  @override
  State<AgencyLayout> createState() => _AgencyLayoutState();
}

class _AgencyLayoutState extends State<AgencyLayout> with WindowListener {
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initPreventClose();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    windowManager.setPreventClose(false); // Reset al salir
    super.dispose();
  }

  Future<void> _initPreventClose() async {
    await windowManager.setPreventClose(true);
  }

  @override
  Future<void> onWindowClose() async {
    final unsavedService = di.sl<UnsavedChangesService>();

    if (unsavedService.isDirty) {
      final shouldClose = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("⚠️ Cambios sin guardar"),
              content: const Text(
                "Tienes trabajo pendiente. Si cierras la aplicación, perderás los cambios no guardados.\n\n¿Estás seguro de salir?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancelar"),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Salir de todas formas"),
                ),
              ],
            ),
      );

      if (shouldClose == true) {
        unsavedService.setDirty(false); // Forzar limpieza
        await windowManager.destroy();
      } else {
        // Usuario canceló, no hacemos nada (la ventana sigue abierta)
      }
    } else {
      await windowManager.destroy();
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar Fijo
          AgencySidebar(
            navigationShell: widget.navigationShell,
            isCollapsed: _isSidebarCollapsed,
          ),

          // 2. Contenido Variable
          Expanded(
            child: Column(
              children: [
                AgencyHeader(
                  onMenuPressed: _toggleSidebar,
                  isSidebarCollapsed: _isSidebarCollapsed,
                ), // Header fijo también
                Expanded(
                  child: Container(
                    color: const Color(0xFFF4F6F8),
                    padding: const EdgeInsets.all(24.0),
                    child: widget.navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
