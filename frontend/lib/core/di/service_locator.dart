import 'package:get_it/get_it.dart';
import 'package:frontend/core/network/dio_client.dart';

import 'package:frontend/features/turista/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/turista/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/turista/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/turista/home/data/datasources/trip_remote_data_source.dart';
import 'package:frontend/features/turista/home/data/repositories/trip_repository_impl.dart';
import 'package:frontend/features/turista/profile/data/datasources/profile_local_data_source.dart';
import 'package:frontend/features/turista/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend/features/turista/chat/data/datasources/chat_remote_data_source.dart';
import 'package:frontend/features/turista/chat/data/repositories/chat_repository_impl.dart';
import 'package:frontend/features/turista/home/data/datasources/itinerary_remote_data_source.dart';
import 'package:frontend/features/turista/home/data/repositories/itinerary_repository_impl.dart';
import 'package:frontend/features/turista/tools/currency/data/datasources/currency_remote_data_source.dart';
import 'package:frontend/features/turista/tools/currency/data/repositories/currency_repository_impl.dart';

import 'package:frontend/features/turista/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/turista/home/domain/repositories/trip_repository.dart';
import 'package:frontend/features/turista/home/domain/repositories/itinerary_repository.dart';
import 'package:frontend/features/turista/tools/currency/domain/repositories/currency_repository.dart';
import 'package:frontend/features/turista/profile/domain/repositories/profile_repository.dart';

import 'package:frontend/features/turista/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/turista/auth/domain/usecases/login_usecase.dart';

import 'package:frontend/features/turista/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:frontend/features/turista/home/domain/usecases/get_current_trip_usecase.dart';
import 'package:frontend/features/turista/profile/domain/usecases/get_profile_usecase.dart';
import 'package:frontend/features/turista/profile/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/turista/chat/domain/usecases/get_messages_usecase.dart';

import 'package:frontend/features/turista/chat/domain/usecases/send_message_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/verify_folio_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/request_phone_code_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/verify_phone_code_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:frontend/features/turista/home/domain/usecases/get_itinerary_usecase.dart';
import 'package:frontend/features/turista/tools/currency/domain/usecases/get_exchange_rates_usecase.dart';
import 'package:frontend/features/turista/tools/currency/domain/usecases/convert_currency_usecase.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/login_cubit.dart';

import 'package:frontend/features/turista/auth/presentation/cubit/register_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/onboarding_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_bloc.dart';
import 'package:frontend/features/turista/profile/presentation/bloc/profile_bloc.dart';

import 'package:frontend/features/turista/chat/presentation/bloc/chat_bloc.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_cubit.dart';

import 'package:frontend/features/turista/home/presentation/bloc/itinerary_bloc.dart';
import 'package:frontend/features/turista/tools/currency/presentation/cubit/currency_cubit.dart';

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

  // Home
  // Home
  sl.registerLazySingleton<TripRemoteDataSource>(() => TripMockDataSource());
  sl.registerLazySingleton<ItineraryRemoteDataSource>(
    () => ItineraryMockDataSource(),
  );

  // Profile
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatMockDataSource(), // Using Mock for now
  );

  // Tools
  sl.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyMockDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ItineraryRepository>(
    () => ItineraryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentTripUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));

  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => VerifyFolioUseCase(sl()));
  sl.registerLazySingleton(() => RequestPhoneCodeUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPhoneCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResendEmailVerificationUseCase(sl()));
  sl.registerLazySingleton(() => GetItineraryUseCase(sl()));
  sl.registerLazySingleton(() => GetExchangeRatesUseCase(sl()));
  sl.registerLazySingleton(() => ConvertCurrencyUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(checkAuthStatusUseCase: sl(), logoutUseCase: sl()),
  );
  sl.registerFactory(() => LoginCubit(loginUseCase: sl()));
  sl.registerFactory(() => TripBloc(getCurrentTripUseCase: sl()));
  sl.registerFactory(() => ItineraryBloc(getItineraryUseCase: sl()));

  sl.registerFactory(
    () => ProfileBloc(getProfileUseCase: sl(), updateProfileUseCase: sl()),
  );
  sl.registerFactory(
    () => ChatBloc(getMessagesUseCase: sl(), sendMessageUseCase: sl()),
  );

  sl.registerFactory(() => RegisterCubit(registerUseCase: sl()));
  sl.registerFactory(() => ForgotPasswordCubit(forgotPasswordUseCase: sl()));

  sl.registerFactory(() => OnboardingCubit(completeOnboardingUseCase: sl()));
  sl.registerFactory(
    () => VerificationCubit(
      verifyFolioUseCase: sl(),
      requestPhoneCodeUseCase: sl(),
      verifyPhoneCodeUseCase: sl(),
      resendEmailVerificationUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CurrencyCubit(
      getExchangeRatesUseCase: sl(),
      convertCurrencyUseCase: sl(),
    ),
  );
}
