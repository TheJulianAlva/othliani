import 'package:get_it/get_it.dart';
import 'core/mock/mock_database.dart';
import 'data/datasources/agencia_mock_data_source.dart';
import 'data/repositories/agencia_repository_impl.dart';
import 'domain/repositories/agencia_repository.dart';
import 'domain/usecases/get_dashboard_stats.dart';
import 'presentation_agencia/blocs/dashboard/dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Dashboard
  // Bloc
  sl.registerFactory(() => DashboardBloc(getDashboardStats: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetDashboardStats(sl()));

  // Repository
  sl.registerLazySingleton<AgenciaRepository>(
    () => AgenciaRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<AgenciaDataSource>(
    () => AgenciaMockDataSourceImpl(sl()),
  );

  //! Core
  sl.registerLazySingleton(() => MockDatabase());
}
