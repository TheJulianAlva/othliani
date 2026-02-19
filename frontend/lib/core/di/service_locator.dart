import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/agencia/trips/data/datasources/trip_local_data_source.dart'; // 💾 Persistencia Local
import '../../features/agencia/shared/data/datasources/mock_agencia_datasource.dart'; // 📌 Necesario para MockAgenciaDataSource
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/services/pexels_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend/core/services/unsaved_changes_service.dart';

final sl = GetIt.instance;

Future<void> initSharedDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => MockAgenciaDataSource());
  sl.registerLazySingleton(
    () => TripLocalDataSource(),
  ); // 💾 Persistencia Local
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton(() => PexelsService());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => UnsavedChangesService());
}
