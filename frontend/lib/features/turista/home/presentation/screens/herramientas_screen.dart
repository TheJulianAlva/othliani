import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/tools/presentation/screens/currency_converter_screen.dart';
import 'traductor_screen.dart';
import 'traductor_voz_screen.dart';
import 'divisor_gastos_screen.dart';

class HerramientasScreen extends StatelessWidget {
  const HerramientasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tools = [
      _ToolItem(
        title: l10n.currencyConverter,
        description: l10n.currencyConverterDesc,
        icon: Icons.currency_exchange_rounded,
        gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
        destination: const CurrencyConverterScreen(),
        emoji: '💱',
      ),
      _ToolItem(
        title: l10n.translatorTitle,
        description: l10n.translatorDesc,
        icon: Icons.camera_alt_rounded,
        gradientColors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
        destination: const TraductorScreen(),
        emoji: '📸',
      ),
      _ToolItem(
        title: l10n.voiceTranslatorTitle,
        description: l10n.voiceTranslatorDesc,
        icon: Icons.record_voice_over_rounded,
        gradientColors: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
        destination: const TraductorVozScreen(),
        emoji: '🎙️',
      ),
      _ToolItem(
        title: l10n.expenseSplitterTitle,
        description: l10n.expenseSplitterDesc,
        icon: Icons.receipt_long_rounded,
        gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        destination: const DivisorGastosScreen(),
        emoji: '🧾',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: tools.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _FloatingToolCard(item: tools[index]),
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.destination,
    required this.emoji,
  });
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Widget destination;
  final String emoji;
}

class _FloatingToolCard extends StatefulWidget {
  const _FloatingToolCard({required this.item});
  final _ToolItem item;

  @override
  State<_FloatingToolCard> createState() => _FloatingToolCardState();
}

class _FloatingToolCardState extends State<_FloatingToolCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item.gradientColors.first;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => widget.item.destination),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _pressed ? 0.35 : 0.18),
                blurRadius: _pressed ? 24 : 16,
                spreadRadius: _pressed ? 2 : 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono con gradiente flotante
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.item.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.item.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Flecha animada
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
