class RoutesTurista {
  static const String folio = '/folio';
  static const String phoneConfirm = '/phone-confirm';
  static const String smsVerification = '/sms-verification';
  static const String onboarding = '/onboarding';
  static const String register = '/register';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String itinerary = '/itinerary';
  static const String map = '/map';
  static const String chat = '/chat';
  static const String config = '/config';
  static const String profile = '/profile';
  static const String currencyConverter = '/currency-converter';
  static const String accessibility = '/accessibility';

  static String tripDetails(String tripId) => '/trip/$tripId';
}
