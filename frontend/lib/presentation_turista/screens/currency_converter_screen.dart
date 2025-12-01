import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _fromCurrency = 'USD';
  String _toCurrency = 'MXN';
  double _result = 0.0;
  bool _isLoading = false;
  File? _selectedImage;

  // Tasas de cambio de ejemplo (en producción, usar una API real)
  final Map<String, Map<String, double>> _exchangeRates = {
    'USD': {'MXN': 17.5, 'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.5, 'CAD': 1.36},
    'MXN': {
      'USD': 0.057,
      'EUR': 0.052,
      'GBP': 0.045,
      'JPY': 8.54,
      'CAD': 0.078,
    },
    'EUR': {'USD': 1.09, 'MXN': 19.1, 'GBP': 0.86, 'JPY': 162.8, 'CAD': 1.48},
    'GBP': {'USD': 1.27, 'MXN': 22.2, 'EUR': 1.16, 'JPY': 189.5, 'CAD': 1.72},
    'JPY': {
      'USD': 0.0067,
      'MXN': 0.117,
      'EUR': 0.0061,
      'GBP': 0.0053,
      'CAD': 0.0091,
    },
    'CAD': {'USD': 0.74, 'MXN': 12.9, 'EUR': 0.68, 'GBP': 0.58, 'JPY': 109.9},
  };

  final List<Map<String, String>> _currencies = [
    {
      'code': 'USD',
      'name': 'Dólar Estadounidense',
      'symbol': '\$',
      'flag': '🇺🇸',
    },
    {'code': 'MXN', 'name': 'Peso Mexicano', 'symbol': '\$', 'flag': '🇲🇽'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'Libra Esterlina', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Yen Japonés', 'symbol': '¥', 'flag': '🇯🇵'},
    {'code': 'CAD', 'name': 'Dólar Canadiense', 'symbol': '\$', 'flag': '🇨🇦'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convertCurrency() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa una cantidad')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cantidad inválida')));
      return;
    }

    setState(() {
      final rate = _exchangeRates[_fromCurrency]?[_toCurrency] ?? 1.0;
      _result = amount * rate;
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      if (_amountController.text.isNotEmpty) {
        _convertCurrency();
      }
    });
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _isLoading = true;
        });

        await _extractTextFromImage(photo.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al tomar foto: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isLoading = true;
        });

        await _extractTextFromImage(image.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Buscar números en el texto reconocido
      final RegExp numberRegex = RegExp(r'[\d,]+\.?\d*');
      String? foundNumber;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final match = numberRegex.firstMatch(line.text);
          if (match != null) {
            foundNumber = match.group(0)?.replaceAll(',', '');
            break;
          }
        }
        if (foundNumber != null) break;
      }

      await textRecognizer.close();

      setState(() {
        _isLoading = false;
        if (foundNumber != null) {
          _amountController.text = foundNumber;
          _convertCurrency();
        }
      });

      if (foundNumber == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró ningún número en la imagen'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al procesar imagen: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              if (_selectedImage != null)
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                ),

              // Camera buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar Foto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),

              // Amount input
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ingresa la cantidad',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _amountController.clear();
                      setState(() {
                        _result = 0.0;
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
                onChanged: (_) => _convertCurrency(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // From Currency
              _buildCurrencySelector(
                label: 'De',
                value: _fromCurrency,
                onChanged: (value) {
                  setState(() {
                    _fromCurrency = value!;
                    _convertCurrency();
                  });
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Swap button
              Center(
                child: IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_vert, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // To Currency
              _buildCurrencySelector(
                label: 'A',
                value: _toCurrency,
                onChanged: (value) {
                  setState(() {
                    _toCurrency = value!;
                    _convertCurrency();
                  });
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Result
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Resultado',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${_getCurrencySymbol(_toCurrency)} ${_result.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _getCurrencyName(_toCurrency),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Exchange rate info
              if (_amountController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '1 $_fromCurrency = ${(_exchangeRates[_fromCurrency]?[_toCurrency] ?? 0).toStringAsFixed(4)} $_toCurrency',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: _currencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency['code'],
                child: Row(
                  children: [
                    Text(
                      currency['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency['code']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currency['name']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _getCurrencySymbol(String code) {
    return _currencies.firstWhere((c) => c['code'] == code)['symbol']!;
  }

  String _getCurrencyName(String code) {
    return _currencies.firstWhere((c) => c['code'] == code)['name']!;
  }
}
