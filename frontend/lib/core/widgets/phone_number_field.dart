import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:country_picker/country_picker.dart';

/// Valor que expone el widget para que puedas construir E.164 o validar.
class PhoneNumberValue {
  final String countryCode; // ej. MX
  final String dialCode; // ej. +52
  final String localMasked; // ej. 722-569-8563
  final String localDigits; // ej. 7225698563 (sin máscara)

  const PhoneNumberValue({
    required this.countryCode,
    required this.dialCode,
    required this.localMasked,
    required this.localDigits,
  });

  @override
  String toString() =>
      'PhoneNumberValue(countryCode: $countryCode, dialCode: $dialCode, localMasked: $localMasked, localDigits: $localDigits)';
}

/// Widget reutilizable del campo de teléfono con:
/// - máscara (por defecto ###-###-####)
/// - selector de país (bandera + código telefónico)
/// Expone los cambios por medio de [onChanged].
class PhoneNumberField extends StatefulWidget {
  final String initialCountryCode; // ej. 'MX'
  final String initialDialCode; // ej. '+52'
  final String mask; // ej. ###-###-####
  final ValueChanged<PhoneNumberValue>? onChanged;
  final String? hintText;

  /// Mapa opcional de longitudes esperadas por país (para validar en el widget).
  final Map<String, int>? expectedLengths;

  const PhoneNumberField({
    super.key,
    this.initialCountryCode = 'MX',
    this.initialDialCode = '+52',
    this.mask = '###-###-####',
    this.onChanged,
    this.hintText,
    this.expectedLengths,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late String _countryCode;
  late String _dialCode;

  final _controller = TextEditingController();
  late MaskTextInputFormatter _maskFormatter;

  @override
  void initState() {
    super.initState();
    _countryCode = widget.initialCountryCode;
    _dialCode = widget.initialDialCode;
    _maskFormatter = MaskTextInputFormatter(
      mask: widget.mask,
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emitChange() {
    final value = PhoneNumberValue(
      countryCode: _countryCode,
      dialCode: _dialCode.startsWith('+') ? _dialCode : '+$_dialCode',
      localMasked: _controller.text,
      localDigits: _maskFormatter.getUnmaskedText(),
    );
    widget.onChanged?.call(value);
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: const ['MX', 'US', 'ES'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 600,
        inputDecoration: const InputDecoration(
          labelText: 'Buscar país',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
      onSelect: (country) {
        setState(() {
          _countryCode = country.countryCode;
          _dialCode = '+${country.phoneCode}';
        });
        _emitChange();
      },
    );
  }

  String _flagEmoji(String countryCode) {
    final base = 0x1F1E6; // Regional Indicator Symbol Letter A
    final codes = countryCode.toUpperCase().codeUnits.map(
      (c) => base + (c - 65),
    );
    return String.fromCharCodes(codes);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [_maskFormatter],
      onChanged: (_) => _emitChange(),
      decoration: InputDecoration(
        hintText: widget.hintText ?? '722-569-8563',
        border: const OutlineInputBorder(),
        prefixIcon: InkWell(
          onTap: _pickCountry,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Text(
                  _flagEmoji(_countryCode),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  _dialCode,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.arrow_drop_down),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      validator: (value) {
        final digits = _maskFormatter.getUnmaskedText();
        final expected = widget.expectedLengths?[_countryCode];
        if ((value ?? '').isEmpty) {
          return 'Coloque su número de teléfono';
        }
        if (expected != null && digits.length != expected) {
          return 'El número debe tener $expected dígitos para $_countryCode';
        }
        return null;
      },
    );
  }
}
