import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_bloc.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_event.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_state.dart';
import '../widgets/itinerary_event_card.dart';
import '../widgets/walkie_talkie_button.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              sl<ItineraryBloc>()..add(
                const LoadItinerary('current_trip'),
              ), // Using mock trip ID
      child: const _ItineraryView(),
    );
  }
}

class _ItineraryView extends StatelessWidget {
  const _ItineraryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itinerario')),
      body: Stack(
        children: [
          BlocBuilder<ItineraryBloc, ItineraryState>(
            builder: (context, state) {
              if (state is ItineraryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItineraryError) {
                return Center(child: Text(state.message));
              } else if (state is ItineraryLoaded) {
                if (state.items.isEmpty) {
                  return const Center(
                    child: Text('No hay eventos planificados.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return ItineraryEventCard(
                      time:
                          '${item.startTime.hour}:${item.startTime.minute.toString().padLeft(2, '0')}',
                      title: item.title,
                      description: item.description,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const WalkieTalkieButton(),
        ],
      ),
    );
  }
}
