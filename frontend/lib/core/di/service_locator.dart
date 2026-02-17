import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/services/pexels_service.dart';

final sl = GetIt.instance;

Future<void> initSharedDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton(() => PexelsService());
}
