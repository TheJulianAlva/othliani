import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/home/domain/usecases/get_current_trip_usecase.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_event.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final GetCurrentTripUseCase getCurrentTripUseCase;

  TripBloc({required this.getCurrentTripUseCase}) : super(TripInitial()) {
    on<TripStarted>(_onStarted);
    on<TripDayChanged>(_onDayChanged);
    on<TripFilterChanged>(_onFilterChanged);
  }

  Future<void> _onStarted(TripStarted event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await getCurrentTripUseCase(NoParams());
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) => emit(
        TripLoaded(
          trip: trip,
          selectedDay: trip.days.isNotEmpty ? trip.days.first : '',
        ),
      ),
    );
  }

  void _onDayChanged(TripDayChanged event, Emitter<TripState> emit) {
    if (state is TripLoaded) {
      emit((state as TripLoaded).copyWith(selectedDay: event.day));
    }
  }

  void _onFilterChanged(TripFilterChanged event, Emitter<TripState> emit) {
    if (state is TripLoaded) {
      emit((state as TripLoaded).copyWith(selectedFilter: event.filter));
    }
  }
}
