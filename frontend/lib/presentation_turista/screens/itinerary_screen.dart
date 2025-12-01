import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';
import '../widgets/itinerary_event_card.dart';
import '../widgets/walkie_talkie_button.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itinerario')),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ItineraryEventCard(
                time: '${index + 8}:00',
                title: 'Evento del itinerario ${index + 1}',
                description:
                    'Descripción breve del lugar o actividad a realizar.',
              );
            },
          ),
          const WalkieTalkieButton(),
        ],
      ),
    );
  }
}
