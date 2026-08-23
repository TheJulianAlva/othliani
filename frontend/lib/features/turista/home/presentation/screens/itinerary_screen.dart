import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart'
    show EmptyStateWidget;
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_bloc.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_event.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_state.dart';
import '../widgets/itinerary_event_card.dart';

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
      body: BlocBuilder<ItineraryBloc, ItineraryState>(
        builder: (context, state) {
          if (state is ItineraryLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state is ItineraryError) {
            final tokens = VelturTokens.of(context);
            final theme = Theme.of(context);
            return Center(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: tokens.dangerSoft,
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: tokens.danger, size: 40),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.danger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ItineraryLoaded) {
            if (state.items.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.event_busy_outlined,
                message: 'No hay eventos planificados.',
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
    );
  }
}
