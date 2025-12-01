class RoutesTurista {
  static const String folio = '/folio';
  static const String phoneConfirm = '/phone-confirm';
  static const String smsVerification = '/sms-verification';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Ejemplos con parámetros si los necesitas más adelante:
  static String tripDetails(String tripId) => '/trip/$tripId';
}
