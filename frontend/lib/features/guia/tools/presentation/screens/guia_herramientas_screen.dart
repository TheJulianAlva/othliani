import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/core/tools/presentation/screens/currency_converter_screen.dart';
import 'package:frontend/features/guia/tools/presentation/widgets/tool_card.dart';
import 'package:frontend/features/guia/shared/widgets/guia_custom_app_bar.dart';

class GuiaHerramientasScreen extends StatelessWidget {
  const GuiaHerramientasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    //    final theme = Theme.of(context);

    return Scaffold(
      appBar: GuiaCustomAppBar(
        title: l10n.tools,
        subtitle: 'Utilidades Operativas',
        icon: Icons.build_rounded,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── COMUNICACIÓN ──────────────────────────────────────────────
          _SectionTitle(title: 'Comunicación'),
          ToolCard(
            title: 'Voz con Central',
            description: 'Canal de radio directo con la agencia.',
            icon: Icons.settings_voice_rounded,
            color: Colors.blue.shade800,
            onTap: () => _notImplemented(context),
          ),
          const SizedBox(height: AppSpacing.md),
          ToolCard(
            title: 'Chat Agencia',
            description: 'Mensajería interna con el equipo de soporte.',
            icon: Icons.forum_rounded,
            color: Colors.blue.shade600,
            onTap: () => context.push(RoutesGuia.chat),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── SEGURIDAD Y AUDITORÍA ─────────────────────────────────────
          _SectionTitle(title: 'Seguridad y Auditoría'),
          ToolCard(
            title: 'Bitácora de Seguridad',
            description: 'Registra incidentes operativos del día.',
            icon: Icons.security_rounded,
            color: Colors.amber.shade700,
            onTap: () => context.push(RoutesGuia.bitacora),
          ),
          const SizedBox(height: AppSpacing.md),
          ToolCard(
            title: 'Caja Negra (Evidencia)',
            description: 'Registro inmutable de logs y geolocalización.',
            icon: Icons.shield_rounded,
            color: Colors.grey.shade800,
            onTap: () => context.push(RoutesGuia.expeditionLog),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── UTILIDADES ────────────────────────────────────────────────
          _SectionTitle(title: 'Utilidades'),
          ToolCard(
            title: l10n.currencyConverterTitle,
            description: l10n.currencyConverterDesc,
            icon: Icons.currency_exchange_rounded,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CurrencyConverterScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ToolCard(
            title: 'Divisor de Cuentas',
            description: 'Calcula gastos compartidos fácilmente.',
            icon: Icons.receipt_long_rounded,
            color: Colors.teal,
            onTap: () => _notImplemented(context),
          ),
        ],
      ),
    );
  }

  void _notImplemented(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Herramienta en desarrollo')));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
