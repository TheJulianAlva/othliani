import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ====================================================
// CORE - Servicios globales
// ====================================================
import '../services/pexels_service.dart';

// ====================================================
// FEATURES - Agencia
// ====================================================

// Shared (Datasources compartidos)
import '../../features/agencia/shared/data/datasources/mock_agencia_datasource.dart';
import '../../features/agencia/shared/data/datasources/agencia_datasource.dart';

// Auth
import '../../features/agencia/auth/data/repositories/auth_repository_impl.dart';
import '../../features/agencia/auth/domain/repositories/auth_repository.dart';
import '../../features/agencia/auth/presentation/blocs/login/login_bloc.dart';

// Dashboard
import '../../features/agencia/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/agencia/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/agencia/dashboard/domain/usecases/get_dashboard_data.dart';
import '../../features/agencia/dashboard/blocs/dashboard/dashboard_bloc.dart';

// Trips
import '../../features/agencia/trips/data/repositories/trip_repository_impl.dart';
import '../../features/agencia/trips/domain/repositories/trip_repository.dart';
import '../../features/agencia/trips/blocs/viajes/viajes_bloc.dart';
import '../../features/agencia/trips/blocs/detalle_viaje/detalle_viaje_bloc.dart';
import '../../features/agencia/trips/blocs/trip_creation/trip_creation_cubit.dart';

// Users
import '../../features/agencia/users/data/repositories/user_repository_impl.dart';
import '../../features/agencia/users/domain/repositories/user_repository.dart';
import '../../features/agencia/users/blocs/usuarios/usuarios_bloc.dart';

// Audit
import '../../features/agencia/audit/data/repositories/audit_repository_impl.dart';
import '../../features/agencia/audit/domain/repositories/audit_repository.dart';
import '../../features/agencia/audit/blocs/auditoria/auditoria_bloc.dart';

// Shared Blocs
import '../../features/agencia/shared/blocs/sync/sync_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // ====================================================
  // 1. EXTERNAL / CORE (Servicios globales)
  // ====================================================
  sl.registerLazySingleton(() => PexelsService());
  sl.registerLazySingleton(() => Connectivity());

  // ====================================================
  // 2. DATA SOURCES (Fuentes de datos compartidas)
  // ====================================================
  sl.registerLazySingleton(() => MockAgenciaDataSource());
  sl.registerLazySingleton<AgenciaDataSource>(
    () => AgenciaMockDataSourceImpl(sl()),
  );

  // ====================================================
  // 3. REPOSITORIOS (Data Layer)
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
  // 4. USE CASES (Application Layer)
  // ====================================================
  sl.registerLazySingleton(() => GetDashboardData(sl()));

  // ====================================================
  // 5. BLOCS / CUBITS (Presentation Layer)
  // ====================================================

  // Auth
  sl.registerFactory(() => LoginBloc(repository: sl()));

  // Dashboard
  sl.registerFactory(() => DashboardBloc(getDashboardData: sl()));

  // Trips
  sl.registerFactory(() => ViajesBloc(repository: sl()));
  sl.registerFactory(() => DetalleViajeBloc(repository: sl()));
  sl.registerFactory(() => TripCreationCubit(repository: sl()));

  // Users
  sl.registerFactory(() => UsuariosBloc(repository: sl()));

  // Audit
  sl.registerFactory(() => AuditoriaBloc(repository: sl()));

  // Shared
  sl.registerFactory(() => SyncBloc(connectivity: sl()));
}
