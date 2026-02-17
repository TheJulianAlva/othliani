import 'package:flutter/material.dart';
import '../../widgets/settings/profile_settings.dart';
import '../../widgets/settings/security_settings.dart';
import '../../widgets/settings/subscription_settings.dart';
import '../../widgets/settings/notification_settings.dart';
import '../../widgets/settings/legal_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  final List<Widget> _contentWidgets = [
    const ProfileSettings(),
    const SecuritySettings(),
    const SubscriptionSettings(),
    const NotificationSettings(),
    const LegalSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          width: double.infinity,
          child: const Text(
            'Configuración del Sistema',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),

        // Body
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Side Menu
              Container(
                width: 280,
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  children: [
                    _buildMenuItem(
                      0,
                      'Perfil Agencia',
                      Icons.business_outlined,
                      'General',
                    ),
                    _buildMenuItem(
                      1,
                      'Seguridad Global',
                      Icons.security_outlined,
                      'Parámetros',
                    ),
                    _buildMenuItem(
                      2,
                      'Suscripción',
                      Icons.card_membership_outlined,
                      'Plan y Pagos',
                    ),
                    _buildMenuItem(
                      3,
                      'Notificaciones',
                      Icons.notifications_none_outlined,
                      'Alertas',
                    ),
                    _buildMenuItem(
                      4,
                      'Legal & Privacidad',
                      Icons.gavel_outlined,
                      'Cumplimiento',
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),

              // Content Area
              Expanded(
                child: Container(
                  color: const Color(0xFFF4F6F8), // Light grey background
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Card(
                        margin: const EdgeInsets.all(24),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        color: Colors.white,
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _contentWidgets,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    int index,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedIndex == index;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedIndex = index),
        leading: Icon(
          icon,
          color: isSelected ? primaryColor : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                isSelected
                    ? primaryColor.withValues(alpha: 0.8)
                    : Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
