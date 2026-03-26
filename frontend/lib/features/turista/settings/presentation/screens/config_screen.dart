import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/locale_cubit.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/theme_cubit.dart';
import 'accessibility_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Idioma ────────────────────────────────────────────────
        BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return _SettingCard(
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: l10n.language,
              subtitle: locale.languageCode == 'es' ? l10n.spanish : l10n.english,
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Color(0xFF9CA3AF),
              ),
              onTap: () => _showLanguageDialog(context, l10n),
            );
          },
        ),
        const SizedBox(height: 14),

        // ── Tema ──────────────────────────────────────────────────
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDark = themeMode == ThemeMode.dark;
            return _SettingCard(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: l10n.theme,
              subtitle: isDark ? l10n.darkTheme : l10n.lightTheme,
              trailing: Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: isDark,
                  activeColor: const Color(0xFF3B82F6),
                  onChanged: (v) => context.read<ThemeCubit>().setTheme(v),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        // ── Accesibilidad ─────────────────────────────────────────
        _SettingCard(
          icon: Icons.accessibility_new_rounded,
          iconColor: const Color(0xFF8B5CF6),
          title: l10n.accessibility,
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: Color(0xFF9CA3AF),
          ),
          onTap: () => _showAccessibilityDialog(context),
        ),
        const SizedBox(height: 14),

        // ── Notificaciones ────────────────────────────────────────
        _SettingCard(
          icon: Icons.notifications_rounded,
          iconColor: const Color(0xFF10B981),
          title: l10n.notifications,
          trailing: Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: true,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Configurar notificaciones próximamente'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          SimpleDialogOption(
            onPressed: () {
              context.read<LocaleCubit>().setLocale(const Locale('es'));
              Navigator.pop(dialogContext);
            },
            child: Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 8),
                Text(l10n.spanish),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              context.read<LocaleCubit>().setLocale(const Locale('en'));
              Navigator.pop(dialogContext);
            },
            child: Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 8),
                Text(l10n.english),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAccessibilityDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccessibilityScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

// ─── Card flotante de configuración ──────────────────────────────────────────
class _SettingCard extends StatefulWidget {
  const _SettingCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<_SettingCard> createState() => _SettingCardState();
}

class _SettingCardState extends State<_SettingCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.iconColor.withValues(alpha: _pressed ? 0.2 : 0.1),
                blurRadius: _pressed ? 20 : 12,
                spreadRadius: _pressed ? 1 : 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Ícono con fondo de color suave
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Título y subtítulo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
