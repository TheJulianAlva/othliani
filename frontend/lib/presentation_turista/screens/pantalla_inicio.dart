import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../widgets/walkie_talkie_button.dart';
import 'pantalla_inicio_viaje.dart';
import 'pantalla_chat.dart';
import 'pantalla_configuracion.dart';
import 'pantalla_mapa.dart';
import 'pantalla_perfil.dart';
import 'pantalla_conversor_divisas.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<IconData> _iconList = [
    Icons.luggage,
    Icons.chat_bubble_outline,
    Icons.currency_exchange,
    Icons.settings_outlined,
    Icons.map_outlined,
  ];

  final List<Widget> _screens = [
    const TripHomeScreen(),
    const ChatScreen(),
    const CurrencyConverterScreen(),
    const ConfigScreen(),
    const MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelList = [
      l10n.itinerary,
      l10n.chat,
      l10n.currency,
      l10n.config,
      l10n.map,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(l10n)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          // Walkie-talkie button always on top
          const WalkieTalkieButton(),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color =
              isActive
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor;
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
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
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
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
        return l10n.myTrips;
      case 1:
        return l10n.chat;
      case 2:
        return l10n.currencyConverter;
      case 3:
        return l10n.configuration;
      case 4:
        return l10n.map;
      default:
        return l10n.appTitle;
    }
  }
}
