import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';
import 'package:frontend/features/guia/shared/widgets/critical_medical_card.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/swipe_to_action_widget.dart';
import 'package:frontend/features/guia/trips/domain/services/caja_negra_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PantallaAlertasGuia
//
// Pantalla de respuesta inmediata cuando un turista activa el botón de pánico
// o abandona la geocerca. Muestra:
//
//   • Fondo ROJO pulsante si turista.vulnerabilidad == NivelVulnerabilidad.critica
//   • Fondo NARANJA si es turista estándar
//   • CriticalMedicalCard solo cuando hay datos médicos vitales
//   • SwipeToActionWidget (anti-nervios) para "Emergencia Resuelta"
//   • Botón de llamada directa al turista
//
// Uso (con go_router push):
//   context.push(RoutesGuia.alertaTurista,
//     extra: AlertaTuristaParams(
//       turista: turista,
//       motivoAlerta: 'Salió de la zona segura',
//       distanciaMetros: 320,
//     )
//   );
// ─────────────────────────────────────────────────────────────────────────────

/// Parámetros para navegar a [PantallaAlertasGuia].
class AlertaTuristaParams {
  final Turista turista;
  final String motivoAlerta;
  final double distanciaMetros;

  const AlertaTuristaParams({
    required this.turista,
    required this.motivoAlerta,
    required this.distanciaMetros,
  });
}

class PantallaAlertasGuia extends StatefulWidget {
  final Turista turista;
  final String motivoAlerta;
  final double distanciaMetros;

  const PantallaAlertasGuia({
    super.key,
    required this.turista,
    required this.motivoAlerta,
    required this.distanciaMetros,
  });

  @override
  State<PantallaAlertasGuia> createState() => _PantallaAlertasGuiaState();
}

class _PantallaAlertasGuiaState extends State<PantallaAlertasGuia>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  bool get esCritica =>
      widget.turista.vulnerabilidad == NivelVulnerabilidad.critica;

  @override
  void initState() {
    super.initState();
    // Vibración al abrir la pantalla de alerta
    HapticFeedback.heavyImpact();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Colores ───────────────────────────────────────────────────────────────

  Color get _colorFondo =>
      esCritica ? const Color(0xFFB71C1C) : const Color(0xFFE65100);

  Color get _colorFondoFlash =>
      esCritica ? const Color(0xFFE53935) : const Color(0xFFF57C00);

  // ── Marcador de distancia ─────────────────────────────────────────────────

  String get _distanciaTexto {
    final d = widget.distanciaMetros;
    return d >= 1000
        ? '${(d / 1000).toStringAsFixed(1)} km'
        : '${d.toInt()} metros';
  }

  // ── Llamar al turista (teléfono) ─────────────────────────────────────────

  Future<void> _llamar(BuildContext ctx) async {
    final tel = widget.turista.contactoEmergenciaTelefono;
    if (tel == null || tel.isEmpty) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('No hay teléfono de emergencia registrado.'),
          ),
        );
      }
      return;
    }
    // Copia el número al portapapeles como fallback confiable
    await Clipboard.setData(ClipboardData(text: tel));
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Número copiado: $tel — Abre el marcador'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) {
        final bg = Color.lerp(_colorFondo, _colorFondoFlash, _pulseCtrl.value)!;
        return Scaffold(backgroundColor: bg, body: child);
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      esCritica ? '⚡ TURISTA EN PELIGRO' : 'TURISTA EN RIESGO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Avatar ─────────────────────────────────────────────────
              _Avatar(nombre: widget.turista.nombre),
              const SizedBox(height: 12),

              // Nombre
              Text(
                widget.turista.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),

              // Badge motivo + distancia
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.motivoAlerta}  ·  $_distanciaTexto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Badge vulnerabilidad
              if (esCritica)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⚡ PRIORIDAD CRÍTICA',
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

              // ── Ficha médica vital ──────────────────────────────────────
              CriticalMedicalCard(turista: widget.turista),

              const Spacer(),

              // ── Botón de llamada ────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => _llamar(context),
                icon: const Icon(Icons.phone_rounded, color: Colors.white),
                label: Text(
                  widget.turista.contactoEmergenciaNombre != null
                      ? 'Llamar contacto: ${widget.turista.contactoEmergenciaNombre}'
                      : 'Llamar contacto de emergencia',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70, width: 1.5),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Confirmar resolución (anti-nervios) ─────────────────────
              const Text(
                'DESLIZA PARA CONFIRMAR QUE ESTÁ SEGURO',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              SwipeToActionWidget(
                text: 'Emergencia RESUELTA',
                baseColor: Colors.green.shade400,
                icon: Icons.check_circle_rounded,
                onActionCompleted: () {
                  HapticFeedback.lightImpact();
                  CajaNegraService().registrarIncidenteResuelto(
                    turistaId: widget.turista.id,
                    nombreTurista: widget.turista.nombre,
                    motivoOriginal: widget.motivoAlerta,
                  );
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar circular ───────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String nombre;

  const _Avatar({required this.nombre});

  String get _iniciales {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.white.withAlpha(40),
      child: CircleAvatar(
        radius: 44,
        backgroundColor: Colors.white.withAlpha(80),
        child: Text(
          _iniciales,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
