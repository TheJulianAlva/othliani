import 'package:get_it/get_it.dart';
import 'package:frontend/core/network/dio_client.dart';

import 'package:frontend/features/turista/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/turista/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/turista/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/turista/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/login_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/register_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/forgot_password_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ! Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ! Features - Turista
  // Auth
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthMockDataSource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));

  // Blocs
  sl.registerFactory(() => LoginCubit(loginUseCase: sl()));
  sl.registerFactory(() => RegisterCubit(registerUseCase: sl()));
  sl.registerFactory(() => ForgotPasswordCubit(forgotPasswordUseCase: sl()));
}
