import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/turista/home/domain/usecases/get_itinerary_usecase.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_event.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_state.dart';

class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  final GetItineraryUseCase getItineraryUseCase;

  ItineraryBloc({required this.getItineraryUseCase})
    : super(ItineraryInitial()) {
    on<LoadItinerary>(_onLoadItinerary);
  }

  Future<void> _onLoadItinerary(
    LoadItinerary event,
    Emitter<ItineraryState> emit,
  ) async {
    emit(ItineraryLoading());
    final result = await getItineraryUseCase(event.tripId);
    result.fold(
      (failure) => emit(ItineraryError(failure.message)),
      (items) => emit(ItineraryLoaded(items)),
    );
  }
}
