import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:frontend/presentation_guia/screens/pantalla_mapa_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_chat_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_alertas_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_perfil_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_itinerario_guia.dart';

// Placeholder for Home Tab content (Trip List)
class HomeTabGuia extends StatelessWidget {
  const HomeTabGuia({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Lista de Viajes (Guía)'));
  }
}

class HomeScreenGuia extends StatefulWidget {
  const HomeScreenGuia({super.key});

  @override
  State<HomeScreenGuia> createState() => _HomeScreenGuiaState();
}

class _HomeScreenGuiaState extends State<HomeScreenGuia>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<IconData> _iconList = [
    Icons.home,
    Icons.map,
    Icons.chat,
    Icons.notifications,
    Icons.person,
  ];

  final List<Widget> _screens = [
    const HomeTabGuia(), // Or Itinerary/Trip List
    const MapScreenGuia(),
    const ChatScreenGuia(),
    const AlertsScreenGuia(),
    const ProfileScreenGuia(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Labels for the tabs. Note: We might need to add specific keys to arb files if they don't exist.
    // Reusing existing keys where possible or using temporary strings if keys are missing.
    final labelList = [
      l10n.home, // Assuming 'home' key exists, or 'inicio'
      l10n.map,
      l10n.chat,
      'Alertas', // Need to add key for Alerts
      l10n.profile, // Assuming 'profile' key exists, or 'perfil'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(l10n)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Don't show back button on Home
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive 
              ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor 
              : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], size: 24, color: color),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labelList[index],
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        activeIndex: _currentIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 16,
        rightCornerRadius: 16,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        splashSpeedInMilliseconds: 300,
        elevation: 8,
        shadow: BoxShadow(
          offset: const Offset(0, -2),
          blurRadius: 12,
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 0:
        return 'Mis Viajes'; // TODO: Add l10n key
      case 1:
        return l10n.map;
      case 2:
        return l10n.chat;
      case 3:
        return 'Alertas'; // TODO: Add l10n key
      case 4:
        return l10n.profile; // TODO: Add l10n key
      default:
        return 'OthliAni - Guía';
    }
  }
}
