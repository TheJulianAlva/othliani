import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/walkie_talkie_button.dart';
import 'trip_home_screen.dart';
import 'chat_screen.dart';
import 'config_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'currency_converter_screen.dart';

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

  final List<String> _labelList = ['viaje', 'chat', 'moneda', 'config', 'mapa'];

  final List<Widget> _screens = [
    const TripHomeScreen(),
    const ChatScreen(),
    const CurrencyConverterScreen(),
    const ConfigScreen(),
    const MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
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
          final color = isActive ? AppColors.primary : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                _labelList[index],
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
        backgroundColor: Colors.white,
        splashColor: AppColors.primary.withValues(alpha: 0.2),
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

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Mi Viaje';
      case 1:
        return 'Chat Grupal';
      case 2:
        return 'Cambio de Moneda';
      case 3:
        return 'Configuración';
      case 4:
        return 'Mapa Interactivo';
      default:
        return 'OthliAni';
    }
  }
}
