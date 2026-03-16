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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          _ToolCard(
            title: l10n.currencyConverter,
            description: l10n.currencyConverterDesc,
            icon: Icons.currency_exchange_rounded,
            color: Colors.green,
            destination: const CurrencyConverterScreen(),
          ),
          const SizedBox(height: 16),
          _ToolCard(
            title: l10n.translatorTitle,
            description: l10n.translatorDesc,
            icon: Icons.camera_alt_rounded, // Se cambió el icono
            color: Colors.blueAccent,
            destination: const TraductorScreen(),
          ),
          const SizedBox(height: 16),
          _ToolCard(
            title: l10n.voiceTranslatorTitle,
            description: l10n.voiceTranslatorDesc,
            icon: Icons.record_voice_over_rounded,
            color: Colors.deepPurple,
            destination: const TraductorVozScreen(),
          ),
          const SizedBox(height: 16),
          _ToolCard(
            title: l10n.expenseSplitterTitle,
            description: l10n.expenseSplitterDesc,
            icon: Icons.receipt_long_rounded,
            color: Colors.orange,
            destination: const DivisorGastosScreen(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.destination,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
