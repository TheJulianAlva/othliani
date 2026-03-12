import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart' as di_shared;
import 'package:frontend/core/di/turista_locator.dart' as di_turista;
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/navigation/enrutador_app_turista.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/accessibility_cubit.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/locale_cubit.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHasAccount = 'TURISTA_HAS_ACCOUNT';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di_shared.initSharedDependencies();
  await di_turista.initTuristaDependencies();

  final prefs = await SharedPreferences.getInstance();
  final hasAccount = prefs.getBool(_kHasAccount) ?? false;

  runApp(MyApp(hasAccount: hasAccount));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.hasAccount});

  final bool hasAccount;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<LocaleCubit>()),
        BlocProvider(create: (_) => sl<AccessibilityCubit>()),
      ],
      child: _AppView(hasAccount: hasAccount),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({required this.hasAccount});

  final bool hasAccount;

  @override
  Widget build(BuildContext context) {
    // Access Cubits
    final themeMode = context.select((ThemeCubit cubit) => cubit.state);
    final locale = context.select((LocaleCubit cubit) => cubit.state);
    final accessibilityState = context.select(
      (AccessibilityCubit cubit) => cubit.state,
    );

    // Create Router with AuthBloc — pass hasAccount so returning users go to
    // /login instead of /folio after logout.
    final authBloc = context.read<AuthBloc>();
    final router = EnrutadorAppTurista.createRouter(
      hasAccount ? RoutesTurista.login : RoutesTurista.folio,
      authBloc,
      hasAccount: hasAccount,
    );

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
