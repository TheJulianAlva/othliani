import 'package:equatable/equatable.dart';

abstract class ItineraryEvent extends Equatable {
  const ItineraryEvent();

  @override
  List<Object> get props => [];
}

class LoadItinerary extends ItineraryEvent {
  final String tripId;

  const LoadItinerary(this.tripId);

  @override
  List<Object> get props => [tripId];
}
