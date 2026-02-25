import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Mapa de monitoreo activo del guía.
/// Como el proyecto no tiene google_maps integrado aún, usamos un Canvas
/// personalizado que simula: geocerca, pines de turistas con iniciales,
/// marcador del guía y la leyenda de estado.
class GuiaMapScreen extends StatefulWidget {
  const GuiaMapScreen({super.key});

  @override
  State<GuiaMapScreen> createState() => _GuiaMapScreenState();
}

// ── Modelo de turista en el mapa ──────────────────────────────────────────────

enum EstadoPin { cercano, alejado, alerta }

class _TuristaPin {
  final String id;
  final String nombre;
  final double x; // 0..1 relativo al canvas
  final double y;
  final EstadoPin estado;

  const _TuristaPin({
    required this.id,
    required this.nombre,
    required this.x,
    required this.y,
    required this.estado,
  });
}

// ── Datos mock ────────────────────────────────────────────────────────────────

const _mockTuristas = [
  _TuristaPin(
    id: 't1',
    nombre: 'Juan D.',
    x: 0.45,
    y: 0.38,
    estado: EstadoPin.cercano,
  ),
  _TuristaPin(
    id: 't2',
    nombre: 'Ana M.',
    x: 0.55,
    y: 0.42,
    estado: EstadoPin.cercano,
  ),
  _TuristaPin(
    id: 't3',
    nombre: 'Luis H.',
    x: 0.62,
    y: 0.35,
    estado: EstadoPin.alejado,
  ),
  _TuristaPin(
    id: 't4',
    nombre: 'Sofía R.',
    x: 0.35,
    y: 0.50,
    estado: EstadoPin.alerta,
  ),
  _TuristaPin(
    id: 't5',
    nombre: 'Carlos L.',
    x: 0.50,
    y: 0.55,
    estado: EstadoPin.cercano,
  ),
  _TuristaPin(
    id: 't6',
    nombre: 'Paola T.',
    x: 0.70,
    y: 0.60,
    estado: EstadoPin.alejado,
  ),
];

class _GuiaMapScreenState extends State<GuiaMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulso;
  String? _seleccionado;

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: AppBar(
        title: const Text('Mapa en vivo'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.my_location), onPressed: () {}),
          IconButton(icon: const Icon(Icons.layers_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de estado rápido ───────────────────────────────────
          _BarraEstado(),
          // ── Canvas del mapa ──────────────────────────────────────────
          Expanded(
            child: AnimatedBuilder(
              animation: _pulso,
              builder: (context, _) {
                return _MapaCanvas(
                  turistas: _mockTuristas,
                  pulsoValue: _pulso.value,
                  seleccionado: _seleccionado,
                  onTap:
                      (id) => setState(
                        () => _seleccionado = id == _seleccionado ? null : id,
                      ),
                );
              },
            ),
          ),
          // ── Info del pin seleccionado ────────────────────────────────
          if (_seleccionado != null)
            _InfoPin(
              turista: _mockTuristas.firstWhere((t) => t.id == _seleccionado),
              onCerrar: () => setState(() => _seleccionado = null),
            ),
          // ── Leyenda ──────────────────────────────────────────────────
          _Leyenda(),
        ],
      ),
    );
  }
}

// ── Canal del mapa (CustomPainter) ───────────────────────────────────────────

class _MapaCanvas extends StatelessWidget {
  final List<_TuristaPin> turistas;
  final double pulsoValue;
  final String? seleccionado;
  final void Function(String id) onTap;

  const _MapaCanvas({
    required this.turistas,
    required this.pulsoValue,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) {
        final size = context.size ?? Size.zero;
        for (final t in turistas) {
          final px = t.x * size.width;
          final py = t.y * size.height;
          if ((d.localPosition - Offset(px, py)).distance < 22) {
            onTap(t.id);
            return;
          }
        }
      },
      child: CustomPaint(
        painter: _MapaPainter(
          turistas: turistas,
          pulso: pulsoValue,
          seleccionado: seleccionado,
        ),
        child: Container(),
      ),
    );
  }
}

class _MapaPainter extends CustomPainter {
  final List<_TuristaPin> turistas;
  final double pulso;
  final String? seleccionado;

  _MapaPainter({
    required this.turistas,
    required this.pulso,
    this.seleccionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Fondo estilo mapa simple ──────────────────────────────────────────
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8EAF0),
    );

    // Cuadrícula de calles
    final callesPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 14;
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * i / 6, 0),
        Offset(size.width * i / 6, size.height),
        callesPaint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 6),
        Offset(size.width, size.height * i / 6),
        callesPaint,
      );
    }
    // Bloques de edificios
    final edificioPaint = Paint()..color = const Color(0xFFCFD8DC);
    final bloques = [
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.05,
        size.width * 0.10,
        size.height * 0.12,
      ),
      Rect.fromLTWH(
        size.width * 0.20,
        size.height * 0.05,
        size.width * 0.12,
        size.height * 0.10,
      ),
      Rect.fromLTWH(
        size.width * 0.65,
        size.height * 0.08,
        size.width * 0.14,
        size.height * 0.14,
      ),
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.25,
        size.width * 0.15,
        size.height * 0.18,
      ),
      Rect.fromLTWH(
        size.width * 0.65,
        size.height * 0.30,
        size.width * 0.12,
        size.height * 0.16,
      ),
      Rect.fromLTWH(
        size.width * 0.20,
        size.height * 0.65,
        size.width * 0.18,
        size.height * 0.14,
      ),
      Rect.fromLTWH(
        size.width * 0.60,
        size.height * 0.68,
        size.width * 0.16,
        size.height * 0.12,
      ),
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.70,
        size.width * 0.10,
        size.height * 0.18,
      ),
    ];
    for (final b in bloques) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(3)),
        edificioPaint,
      );
    }

    // ── Geocerca (círculo cian traslúcido) ────────────────────────────────
    final centro = Offset(size.width * 0.50, size.height * 0.45);
    final radio = size.width * 0.30;
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..color = const Color(0x3000BCD4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..color = const Color(0xFF00BCD4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // ── Pines de turistas ─────────────────────────────────────────────────
    for (final t in turistas) {
      final px = t.x * size.width;
      final py = t.y * size.height;
      final esAlerta = t.estado == EstadoPin.alerta;
      final esAlejado = t.estado == EstadoPin.alejado;

      // Pulso para alerta
      if (esAlerta) {
        canvas.drawCircle(
          Offset(px, py),
          18 + pulso * 8,
          Paint()
            ..color = const Color(0xFFD32F2F).withAlpha((pulso * 80).toInt()),
        );
      }

      // Círculo del pin
      final borderColor =
          esAlerta
              ? const Color(0xFFD32F2F)
              : esAlejado
              ? const Color(0xFFFF6D00)
              : const Color(0xFF2E7D32);
      final bgColor =
          esAlerta
              ? const Color(0xFFFFEBEE)
              : esAlejado
              ? const Color(0xFFFFF3E0)
              : const Color(0xFFE8F5E9);

      canvas.drawCircle(Offset(px, py), 18, Paint()..color = bgColor);
      canvas.drawCircle(
        Offset(px, py),
        18,
        Paint()
          ..color = borderColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );

      // Iniciales
      final partes = t.nombre.split(' ');
      final iniciales =
          partes.length >= 2
              ? '${partes[0][0]}${partes[1][0]}'
              : partes[0].substring(0, 2);
      final tp = TextPainter(
        text: TextSpan(
          text: iniciales.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: borderColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));

      // Seleccionado → tooltip
      if (seleccionado == t.id) {
        final tooltipPaint = Paint()..color = const Color(0xFF1A237E);
        final rr = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(px, py - 34), width: 80, height: 22),
          const Radius.circular(6),
        );
        canvas.drawRRect(rr, tooltipPaint);
        final tp2 = TextPainter(
          text: TextSpan(
            text: t.nombre,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 76);
        tp2.paint(canvas, Offset(px - tp2.width / 2, py - 34 - tp2.height / 2));
      }
    }

    // ── Pin del guía (rojo / posición central) ────────────────────────────
    final guiaPx = size.width * 0.49;
    final guiaPy = size.height * 0.44;
    canvas.drawCircle(
      Offset(guiaPx, guiaPy),
      14,
      Paint()..color = const Color(0xFFB71C1C),
    );
    canvas.drawCircle(
      Offset(guiaPx, guiaPy),
      14,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Triángulo inferior del pin
    final path =
        Path()
          ..moveTo(guiaPx - 6, guiaPy + 12)
          ..lineTo(guiaPx + 6, guiaPy + 12)
          ..lineTo(guiaPx, guiaPy + 22)
          ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFB71C1C));

    final tpGuia = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpGuia.paint(
      canvas,
      Offset(guiaPx - tpGuia.width / 2, guiaPy - tpGuia.height / 2),
    );

    // Radio de la geocerca en texto
    final tpGeo = TextPainter(
      text: const TextSpan(
        text: '⬤ Geocerca · 300 m',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF00838F),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpGeo.paint(
      canvas,
      Offset(size.width / 2 - tpGeo.width / 2, size.height * 0.12),
    );
  }

  @override
  bool shouldRepaint(_MapaPainter old) =>
      old.pulso != pulso || old.seleccionado != seleccionado;
}

// ── Barra de estado ───────────────────────────────────────────────────────────

class _BarraEstado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _ChipEstadoMapa(
            icono: Icons.check_circle,
            texto: '4 ok',
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 8),
          _ChipEstadoMapa(
            icono: Icons.wifi_off,
            texto: '2 offline',
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _ChipEstadoMapa(
            icono: Icons.warning,
            texto: '1 alerta',
            color: const Color(0xFFD32F2F),
          ),
          const Spacer(),
          const Icon(Icons.circle, color: Color(0xFF00BCD4), size: 10),
          const SizedBox(width: 4),
          const Text('Geocerca activa', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _ChipEstadoMapa extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  const _ChipEstadoMapa({
    required this.icono,
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          texto,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Info pin seleccionado ──────────────────────────────────────────────────────

class _InfoPin extends StatelessWidget {
  final _TuristaPin turista;
  final VoidCallback onCerrar;
  const _InfoPin({required this.turista, required this.onCerrar});

  @override
  Widget build(BuildContext context) {
    final (color, etiqueta) = switch (turista.estado) {
      EstadoPin.cercano => (const Color(0xFF2E7D32), 'Dentro de geocerca'),
      EstadoPin.alejado => (const Color(0xFFE65100), 'Fuera de geocerca'),
      EstadoPin.alerta => (const Color(0xFFD32F2F), '⚠️ Alerta activa'),
    };
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withAlpha(30),
            child: Text(
              turista.nombre.substring(0, 1),
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  turista.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(etiqueta, style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onCerrar,
          ),
        ],
      ),
    );
  }
}

// ── Leyenda ───────────────────────────────────────────────────────────────────

class _Leyenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ItemLeyenda(color: const Color(0xFF2E7D32), texto: 'Cerca'),
          _ItemLeyenda(color: const Color(0xFFFF6D00), texto: 'Alejado'),
          _ItemLeyenda(color: const Color(0xFFD32F2F), texto: 'Alerta'),
          _ItemLeyenda(
            color: const Color(0xFFB71C1C),
            texto: 'Guía',
            forma: BoxShape.rectangle,
          ),
        ],
      ),
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String texto;
  final BoxShape forma;
  const _ItemLeyenda({
    required this.color,
    required this.texto,
    this.forma = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: forma,
            borderRadius:
                forma == BoxShape.rectangle ? BorderRadius.circular(2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

// ignore: unused_element
double _unused(double a, double b) => math.max(a, b);
