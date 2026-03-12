import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class TraductorScreen extends StatelessWidget {
  const TraductorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translatorTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.translate_rounded, size: 80, color: Colors.blueAccent.withValues(alpha: 0.4)),
            const SizedBox(height: 20),
            Text(
              l10n.translatorTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.comingSoon,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              '(${l10n.translatorDesc})',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
