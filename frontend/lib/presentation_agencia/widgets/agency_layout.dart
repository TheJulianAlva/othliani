import 'package:flutter/material.dart';
import 'agency_sidebar.dart';
import 'agency_header.dart';

class AgencyLayout extends StatefulWidget {
  final Widget child;

  const AgencyLayout({super.key, required this.child});

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
          // Sidebar
          AgencySidebar(isCollapsed: _isSidebarCollapsed),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header
                AgencyHeader(
                  onMenuPressed: _toggleSidebar,
                  isSidebarCollapsed: _isSidebarCollapsed,
                ),

                // Dynamic Content (Router View)
                Expanded(
                  child: Container(
                    color: const Color(0xFFF4F6F8), // Background Color
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
