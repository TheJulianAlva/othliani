import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_local_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_remote_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_subscription_remote_data_source.dart';
import 'package:frontend/features/guia/auth/data/repositories/guia_auth_repository_impl.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';
import 'package:frontend/features/guia/trips/data/datasources/caja_negra_local_datasource.dart';
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
import 'package:frontend/features/guia/home/data/datasources/guia_home_mock_datasource.dart';
import 'package:frontend/features/guia/home/data/repositories/guia_home_repository_impl.dart';
import 'package:frontend/features/guia/home/domain/repositories/guia_home_repository.dart';
import 'package:frontend/features/guia/home/domain/usecases/get_agencia_home_data_usecase.dart';
import 'package:frontend/features/guia/home/domain/usecases/get_personal_home_data_usecase.dart';
import 'package:frontend/features/guia/home/data/datasources/sucesion_mando_datasource.dart';
import 'package:frontend/features/guia/home/data/services/sucesion_mando_local_service.dart';
import 'package:frontend/features/guia/home/domain/repositories/sucesion_mando_repository.dart';
import 'package:frontend/features/guia/home/data/repositories/sucesion_mando_repository_impl.dart';
import 'package:frontend/features/guia/trips/domain/repositories/caja_negra_repository.dart';
import 'package:frontend/features/guia/trips/data/repositories/caja_negra_repository_impl.dart';

// Herramienta de conversor de moneda (compartida con turista)
import 'package:frontend/features/turista/tools/currency/data/datasources/currency_remote_data_source.dart';
import 'package:frontend/features/turista/tools/currency/data/repositories/currency_repository_impl.dart';
import 'package:frontend/features/turista/tools/currency/domain/repositories/currency_repository.dart';
import 'package:frontend/features/turista/tools/currency/domain/usecases/get_exchange_rates_usecase.dart';
import 'package:frontend/features/turista/tools/currency/domain/usecases/convert_currency_usecase.dart';
import 'package:frontend/features/turista/tools/currency/presentation/cubit/currency_cubit.dart';

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
  sl.registerLazySingleton<CajaNegraLocalDataSource>(
    () => CajaNegraLocalDataSource(sl()),
  );
  sl.registerLazySingleton<GuiaHomeRemoteDataSource>(
    () => GuiaHomeMockDataSource(),
  );
  sl.registerLazySingleton<SucesionMandoDataSource>(
    () => SucesionMandoLocalService(),
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
  sl.registerLazySingleton<GuiaHomeRepository>(
    () => GuiaHomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SucesionMandoRepository>(
    () => SucesionMandoRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<CajaNegraRepository>(
    () => CajaNegraRepositoryImpl(localDataSource: sl()),
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
  sl.registerLazySingleton(() => GetAgenciaHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => GetPersonalHomeDataUseCase(sl()));

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
  sl.registerFactory(() => AgenciaHomeCubit(getAgenciaHomeDataUseCase: sl()));
  sl.registerFactory(() => PersonalHomeCubit(getPersonalHomeDataUseCase: sl()));

  // ====================================================
  // 5. CONVERSOR DE MONEDA (pantalla compartida con turista)
  //    Registramos solo si no fue ya registrado por turista_locator
  // ====================================================
  if (!sl.isRegistered<CurrencyRemoteDataSource>()) {
    sl.registerLazySingleton<CurrencyRemoteDataSource>(
      () => CurrencyMockDataSource(),
    );
  }
  if (!sl.isRegistered<CurrencyRepository>()) {
    sl.registerLazySingleton<CurrencyRepository>(
      () => CurrencyRepositoryImpl(remoteDataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetExchangeRatesUseCase>()) {
    sl.registerLazySingleton(() => GetExchangeRatesUseCase(sl()));
  }
  if (!sl.isRegistered<ConvertCurrencyUseCase>()) {
    sl.registerLazySingleton(() => ConvertCurrencyUseCase(sl()));
  }
  if (!sl.isRegistered<CurrencyCubit>()) {
    sl.registerFactory(
      () => CurrencyCubit(
        getExchangeRatesUseCase: sl(),
        convertCurrencyUseCase: sl(),
      ),
    );
  }
}
