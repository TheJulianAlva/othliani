import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';

import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';

// [TODO: Arquitectura Clean]
// Cuando se inyecte el GuiaSessionCubit globalmente, descomentar esta importación.
// import 'package:frontend/features/guia/auth/presentation/cubit/guia_session_cubit.dart';

import 'package:frontend/features/guia/home/presentation/blocs/agencia_home_bloc/agencia_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/sos/sos_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/eco_mode/eco_mode_cubit.dart';

import 'package:frontend/features/guia/home/presentation/screens/agencia_main_layout.dart';
import 'package:frontend/features/guia/home/presentation/screens/personal_main_layout.dart';
import 'package:frontend/features/guia/home/presentation/widgets/sos_pre_aviso_overlay.dart';
import 'package:frontend/features/guia/home/presentation/widgets/eco_mode_overlay.dart';
import 'package:frontend/core/di/service_locator.dart';

// Importaciones de las demás pestañas del guía
import 'package:frontend/features/guia/shared/screens/guia_map_screen.dart';
import 'package:frontend/features/guia/chat/presentation/screens/guia_chat_screen.dart';
import 'package:frontend/features/guia/profile/presentation/screens/guia_profile_screen.dart';
import 'package:frontend/core/tools/presentation/screens/currency_converter_screen.dart';

/// Punto de entrada único para el home del guía.
///
/// Lee el [GuiaUserModel] cacheado y despacha al layout de "Gestión" correspondiente:
/// - [permissionLevel] == 2 → [AgenciaMainLayout] (B2B)
/// - [permissionLevel] == 1 → [PersonalMainLayout] (B2C)
///
/// Implementa un [IndexedStack] y un [BottomNavigationBar] para la navegación interna.
class HomeWrapperScreen extends StatefulWidget {
  const HomeWrapperScreen({super.key});

  @override
  State<HomeWrapperScreen> createState() => _HomeWrapperScreenState();
}

class _HomeWrapperScreenState extends State<HomeWrapperScreen> {
  GuiaUserModel? _user;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('CACHED_GUIA_USER');
    if (jsonStr != null) {
      final model = GuiaUserModel.fromJson(json.decode(jsonStr));
      if (mounted) {
        setState(() {
          _user = model;
          _cargando = false;
        });
      }
    } else {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // [TODO: Arquitectura Clean]
    // A futuro, toda esta lógica de carga local debe reemplazarse por un listener
    // directo al GuiaSessionCubit global de la siguiente forma:
    //
    // return BlocBuilder<GuiaSessionCubit, GuiaSessionState>(
    //   builder: (context, sessionState) {
    //     if (sessionState is GuiaSessionAuthenticated) {
    //       final user = sessionState.user;
    //       // ... (Lógica de instanciación de cubits aquí abajo)
    //     }
    //   }
    // );

    final user = _user;
    Widget gestionScreen;
    int numTuristas = 0;
    BlocProvider layoutCubitProvider;

    // Determinamos qué layout de Gestión usar según la sesión
    if (user == null) {
      layoutCubitProvider = BlocProvider<PersonalHomeCubit>(
        create: (_) => sl<PersonalHomeCubit>(),
      );
      gestionScreen = const PersonalMainLayout(nombreGuia: 'Guía');
    } else if (user.role == GuiaRole.agencia) {
      final folio = _folioDesdeId(user.id);
      layoutCubitProvider = BlocProvider<AgenciaHomeCubit>(
        create: (_) => sl<AgenciaHomeCubit>(),
      );
      gestionScreen = AgenciaMainLayout(nombreGuia: user.name, folio: folio);
      numTuristas = 15;
    } else {
      layoutCubitProvider = BlocProvider<PersonalHomeCubit>(
        create: (_) => sl<PersonalHomeCubit>()..cargarDatos(user.name),
      );
      gestionScreen = PersonalMainLayout(nombreGuia: user.name);
    }

    return _WrappedHome(
      layoutCubitProvider: layoutCubitProvider,
      numTuristas: numTuristas,
      // Pasamos el contenedor maestro que maneja el IndexedStack
      content: _HomeTabs(gestionScreen: gestionScreen),
    );
  }

  String _folioDesdeId(String id) {
    final partes = id.replaceFirst('guia_b2b_', '').toUpperCase().split('_');
    if (partes.length >= 2) return '${partes[0]}-${partes[1]}';
    return id.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HomeTabs
// Contenedor maestro que gestiona el IndexedStack y la Navigation Bar.
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTabs extends StatefulWidget {
  final Widget gestionScreen;
  const _HomeTabs({required this.gestionScreen});

  @override
  State<_HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<_HomeTabs> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      widget.gestionScreen, // 0: Gestión (B2B o B2C)
      const GuiaMapScreen(), // 1: Mapa
      const GuiaChatScreen(), // 2: Chat
      const CurrencyConverterScreen(), // 3: Conversor
      const GuiaProfileScreen(), // 4: Perfil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      // Floating Action Button de SOS sugerido globalmente
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lanza la pantalla base de SOS
          context.push(RoutesGuia.sos);
        },
        backgroundColor: Colors.red.shade700,
        elevation: 4,
        child: const Icon(Icons.sos_rounded, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00AE00),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center_outlined),
            activeIcon: Icon(Icons.business_center),
            label: 'Gestión',
            tooltip:
                'Centro de control: Iniciar/Finalizar viaje, verificar participantes, ver itinerario detallado y estadísticas de viaje (distancia, tiempo, CO2).',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
            tooltip:
                'Monitoreo en vivo de turistas, configuración de radio de geocerca (50m, 200m, 500m), marcar puntos de reunión y activar "Modo Explorador".',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
            tooltip:
                'Comunicación grupal, función "Walkie-Talkie" (envío rápido de audio) y lanzamiento de alertas personalizadas para los turistas.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.paid_outlined),
            activeIcon: Icon(Icons.paid),
            label: 'Conversor',
            tooltip:
                'Herramienta de apoyo: Conversor de divisas instantáneo para asistir a turistas en compras y acceso a la "Caja Negra" de eventos.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
            tooltip:
                'Gestión de cuenta: Configurar contactos de emergencia (Esposa, Hermano, Autoridad), cambio de idioma/tema y cierre de sesión.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WrappedHome
// Capa de providers y overlays (Eco Mode y SOS) que envuelve Toda la interfaz
// ─────────────────────────────────────────────────────────────────────────────
class _WrappedHome extends StatelessWidget {
  final BlocProvider layoutCubitProvider;
  final Widget content;
  final int numTuristas;

  const _WrappedHome({
    required this.layoutCubitProvider,
    required this.content,
    required this.numTuristas,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        layoutCubitProvider,
        BlocProvider(create: (_) => SosCubit()),
        BlocProvider(create: (_) => EcoModeCubit()),
      ],
      child: BlocListener<SosCubit, SosState>(
        listenWhen: (_, curr) => curr is SosWarning || curr is SosActive,
        listener: (ctx, _) {
          ctx.read<EcoModeCubit>().disableEcoMode();
        },
        child: BlocBuilder<EcoModeCubit, bool>(
          builder: (context, ecoActivo) {
            return Stack(
              children: [
                // Toda la UI con Scaffold, Navbar, y FAB incluídos
                content,

                // Overlay Modo Eco
                if (ecoActivo)
                  Positioned.fill(
                    child: EcoModeOverlay(turistasActivos: numTuristas),
                  ),

                // Overlay SOS General (Renderizado condicional para optimizar el árbol)
                BlocBuilder<SosCubit, SosState>(
                  buildWhen:
                      (prev, curr) =>
                          (prev is SosWarning) != (curr is SosWarning),
                  builder: (context, sosState) {
                    if (sosState is SosWarning) {
                      return const Positioned.fill(child: SosPreAvisoOverlay());
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
