abstract class CurrencyRemoteDataSource {
  Future<Map<String, double>> getExchangeRates(String baseCurrency);
}

class CurrencyMockDataSource implements CurrencyRemoteDataSource {
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

  @override
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _exchangeRates[baseCurrency] ?? {};
  }
}
