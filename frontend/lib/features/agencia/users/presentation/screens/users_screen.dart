import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/usuarios/usuarios_bloc.dart';
import '../widgets/guides_tab.dart';
import '../widgets/directory_tab.dart';
import '../widgets/new_guide_modal.dart';
import '../../../../../injection_container.dart' as di;

class UsersScreen extends StatelessWidget {
  final String initialTab;

  const UsersScreen({super.key, this.initialTab = 'guias'});

  @override
  Widget build(BuildContext context) {
    // Read Query Param for Tab Selection
    int initialIndex = (initialTab == 'clientes') ? 1 : 0;

    return BlocProvider(
      create: (context) => di.sl<UsuariosBloc>()..add(LoadUsuariosEvent()),
      child: DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
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
                child: TabBarView(children: [GuidesTab(), DirectoryTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
