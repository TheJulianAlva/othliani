import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/eco_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EcoBadgeWidget — Sello Verde Premium exclusivo para Guías Independientes B2C
//
// Diseño:
//   • Gradiente dinámico según NivelEco (explorador/bronce/plata/oro)
//   • Animación de entrada (fade + slide up) para impacto visual
//   • Barra de progreso animada hacia el siguiente nivel
//   • Botón "Compartir" que copia el texto de la insignia al portapapeles
// ─────────────────────────────────────────────────────────────────────────────

class EcoBadgeWidget extends StatefulWidget {
  final EcoStats stats;

  const EcoBadgeWidget({super.key, required this.stats});

  @override
  State<EcoBadgeWidget> createState() => _EcoBadgeWidgetState();
}

class _EcoBadgeWidgetState extends State<EcoBadgeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.stats.progresoNivel,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Paleta por nivel ───────────────────────────────────────────────────────

  _NivelPaleta get _paleta => switch (widget.stats.nivelActual) {
    NivelEco.oro => const _NivelPaleta(
      gradA: Color(0xFFFF8F00),
      gradB: Color(0xFFE65100),
      icono: Icons.military_tech_rounded,
      glowColor: Color(0xFFFFB300),
    ),
    NivelEco.plata => const _NivelPaleta(
      gradA: Color(0xFF78909C),
      gradB: Color(0xFF37474F),
      icono: Icons.shield_rounded,
      glowColor: Color(0xFF90A4AE),
    ),
    NivelEco.bronce => const _NivelPaleta(
      gradA: Color(0xFFBF8A5C),
      gradB: Color(0xFF6D3B26),
      icono: Icons.eco_rounded,
      glowColor: Color(0xFFD4956B),
    ),
    NivelEco.explorador => const _NivelPaleta(
      gradA: Color(0xFF43A047),
      gradB: Color(0xFF1B5E20),
      icono: Icons.nature_people_rounded,
      glowColor: Color(0xFF66BB6A),
    ),
  };

  // ── Texto para compartir ───────────────────────────────────────────────────

  String get _textoCompartir =>
      '🌿 Mi certificación Veltur:\n'
      '${widget.stats.nivelActual.etiqueta}\n'
      '${widget.stats.expedicionesLimpias} expediciones seguras · '
      '${widget.stats.kgCo2Ahorrado.toStringAsFixed(1)} kg CO2 compensado\n'
      '#Veltur #TurismoSeguro #GuardianVerde';

  void _compartir() {
    Clipboard.setData(ClipboardData(text: _textoCompartir));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '¡Insignia copiada! Pégala en tus redes sociales 🚀',
        ),
        backgroundColor: _paleta.gradB,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = _paleta;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [p.gradA, p.gradB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: p.glowColor.withAlpha(100),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Cabecera ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícono con halo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(p.icono, color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CERTIFICACIÓN VELTUR',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.stats.nivelActual.etiqueta,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divisor ──────────────────────────────────────────────────
              Divider(color: Colors.white.withAlpha(40), height: 1),

              // ── Estadísticas ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        valor: '${widget.stats.expedicionesLimpias}',
                        label: 'Viajes\nseguros',
                        icono: Icons.check_circle_outline_rounded,
                      ),
                    ),
                    _VertDivider(),
                    Expanded(
                      child: _StatTile(
                        valor:
                            '${widget.stats.kgCo2Ahorrado.toStringAsFixed(1)} kg',
                        label: 'CO₂\ncompensado',
                        icono: Icons.air_rounded,
                      ),
                    ),
                    _VertDivider(),
                    Expanded(
                      child: _StatTile(
                        valor:
                            '${(widget.stats.tasaExito * 100).toStringAsFixed(0)}%',
                        label: 'Tasa de\néxito',
                        icono: Icons.trending_up_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Barra de progreso ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    widget.stats.nivelActual == NivelEco.oro
                        ? _MensajeOro()
                        : _BarraProgreso(
                          animacion: _progressAnim,
                          expedicionesLimpias: widget.stats.expedicionesLimpias,
                          siguienteNivel: widget.stats.siguienteNivel!,
                          faltanExpediciones:
                              widget.stats.expedicionesParaSiguienteNivel,
                        ),
              ),

              const SizedBox(height: 16),

              // ── Botón compartir ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: OutlinedButton.icon(
                  onPressed: _compartir,
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text(
                    'Compartir mi insignia',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets privados ───────────────────────────────────────────────────────

class _NivelPaleta {
  final Color gradA;
  final Color gradB;
  final IconData icono;
  final Color glowColor;
  const _NivelPaleta({
    required this.gradA,
    required this.gradB,
    required this.icono,
    required this.glowColor,
  });
}

class _StatTile extends StatelessWidget {
  final String valor;
  final String label;
  final IconData icono;
  const _StatTile({
    required this.valor,
    required this.label,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 52, color: Colors.white24);
}

class _BarraProgreso extends StatelessWidget {
  final Animation<double> animacion;
  final int expedicionesLimpias;
  final NivelEco siguienteNivel;
  final int faltanExpediciones;

  const _BarraProgreso({
    required this.animacion,
    required this.expedicionesLimpias,
    required this.siguienteNivel,
    required this.faltanExpediciones,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Faltan $faltanExpediciones expediciones para ${siguienteNivel.etiqueta}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: animacion,
          builder:
              (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: animacion.value,
                  backgroundColor: Colors.black26,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 7,
                ),
              ),
        ),
      ],
    );
  }
}

class _MensajeOro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            '¡Máximo nivel de excelencia alcanzado!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
