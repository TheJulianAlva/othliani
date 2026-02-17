import 'package:get_it/get_it.dart';
import 'features/agencia/shared/data/datasources/mock_agencia_datasource.dart';
import 'data/datasources/agencia_mock_data_source.dart';
import 'features/agencia/dashboard/data/repositories/dashboard_repository_impl.dart'; // ✨ New Repo Impl
import 'features/agencia/dashboard/domain/repositories/dashboard_repository.dart'; // ✨ New Repo Interface
import 'features/agencia/trips/data/repositories/trip_repository_impl.dart';
import 'features/agencia/trips/domain/repositories/trip_repository.dart';
import 'features/agencia/users/data/repositories/user_repository_impl.dart';
import 'features/agencia/users/domain/repositories/user_repository.dart';
import 'features/agencia/audit/data/repositories/audit_repository_impl.dart';
import 'features/agencia/audit/domain/repositories/audit_repository.dart';
import 'domain/usecases/get_dashboard_data.dart';
import 'features/agencia/dashboard/blocs/dashboard/dashboard_bloc.dart'; // ✨ New Path
import 'features/agencia/trips/blocs/viajes/viajes_bloc.dart'; // ✨ Nuevo Path
import 'features/agencia/trips/blocs/detalle_viaje/detalle_viaje_bloc.dart'; // ✨ Nuevo Path
import 'features/agencia/users/blocs/usuarios/usuarios_bloc.dart';
import 'features/agencia/audit/blocs/auditoria/auditoria_bloc.dart';
import 'features/agencia/trips/blocs/trip_creation/trip_creation_cubit.dart'; // ✨ Nuevo Path
import 'features/agencia/shared/blocs/sync/sync_bloc.dart';
import 'core/services/pexels_service.dart';
import 'features/agencia/auth/data/repositories/auth_repository_impl.dart';
import 'features/agencia/auth/domain/repositories/auth_repository.dart';
import 'features/agencia/auth/presentation/blocs/login/login_bloc.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

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
  sl.registerFactory(() => TripCreationCubit(repository: sl()));
  sl.registerFactory(() => SyncBloc(connectivity: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetDashboardData(sl()));

  // Repository (old AgenciaRepository removed - now using modular repositories)

  // ✨ Dashboard Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // ✨ Trip Repository
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(sl(), sl()),
  );

  // ✨ User Repository
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  // ✨ Audit Repository
  sl.registerLazySingleton<AuditRepository>(() => AuditRepositoryImpl(sl()));

  // ✨ Auth Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // ✨ Login Bloc
  sl.registerFactory(() => LoginBloc(repository: sl()));

  // Data sources
  sl.registerLazySingleton<AgenciaDataSource>(
    () => AgenciaMockDataSourceImpl(sl()),
  );

  //! Core
  sl.registerLazySingleton(() => MockAgenciaDataSource());

  //! External Services
  sl.registerLazySingleton(() => PexelsService());
  sl.registerLazySingleton(() => Connectivity());
}
