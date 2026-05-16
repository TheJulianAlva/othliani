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
        destination: const CurrencyConverterScreen(),
        emoji: '💱',
      ),
      _ToolItem(
        title: l10n.translatorTitle,
        description: l10n.translatorDesc,
        icon: Icons.camera_alt_rounded,
        destination: const TraductorScreen(),
        emoji: '📸',
      ),
      _ToolItem(
        title: l10n.voiceTranslatorTitle,
        description: l10n.voiceTranslatorDesc,
        icon: Icons.record_voice_over_rounded,
        destination: const TraductorVozScreen(),
        emoji: '🎙️',
      ),
      _ToolItem(
        title: l10n.expenseSplitterTitle,
        description: l10n.expenseSplitterDesc,
        icon: Icons.receipt_long_rounded,
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
    required this.destination,
    required this.emoji,
  });
  final String title;
  final String description;
  final IconData icon;
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
    final primaryColor = Theme.of(context).primaryColor;

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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      widget.item.icon,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

