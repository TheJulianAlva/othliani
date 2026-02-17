import 'package:equatable/equatable.dart';
import 'package:frontend/features/turista/home/domain/entities/trip.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  final Trip trip;
  final String selectedDay;
  final String selectedFilter;

  const TripLoaded({
    required this.trip,
    required this.selectedDay,
    this.selectedFilter = 'Todas',
  });

  TripLoaded copyWith({
    Trip? trip,
    String? selectedDay,
    String? selectedFilter,
  }) {
    return TripLoaded(
      trip: trip ?? this.trip,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [trip, selectedDay, selectedFilter];
}

class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}
