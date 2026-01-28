import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_dashboard_stats.dart';
import '../../../../domain/entities/dashboard_stats.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats getDashboardStats;

  DashboardBloc({required this.getDashboardStats}) : super(DashboardInitial()) {
    on<LoadDashboardStats>((event, emit) async {
      emit(DashboardLoading());
      final result = await getDashboardStats();
      result.fold(
        (failure) => emit(DashboardError('Error al cargar datos')),
        (stats) => emit(DashboardLoaded(stats)),
      );
    });
  }
}
