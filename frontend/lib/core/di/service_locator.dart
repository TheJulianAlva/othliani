import 'package:get_it/get_it.dart';
import 'package:frontend/core/network/dio_client.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ! Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ! Features - Turista
  // Auth
  // Data Sources
  // Repositories
  // Use Cases
  // Blocs
}
