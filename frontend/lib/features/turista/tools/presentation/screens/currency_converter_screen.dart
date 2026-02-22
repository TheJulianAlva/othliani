import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/tools/currency/presentation/cubit/currency_cubit.dart';
import 'package:frontend/features/turista/tools/currency/presentation/cubit/currency_state.dart';

class CurrencyConverterScreen extends StatelessWidget {
  const CurrencyConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.currencyConverter), centerTitle: false),
      body: BlocProvider(
        create: (_) => sl<CurrencyCubit>()..init(),
        child: const _CurrencyConverterView(),
      ),
    );
  }
}

class _CurrencyConverterView extends StatefulWidget {
  const _CurrencyConverterView();

  @override
  State<_CurrencyConverterView> createState() => _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends State<_CurrencyConverterView> {
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Local state for OCR image and loading, as these are UI specific
  bool _isLoading = false;
  File? _selectedImage;

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

  void _convertCurrency(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_amountController.text.isEmpty) {
      // Allow empty to just reset result or do nothing
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidAmount)));
      return;
    }

    final cubit = context.read<CurrencyCubit>();
    if (cubit.state is CurrencyLoaded) {
      final state = cubit.state as CurrencyLoaded;
      cubit.convert(amount, state.fromCurrency, state.toCurrency);
    }
  }

  Future<void> _takePicture() async {
    final l10n = AppLocalizations.of(context)!;
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
      ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    final l10n = AppLocalizations.of(context)!;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
    }
  }

  Future<void> _extractTextFromImage(String imagePath) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

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

          _convertCurrency(context);
        }
      });

      if (foundNumber == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noNumberFound)));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        String fromCurrency = 'USD';
        String toCurrency = 'MXN';
        double result = 0.0;
        Map<String, double> rates = {};

        if (state is CurrencyLoaded) {
          fromCurrency = state.fromCurrency;
          toCurrency = state.toCurrency;
          result = state.result;
          rates = state.rates;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_selectedImage != null)
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Buttons wrapped to handle large text
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _takePicture,
                              icon: const Icon(Icons.camera_alt),
                              label: Text(
                                l10n.takePhoto,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: Text(
                                l10n.gallery,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.lg),

                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.amount,
                            hintText: l10n.enterAmount,
                            prefixIcon: const Icon(Icons.attach_money),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _amountController.clear();
                                context.read<CurrencyCubit>().updateCurrencies(
                                  fromCurrency,
                                  toCurrency,
                                );
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                            ),
                          ),
                          onChanged: (_) => _convertCurrency(context),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        _buildCurrencySelector(
                          context,
                          label: l10n.from,
                          value: fromCurrency,
                          onChanged: (value) {
                            if (value != null) {
                              final cubit = context.read<CurrencyCubit>();
                              cubit.updateCurrencies(value, toCurrency);
                              _convertCurrency(context);
                            }
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Center(
                          child: IconButton(
                            onPressed: () async {
                              await context
                                  .read<CurrencyCubit>()
                                  .swapCurrencies();
                              if (!context.mounted) return;
                              _convertCurrency(context);
                            },
                            icon: const Icon(Icons.swap_vert, size: 32),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              foregroundColor: theme.colorScheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _buildCurrencySelector(
                          context,
                          label: l10n.to,
                          value: toCurrency,
                          onChanged: (value) {
                            if (value != null) {
                              final cubit = context.read<CurrencyCubit>();
                              cubit.updateCurrencies(fromCurrency, value);
                              _convertCurrency(context);
                            }
                          },
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.result,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              state is CurrencyLoading
                                  ? const CircularProgressIndicator()
                                  : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${_getCurrencySymbol(toCurrency)} ${result.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _getCurrencyName(toCurrency),
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        if (_amountController.text.isNotEmpty &&
                            rates.containsKey(toCurrency))
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.sm,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    '1 $fromCurrency = ${(rates[toCurrency] ?? 0).toStringAsFixed(4)} $toCurrency',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context, {
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            dropdownColor: theme.cardColor,
            items:
                _currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency['code'],
                    child: Row(
                      children: [
                        Text(
                          currency['flag']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${currency['code']} - ${currency['name']}',
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
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
