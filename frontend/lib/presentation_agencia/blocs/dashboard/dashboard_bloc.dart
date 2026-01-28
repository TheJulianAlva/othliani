import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_dashboard_data.dart';
import '../../../../domain/entities/dashboard_data.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc({required this.getDashboardData}) : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());
      final result = await getDashboardData();
      result.fold(
        (failure) => emit(DashboardError('Error al cargar datos')),
        (data) => emit(DashboardLoaded(data)),
      );
    });
  }
}
