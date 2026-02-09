import 'package:get_it/get_it.dart';
import 'data/datasources/mock_agencia_datasource.dart';
import 'data/datasources/agencia_mock_data_source.dart';
import 'data/repositories/agencia_repository_impl.dart';
import 'domain/repositories/agencia_repository.dart';
import 'domain/usecases/get_dashboard_data.dart';
import 'presentation_agencia/blocs/dashboard/dashboard_bloc.dart';
import 'presentation_agencia/blocs/viajes/viajes_bloc.dart';
import 'presentation_agencia/blocs/detalle_viaje/detalle_viaje_bloc.dart';
import 'presentation_agencia/blocs/usuarios/usuarios_bloc.dart';
import 'presentation_agencia/blocs/auditoria/auditoria_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Dashboard
  // Bloc
  sl.registerFactory(() => DashboardBloc(getDashboardData: sl()));

  // New features
  sl.registerFactory(() => ViajesBloc(repository: sl()));
  sl.registerFactory(() => DetalleViajeBloc(repository: sl()));
  sl.registerFactory(() => UsuariosBloc(repository: sl()));
  sl.registerFactory(() => AuditoriaBloc(repository: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetDashboardData(sl()));

  // Repository
  sl.registerLazySingleton<AgenciaRepository>(
    () => AgenciaRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<AgenciaDataSource>(
    () => AgenciaMockDataSourceImpl(sl()),
  );

  //! Core
  sl.registerLazySingleton(() => MockAgenciaDataSource());
}
