import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';
import 'package:frontend/features/guia/home/presentation/screens/pantalla_alertas_guia.dart';
import 'package:frontend/core/demo/demo_config.dart';

/// Widget invisible que solo existe en kDemoMode.
/// Al hacer triple-tap en la esquina superior derecha de la pantalla del guía,
/// navega directamente a PantallaAlertasGuia con datos mock de Ana Martínez.
/// Esto permite ejecutar el Acto 2 de la demo sin depender del servidor Railway.
class DemoPanicTrigger extends StatefulWidget {
  final Widget child;
  const DemoPanicTrigger({super.key, required this.child});

  @override
  State<DemoPanicTrigger> createState() => _DemoPanicTriggerState();
}

class _DemoPanicTriggerState extends State<DemoPanicTrigger> {
  int _tapCount = 0;
  DateTime? _firstTap;

  void _handleTap() {
    final now = DateTime.now();
    if (_firstTap == null ||
        now.difference(_firstTap!) > const Duration(milliseconds: 800)) {
      _firstTap = now;
      _tapCount = 1;
    } else {
      _tapCount++;
      if (_tapCount >= 3) {
        _tapCount = 0;
        _firstTap = null;
        _activarAlerta();
      }
    }
  }

  void _activarAlerta() {
    const turista = Turista(
      id: 'turista-demo-ana',
      nombre: kDemoTuristaNombre,
      viajeId: kDemoTripId,
      status: 'SOS',
      bateria: 0.65,
      enCampo: true,
      vulnerabilidad: NivelVulnerabilidad.estandar,
      contactoEmergenciaNombre: 'Roberto Martínez',
      contactoEmergenciaParentesco: 'Esposo',
      contactoEmergenciaTelefono: '+52 998 234 5678',
    );

    if (mounted) {
      context.push(
        RoutesGuia.alertaTurista,
        extra: const AlertaTuristaParams(
          turista: turista,
          motivoAlerta: 'Botón de pánico activado',
          distanciaMetros: 285.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDemoMode) return widget.child;

    return Stack(
      children: [
        widget.child,
        // Zona de triple-tap en esquina superior derecha — invisible para la audiencia
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox(width: 60, height: 60),
          ),
        ),
      ],
    );
  }
}
