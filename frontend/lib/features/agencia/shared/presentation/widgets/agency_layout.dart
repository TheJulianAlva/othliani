import 'package:flutter/material.dart';
import 'agency_sidebar.dart';
import 'agency_header.dart';

class AgencyLayout extends StatefulWidget {
  final Widget child;
  final String activeItem;

  const AgencyLayout({
    super.key,
    required this.child,
    this.activeItem = 'Dashboard',
  });

  @override
  State<AgencyLayout> createState() => _AgencyLayoutState();
}

class _AgencyLayoutState extends State<AgencyLayout> {
  bool _isSidebarCollapsed = false;

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
            activeItem: widget.activeItem,
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
                    child: widget.child,
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
