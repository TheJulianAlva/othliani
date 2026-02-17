import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/navigation/enrutador_app_turista.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/accessibility_cubit.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/locale_cubit.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/theme_cubit.dart';
// Providers legacy
// import 'package:provider/provider.dart'; // Removing Provider dependency for settings

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We replace MultiProvider with MultiBlocProvider
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthCheckRequested())),
        // Settings Cubits
        BlocProvider(create: (_) => ThemeCubit(sharedPreferences: sl())),
        BlocProvider(create: (_) => LocaleCubit(sharedPreferences: sl())),
        BlocProvider(create: (_) => AccessibilityCubit()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    // Access Cubits
    final themeMode = context.select((ThemeCubit cubit) => cubit.state);
    final locale = context.select((LocaleCubit cubit) => cubit.state);
    final accessibilityState = context.select(
      (AccessibilityCubit cubit) => cubit.state,
    );

    // Apply accessibility (simple text scale for now, assuming AppTheme uses it or we wrap MaterialApp)
    // Note: To fully apply accessibility settings like high contrast, we might need to modify AppTheme.
    // For now we just pass themeMode and locale.

    // Create Router with AuthBloc
    final authBloc = context.read<AuthBloc>();
    final router = EnrutadorAppTurista.createRouter('/', authBloc);

    return MaterialApp.router(
      title: 'Turista App',
      theme:
          AppTheme
              .lightTheme, // You might need to adjust AppTheme to accept accessibility params
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        // Apply text scale factor from accessibility
        double textScale = 1.0;
        switch (accessibilityState.fontSize) {
          case FontSizeOption.small:
            textScale = 0.8;
            break;
          case FontSizeOption.medium:
            textScale = 1.0;
            break;
          case FontSizeOption.large:
            textScale = 1.2;
            break;
          case FontSizeOption.extraLarge:
            textScale = 1.5;
            break;
        }

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            boldText:
                accessibilityState
                    .highContrast, // approximating high contrast with bold
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
