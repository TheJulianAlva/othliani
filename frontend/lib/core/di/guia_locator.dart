import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_local_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_remote_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_subscription_remote_data_source.dart';
import 'package:frontend/features/guia/auth/data/repositories/guia_auth_repository_impl.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';
import 'package:frontend/features/guia/auth/domain/usecases/login_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/forgot_password_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/check_auth_status_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/logout_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/onboarding_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/register_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_email_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/activate_subscription_guia_usecase.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_login_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_forgot_password_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_onboarding_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_register_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_email_verification_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_mock_payment_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_agency_login_cubit.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_folio_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_agency_phone_guia_usecase.dart';
import 'package:frontend/features/guia/home/presentation/blocs/agencia_home_bloc/agencia_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';

Future<void> initGuiaDependencies() async {
  // ====================================================
  // 1. FUENTES DE DATOS (Data Layer)
  // ====================================================

  sl.registerLazySingleton<GuiaAuthRemoteDataSource>(
    () => GuiaAuthMockDataSource(),
  );
  sl.registerLazySingleton<GuiaAuthLocalDataSource>(
    () => GuiaAuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<GuiaSubscriptionRemoteDataSource>(
    () => GuiaSubscriptionRemoteDataSourceImpl(),
  );

  // ====================================================
  // 2. REPOSITORIOS
  // ====================================================

  sl.registerLazySingleton<GuiaAuthRepository>(
    () => GuiaAuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      subscriptionDataSource: sl(),
    ),
  );

  // ====================================================
  // 3. CASOS DE USO (Domain Layer)
  // ====================================================

  sl.registerLazySingleton(() => LoginGuiaUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordGuiaUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusGuiaUseCase(sl()));
  sl.registerLazySingleton(() => LogoutGuiaUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingGuiaUseCase(sl()));
  sl.registerLazySingleton(() => CheckOnboardingGuiaUseCase(sl()));
  sl.registerLazySingleton(() => VerifyFolioGuiaUseCase(sl()));
  sl.registerLazySingleton(() => VerifyAgencyPhoneGuiaUseCase(sl()));
  sl.registerLazySingleton(() => RegisterGuiaUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailGuiaUseCase(sl()));
  sl.registerLazySingleton(() => ActivateSubscriptionGuiaUseCase(sl()));

  // ====================================================
  // 4. CUBITS (Presentation Layer)
  // ====================================================

  sl.registerFactory(() => GuiaLoginCubit(loginUseCase: sl()));
  sl.registerFactory(
    () => GuiaForgotPasswordCubit(forgotPasswordUseCase: sl()),
  );
  sl.registerFactory(
    () => GuiaOnboardingCubit(completeOnboardingUseCase: sl()),
  );
  sl.registerFactory(() => GuiaRegisterCubit(registerUseCase: sl()));
  sl.registerFactory(
    () => GuiaEmailVerificationCubit(verifyEmailUseCase: sl()),
  );
  sl.registerFactory(
    () => GuiaMockPaymentCubit(activateSubscriptionUseCase: sl()),
  );
  sl.registerFactory(
    () => GuiaAgencyLoginCubit(
      verifyFolioUseCase: sl(),
      verifyAgencyPhoneUseCase: sl(),
    ),
  );

  // Home cubits
  sl.registerFactory(() => AgenciaHomeCubit());
  sl.registerFactory(() => PersonalHomeCubit());
}
