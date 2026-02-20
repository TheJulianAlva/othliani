import 'package:frontend/core/di/service_locator.dart';

import 'package:frontend/features/agencia/shared/data/datasources/agencia_datasource.dart';
import 'package:frontend/features/agencia/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/agencia/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/agencia/auth/presentation/blocs/login/login_bloc.dart';
import 'package:frontend/features/agencia/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:frontend/features/agencia/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:frontend/features/agencia/dashboard/domain/usecases/get_dashboard_data.dart';
import 'package:frontend/features/agencia/dashboard/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:frontend/features/agencia/trips/data/repositories/trip_repository_impl.dart';
import 'package:frontend/features/agencia/trips/domain/repositories/trip_repository.dart';
import 'package:frontend/features/agencia/trips/presentation/blocs/viajes/viajes_bloc.dart';
import 'package:frontend/features/agencia/trips/presentation/blocs/detalle_viaje/detalle_viaje_bloc.dart';
import 'package:frontend/features/agencia/trips/presentation/blocs/trip_creation/trip_creation_cubit.dart';
import 'package:frontend/features/agencia/trips/presentation/blocs/itinerary_builder/itinerary_builder_cubit.dart';
import 'package:frontend/features/agencia/users/data/repositories/user_repository_impl.dart';
import 'package:frontend/features/agencia/users/domain/repositories/user_repository.dart';
import 'package:frontend/features/agencia/users/presentation/blocs/usuarios/usuarios_bloc.dart';
import 'package:frontend/features/agencia/audit/data/repositories/audit_repository_impl.dart';
import 'package:frontend/features/agencia/audit/domain/repositories/audit_repository.dart';
import 'package:frontend/features/agencia/audit/presentation/blocs/auditoria/auditoria_bloc.dart';
import 'package:frontend/features/agencia/shared/presentation/blocs/sync/sync_bloc.dart';

Future<void> initAgenciaDependencies() async {
  // ====================================================
  // 1. DATA SOURCES (Fuentes de datos compartidas)
  // ====================================================

  sl.registerLazySingleton<AgenciaDataSource>(
    () => AgenciaMockDataSourceImpl(sl()),
  );

  // ====================================================
  // 2. REPOSITORIOS (Data Layer)
  // ====================================================

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // Dashboard Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // Trip Repository
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(sl(), sl()),
  );

  // User Repository
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  // Audit Repository
  sl.registerLazySingleton<AuditRepository>(() => AuditRepositoryImpl(sl()));

  // ====================================================
  // 3. USE CASES (Application Layer)
  // ====================================================
  sl.registerLazySingleton(() => GetDashboardData(sl()));

  // ====================================================
  // 4. BLOCS / CUBITS (Presentation Layer)
  // ====================================================

  // Auth
  sl.registerFactory(() => LoginBloc(repository: sl()));

  // Dashboard
  sl.registerFactory(() => DashboardBloc(getDashboardData: sl()));

  // Trips
  sl.registerFactory(() => ViajesBloc(repository: sl()));
  sl.registerFactory(() => DetalleViajeBloc(repository: sl()));
  sl.registerFactory(
    () => TripCreationCubit(
      repository: sl(),
      localDataSource: sl(),
      unsavedChangesService: sl(),
    ),
  );
  sl.registerFactory(
    () => ItineraryBuilderCubit(
      repository: sl(),
      localDataSource: sl(),
      unsavedChangesService: sl(),
    ),
  );

  // Users
  sl.registerFactory(() => UsuariosBloc(repository: sl()));

  // Audit
  sl.registerFactory(() => AuditoriaBloc(repository: sl()));

  // Shared
  sl.registerFactory(() => SyncBloc(connectivity: sl()));
}
