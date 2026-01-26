import 'package:flutter/material.dart';
import '../widgets/users/guides_tab.dart';
import '../widgets/users/clients_tab.dart';
import '../widgets/users/new_guide_modal.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            // Header Content
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gestión de Staff y Clientes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F4C75),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const NewGuideModal(),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('DAR DE ALTA GUÍA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C75),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  const TabBar(
                    labelColor: Color(0xFF0F4C75),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF0F4C75),
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: '👔 GUÍAS (MI EQUIPO)'),
                      Tab(text: '🎒 HISTORIAL DE CLIENTES (PAX)'),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            const Expanded(
              child: TabBarView(children: [GuidesTab(), ClientsTab()]),
            ),
          ],
        ),
      ),
    );
  }
}
