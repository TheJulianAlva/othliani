import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes_turista.dart';
import '../../core/theme/app_constants.dart';
import '../widgets/home_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OthliAni Turista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(RoutesTurista.profile),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido', style: AppTextStyles.heading),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                children: [
                  HomeCard(
                    icon: Icons.directions_bus,
                    title: 'Mi Viaje',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Detalles del viaje próximamente'),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    icon: Icons.calendar_today,
                    title: 'Itinerario',
                    onTap: () => context.push(RoutesTurista.itinerary),
                  ),
                  HomeCard(
                    icon: Icons.map,
                    title: 'Mapa',
                    onTap: () => context.push(RoutesTurista.map),
                  ),
                  HomeCard(
                    icon: Icons.group,
                    title: 'Chat Grupal',
                    onTap: () => context.push(RoutesTurista.chat),
                  ),
                  HomeCard(
                    icon: Icons.radio,
                    title: 'Walkie-Talkie',
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Walkie-Talkie próximamente'),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    icon: Icons.currency_exchange,
                    title: 'Cambio de Moneda',
                    color: Colors.green,
                    onTap: () => context.push(RoutesTurista.currencyConverter),
                  ),
                  HomeCard(
                    icon: Icons.settings,
                    title: 'Configuración',
                    onTap: () => context.push(RoutesTurista.config),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
