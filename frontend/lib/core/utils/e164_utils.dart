/// Utilidades para formatear números en E.164 y validaciones simples.
library;

/// Devuelve el número en formato E.164: +`código``local_sin_separadores`
/// - `dialCode` puede venir como '+52' o '52'; se asegura el '+'
/// - `localDigits` debe ser solo dígitos (limpia si traen separadores).
String toE164(String dialCode, String localDigits) {
  final sanitizedDial = dialCode.startsWith('+') ? dialCode : '+$dialCode';
  final digitsOnly = localDigits.replaceAll(RegExp(r'[^0-9]'), '');
  return '$sanitizedDial$digitsOnly';
}

/// Validación de longitud por país (opcional).
bool hasExpectedLength({
  required String countryCode,
  required String localDigits,
  Map<String, int> expectedLengths = const {'MX': 10, 'US': 10, 'ES': 9},
}) {
  final digitsOnly = localDigits.replaceAll(RegExp(r'\D'), '');
  final expected = expectedLengths[countryCode];
  return expected == null ? true : digitsOnly.length == expected;
}

/// ---------- NUEVO: Modelo de partes del teléfono ----------
class PhoneParts {
  final String codigo; // ej. +52
  final String numero; // ej. 7203524477 (solo dígitos)
  final String pais; // ej. MX (ISO-2)
  final String e164; // ej. +527203524477
  const PhoneParts({
    required this.codigo,
    required this.numero,
    required this.pais,
    required this.e164,
  });

  @override
  String toString() =>
      'PhoneParts(codigo: $codigo, numero: $numero, pais: $pais, e164: $e164)';
}

/// Construye PhoneParts a partir de countryCode (ISO), dialCode y el número local.
/// - Asegura que `dialCode` lleve '+'.
/// - Normaliza `localDigits` a solo dígitos.
/// - Genera `e164` concatenando `codigo` + `numero`.
PhoneParts partsFrom({
  required String countryCode, // MX
  required String dialCode, // +52 o 52
  required String localDigits, // ej. 7225698563
}) {
  final codigo = dialCode.startsWith('+') ? dialCode : '+$dialCode';
  final numero = localDigits.replaceAll(RegExp(r'\D'), ''); // solo dígitos
  final e164 = toE164(codigo, numero);
  return PhoneParts(
    codigo: codigo,
    numero: numero,
    pais: countryCode,
    e164: e164,
  );
}
