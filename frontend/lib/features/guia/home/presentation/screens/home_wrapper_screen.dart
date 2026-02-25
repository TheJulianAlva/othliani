import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:frontend/features/guia/home/presentation/blocs/agencia_home_bloc/agencia_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/sos/sos_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/eco_mode/eco_mode_cubit.dart';
import 'package:frontend/features/guia/home/presentation/screens/agencia_main_layout.dart';
import 'package:frontend/features/guia/home/presentation/screens/personal_main_layout.dart';
import 'package:frontend/features/guia/home/presentation/widgets/sos_pre_aviso_overlay.dart';
import 'package:frontend/features/guia/home/presentation/widgets/eco_mode_overlay.dart';
import 'package:frontend/core/di/service_locator.dart';

/// Punto de entrada único para el home del guía.
///
/// Lee el [GuiaUserModel] cacheado y despacha al layout correcto:
/// - [permissionLevel] == 2 → [AgenciaMainLayout] (B2B)
/// - [permissionLevel] == 1 → [PersonalMainLayout] (B2C)
///
/// Provee [SosCubit] y [EcoModeCubit] a todo el árbol.
/// El [EcoModeOverlay] y el [SosPreAvisoOverlay] se superponen con [Stack].
///
/// ✨ Despertar forzado: si [SosCubit] entra en [SosWarning] o [SosActive]
/// mientras el Modo Eco está activo, el [BlocListener] llama a
/// [EcoModeCubit.disableEcoMode()] automáticamente.
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

    final user = _user;

    // Sin sesión guardada → fallback al layout personal vacío
    if (user == null) {
      return _WrappedHome(
        layoutCubitProvider: BlocProvider<PersonalHomeCubit>(
          create: (_) => sl<PersonalHomeCubit>(),
        ),
        content: const PersonalMainLayout(nombreGuia: 'Guía'),
        numTuristas: 0,
      );
    }

    // Sesión B2B (agencia)
    if (user.permissionLevel == 2) {
      final folio = _folioDesdeId(user.id);
      return _WrappedHome(
        layoutCubitProvider: BlocProvider<AgenciaHomeCubit>(
          create: (_) => sl<AgenciaHomeCubit>(),
        ),
        content: AgenciaMainLayout(nombreGuia: user.name, folio: folio),
        // Para el Modo Eco mostramos el número de turistas del estado actual
        // sin levantar el cubit aquí; el overlay toma el valor inyectado.
        numTuristas: 15,
      );
    }

    // Sesión B2C (personal)
    return _WrappedHome(
      layoutCubitProvider: BlocProvider<PersonalHomeCubit>(
        create: (_) => sl<PersonalHomeCubit>(),
      ),
      content: PersonalMainLayout(nombreGuia: user.name),
      numTuristas: 0,
    );
  }

  /// Convierte el ID guardado ("guia_b2b_ag_001") a folio ("AG-001").
  String _folioDesdeId(String id) {
    final partes = id.replaceFirst('guia_b2b_', '').toUpperCase().split('_');
    if (partes.length >= 2) return '${partes[0]}-${partes[1]}';
    return id.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WrappedHome
//
// Ayudante privado que evita triplicar el código de providers + Stack.
// Inyecta SosCubit, EcoModeCubit y monta las capas en este orden:
//
//   [0] Layout principal (B2B o B2C)
//   [1] EcoModeOverlay         — negro OLED, se muestra si Eco activo
//   [2] SosPreAvisoOverlay     — naranja, se muestra si SosWarning/SosActive
//
// BlocListener maestro: SosCubit → desactiva Eco si hay emergencia.
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
          // 🚨 DESPERTAR FORZADO: si hay emergencia, salir del Modo Eco
          ctx.read<EcoModeCubit>().disableEcoMode();
        },
        child: BlocBuilder<EcoModeCubit, bool>(
          builder: (context, ecoActivo) {
            return Stack(
              children: [
                // Capa 0 — Layout normal
                content,

                // Capa 1 — Modo Eco (pantalla negra OLED)
                if (ecoActivo)
                  Positioned.fill(
                    child: EcoModeOverlay(turistasActivos: numTuristas),
                  ),

                // Capa 2 — Pre-aviso SOS (siempre más arriba que el Eco)
                const Positioned.fill(child: SosPreAvisoOverlay()),
              ],
            );
          },
        ),
      ),
    );
  }
}
