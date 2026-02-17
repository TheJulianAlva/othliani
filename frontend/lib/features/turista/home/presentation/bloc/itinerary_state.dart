import 'package:equatable/equatable.dart';
import 'package:frontend/features/turista/home/domain/entities/itinerary_item.dart';

abstract class ItineraryState extends Equatable {
  const ItineraryState();

  @override
  List<Object> get props => [];
}

class ItineraryInitial extends ItineraryState {}

class ItineraryLoading extends ItineraryState {}

class ItineraryLoaded extends ItineraryState {
  final List<ItineraryItem> items;

  const ItineraryLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class ItineraryError extends ItineraryState {
  final String message;

  const ItineraryError(this.message);

  @override
  List<Object> get props => [message];
}
