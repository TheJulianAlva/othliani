import 'package:get_it/get_it.dart';
import 'package:frontend/core/network/dio_client.dart';

import 'package:frontend/features/turista/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/turista/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/turista/auth/data/repositories/auth_repository_impl.dart';

import 'package:frontend/features/turista/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/turista/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/login_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/register_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/onboarding_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ! Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ! Features - Turista
  // Auth
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthMockDataSource());
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(checkAuthStatusUseCase: sl(), logoutUseCase: sl()),
  );
  sl.registerFactory(() => LoginCubit(loginUseCase: sl()));

  sl.registerFactory(() => RegisterCubit(registerUseCase: sl()));
  sl.registerFactory(() => ForgotPasswordCubit(forgotPasswordUseCase: sl()));
  sl.registerFactory(() => OnboardingCubit(completeOnboardingUseCase: sl()));
}
