import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'OthliAni - Turista'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @continueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// No description provided for @myTrips.
  ///
  /// In es, this message translates to:
  /// **'Mis Viajes'**
  String get myTrips;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get deleteAccount;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta próximamente'**
  String get deleteAccountConfirm;

  /// No description provided for @myTripsComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Historial de viajes próximamente'**
  String get myTripsComingSoon;

  /// No description provided for @configuration.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuration;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema Oscuro'**
  String get darkTheme;

  /// No description provided for @accessibility.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad'**
  String get accessibility;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @fontSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de fuente'**
  String get fontSize;

  /// No description provided for @small.
  ///
  /// In es, this message translates to:
  /// **'Pequeño'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In es, this message translates to:
  /// **'Mediano'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get large;

  /// No description provided for @extraLarge.
  ///
  /// In es, this message translates to:
  /// **'Extra grande'**
  String get extraLarge;

  /// No description provided for @highContrast.
  ///
  /// In es, this message translates to:
  /// **'Alto contraste'**
  String get highContrast;

  /// No description provided for @screenReader.
  ///
  /// In es, this message translates to:
  /// **'Lector de pantalla'**
  String get screenReader;

  /// No description provided for @reduceAnimations.
  ///
  /// In es, this message translates to:
  /// **'Reducir animaciones'**
  String get reduceAnimations;

  /// No description provided for @hapticFeedback.
  ///
  /// In es, this message translates to:
  /// **'Vibración táctil'**
  String get hapticFeedback;

  /// No description provided for @accessibilitySettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración de accesibilidad'**
  String get accessibilitySettings;

  /// No description provided for @map.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get map;

  /// No description provided for @currentActivities.
  ///
  /// In es, this message translates to:
  /// **'Actividades en curso'**
  String get currentActivities;

  /// No description provided for @currentLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación actual'**
  String get currentLocation;

  /// No description provided for @centerOnLocation.
  ///
  /// In es, this message translates to:
  /// **'Centrar en mi ubicación'**
  String get centerOnLocation;

  /// No description provided for @apiInfo.
  ///
  /// In es, this message translates to:
  /// **'Información de API'**
  String get apiInfo;

  /// No description provided for @locationNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Ubicación no disponible'**
  String get locationNotAvailable;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @chat.
  ///
  /// In es, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @currency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currency;

  /// No description provided for @config.
  ///
  /// In es, this message translates to:
  /// **'Config'**
  String get config;

  /// No description provided for @onboardingTitle1.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a OthliAni'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In es, this message translates to:
  /// **'Tu compañero perfecto para explorar México'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In es, this message translates to:
  /// **'Descubre lugares increíbles'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In es, this message translates to:
  /// **'Encuentra los mejores destinos turísticos'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In es, this message translates to:
  /// **'Planifica tu viaje'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In es, this message translates to:
  /// **'Organiza tu itinerario de manera sencilla'**
  String get onboardingDesc3;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @emailAddress.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de teléfono'**
  String get phoneNumber;

  /// No description provided for @verificationCode.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación'**
  String get verificationCode;

  /// No description provided for @sendCode.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get sendCode;

  /// No description provided for @verify.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get resendCode;

  /// No description provided for @dontHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get signIn;

  /// No description provided for @enterFolio.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu folio'**
  String get enterFolio;

  /// No description provided for @folioNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de folio'**
  String get folioNumber;

  /// No description provided for @folioDescription.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el número de folio de tu viaje para continuar'**
  String get folioDescription;

  /// No description provided for @invalidFolio.
  ///
  /// In es, this message translates to:
  /// **'Folio inválido'**
  String get invalidFolio;

  /// No description provided for @tripDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles del viaje'**
  String get tripDetails;

  /// No description provided for @itinerary.
  ///
  /// In es, this message translates to:
  /// **'Viaje'**
  String get itinerary;

  /// No description provided for @activities.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get activities;

  /// No description provided for @startTrip.
  ///
  /// In es, this message translates to:
  /// **'Iniciar viaje'**
  String get startTrip;

  /// No description provided for @tripStarted.
  ///
  /// In es, this message translates to:
  /// **'Viaje iniciado'**
  String get tripStarted;

  /// No description provided for @destination.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get destination;

  /// No description provided for @duration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get duration;

  /// No description provided for @participants.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get participants;

  /// No description provided for @sendMessage.
  ///
  /// In es, this message translates to:
  /// **'Enviar mensaje'**
  String get sendMessage;

  /// No description provided for @typeMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje...'**
  String get typeMessage;

  /// No description provided for @guide.
  ///
  /// In es, this message translates to:
  /// **'Guía'**
  String get guide;

  /// No description provided for @tourist.
  ///
  /// In es, this message translates to:
  /// **'Turista'**
  String get tourist;

  /// No description provided for @currencyConverter.
  ///
  /// In es, this message translates to:
  /// **'Conversor de divisas'**
  String get currencyConverter;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get amount;

  /// No description provided for @from.
  ///
  /// In es, this message translates to:
  /// **'De'**
  String get from;

  /// No description provided for @to.
  ///
  /// In es, this message translates to:
  /// **'A'**
  String get to;

  /// No description provided for @convert.
  ///
  /// In es, this message translates to:
  /// **'Convertir'**
  String get convert;

  /// No description provided for @result.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get result;

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoon;

  /// No description provided for @notAvailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get notAvailable;

  /// No description provided for @tryAgain.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get tryAgain;

  /// No description provided for @resetPassword.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get resetPassword;

  /// No description provided for @enterEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico'**
  String get enterEmail;

  /// No description provided for @sendResetLink.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace de restablecimiento'**
  String get sendResetLink;

  /// No description provided for @enterPhone.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu número de teléfono'**
  String get enterPhone;

  /// No description provided for @verifyPhone.
  ///
  /// In es, this message translates to:
  /// **'Verificar teléfono'**
  String get verifyPhone;

  /// No description provided for @enterCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código'**
  String get enterCode;

  /// No description provided for @codeDescription.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un código de verificación a tu número'**
  String get codeDescription;

  /// No description provided for @didntReceiveCode.
  ///
  /// In es, this message translates to:
  /// **'¿No recibiste el código?'**
  String get didntReceiveCode;

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @active.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get active;

  /// No description provided for @allIncluded.
  ///
  /// In es, this message translates to:
  /// **'Todo incluido'**
  String get allIncluded;

  /// No description provided for @dayProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso del día'**
  String get dayProgress;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @finished.
  ///
  /// In es, this message translates to:
  /// **'Terminada'**
  String get finished;

  /// No description provided for @inProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get inProgress;

  /// No description provided for @pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// No description provided for @noActivities.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades'**
  String get noActivities;

  /// No description provided for @enterAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una cantidad'**
  String get enterAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In es, this message translates to:
  /// **'Cantidad inválida'**
  String get invalidAmount;

  /// No description provided for @noNumberFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró número'**
  String get noNumberFound;

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get takePhoto;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get gallery;

  /// No description provided for @incorrectDataButton.
  ///
  /// In es, this message translates to:
  /// **'¿Tus datos son incorrectos?'**
  String get incorrectDataButton;

  /// No description provided for @incorrectDataTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Datos incorrectos?'**
  String get incorrectDataTitle;

  /// No description provided for @incorrectDataContent.
  ///
  /// In es, this message translates to:
  /// **'Comunicate con la empresa o persona que te registró si crees que pudo haber ocurrido un error al registrar tus datos.'**
  String get incorrectDataContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
