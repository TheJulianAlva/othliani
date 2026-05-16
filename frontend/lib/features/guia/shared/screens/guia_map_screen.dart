import 'package:flutter/material.dart';
import 'package:frontend/features/guia/shared/widgets/guia_custom_app_bar.dart';

/// Mapa de monitoreo activo del guía con Geocerca ajustable.
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
  double _radioActual = 300.0;

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  void _mostrarAjusteGeocerca() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ajustar Geocerca',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Define el radio de seguridad para el grupo.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Radio actual:',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_radioActual.round()} m',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.cyan.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.cyan.shade600,
                        thumbColor: Colors.cyan.shade600,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _radioActual,
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        onChanged: (v) {
                          setSheetState(() => _radioActual = v);
                          setState(() => _radioActual = v);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ChipAjuste(
                          label: '50 m',
                          isSelected: _radioActual == 50,
                          onTap: () {
                            setSheetState(() => _radioActual = 50);
                            setState(() => _radioActual = 50);
                          },
                        ),
                        _ChipAjuste(
                          label: '200 m',
                          isSelected: _radioActual == 200,
                          onTap: () {
                            setSheetState(() => _radioActual = 200);
                            setState(() => _radioActual = 200);
                          },
                        ),
                        _ChipAjuste(
                          label: '300 m',
                          isSelected: _radioActual == 300,
                          onTap: () {
                            setSheetState(() => _radioActual = 300);
                            setState(() => _radioActual = 300);
                          },
                        ),
                        _ChipAjuste(
                          label: '500 m',
                          isSelected: _radioActual == 500,
                          onTap: () {
                            setSheetState(() => _radioActual = 500);
                            setState(() => _radioActual = 500);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CONFIRMAR AJUSTE',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
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
      appBar: GuiaCustomAppBar(
        title: 'Mapa en vivo',
        subtitle: 'Monitoreo de grupo',
        icon: Icons.map_outlined,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.layers_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _BarraEstado(
            onAjustar: _mostrarAjusteGeocerca,
            radioActual: _radioActual,
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _pulso,
              builder: (context, _) {
                return _MapaCanvas(
                  turistas: _mockTuristas,
                  pulsoValue: _pulso.value,
                  seleccionado: _seleccionado,
                  radioGeocerca: _radioActual,
                  onTap:
                      (id) => setState(
                        () => _seleccionado = id == _seleccionado ? null : id,
                      ),
                );
              },
            ),
          ),
          if (_seleccionado != null)
            _InfoPin(
              turista: _mockTuristas.firstWhere((t) => t.id == _seleccionado),
              onCerrar: () => setState(() => _seleccionado = null),
            ),
          _Leyenda(),
        ],
      ),
    );
  }
}

class _ChipAjuste extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ChipAjuste({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.cyan.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ── Canal del mapa (CustomPainter) ───────────────────────────────────────────

class _MapaCanvas extends StatelessWidget {
  final List<_TuristaPin> turistas;
  final double pulsoValue;
  final String? seleccionado;
  final double radioGeocerca;
  final void Function(String id) onTap;

  const _MapaCanvas({
    required this.turistas,
    required this.pulsoValue,
    required this.seleccionado,
    required this.radioGeocerca,
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
          radioGeocerca: radioGeocerca,
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
  final double radioGeocerca;

  _MapaPainter({
    required this.turistas,
    required this.pulso,
    required this.radioGeocerca,
    this.seleccionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8EAF0),
    );

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

    final centro = Offset(size.width * 0.50, size.height * 0.45);
    final radioVisual = size.width * (radioGeocerca / 1000);

    canvas.drawCircle(
      centro,
      radioVisual,
      Paint()
        ..color = const Color(0x3000BCD4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      centro,
      radioVisual,
      Paint()
        ..color = const Color(0xFF00BCD4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    for (final t in turistas) {
      final px = t.x * size.width;
      final py = t.y * size.height;
      final esAlerta = t.estado == EstadoPin.alerta;
      final esAlejado = t.estado == EstadoPin.alejado;

      if (esAlerta) {
        canvas.drawCircle(
          Offset(px, py),
          18 + pulso * 8,
          Paint()
            ..color = const Color(0xFFD32F2F).withAlpha((pulso * 80).toInt()),
        );
      }

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

    final tpGeo = TextPainter(
      text: TextSpan(
        text: '⬤ Geocerca · ${radioGeocerca.toInt()} m',
        style: const TextStyle(
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
      old.pulso != pulso ||
      old.seleccionado != seleccionado ||
      old.radioGeocerca != radioGeocerca;
}

// ── Otros Widgets ─────────────────────────────────────────────────────────────

class _BarraEstado extends StatelessWidget {
  final VoidCallback onAjustar;
  final double radioActual;
  const _BarraEstado({required this.onAjustar, required this.radioActual});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
              const Text(
                '14:38',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _GeocercaBannerMapa(onAjustar: onAjustar, radioActual: radioActual),
      ],
    );
  }
}

class _GeocercaBannerMapa extends StatelessWidget {
  final VoidCallback onAjustar;
  final double radioActual;
  const _GeocercaBannerMapa({
    required this.onAjustar,
    required this.radioActual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        border: Border(
          bottom: BorderSide(color: Colors.cyan.shade100),
          top: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF00ACC1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.gps_fixed, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GEOCERCA ACTIVA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF006064),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Radio: ${radioActual.toInt()}m · Zona Arqueológica',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00838F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAjustar,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.cyan.shade200),
              ),
            ),
            child: const Text(
              'Ajustar',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
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
