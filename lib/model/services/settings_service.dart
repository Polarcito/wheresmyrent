import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Estado cacheado en memoria (accesible de forma síncrona)
  static bool showCurrency = false;
  static String currencyCode = 'USD';
  static List<String> currencies = ['CLP', 'USD', 'EUR', 'BRL', 'ARS', 'MXN'];

  // Claves
  static const _kShowCurrency = 'showCurrency';
  static const _kCurrencyCode = 'currencyCode';
  static const _kCurrenciesList = 'currenciesList';

  /// Cargar todo desde SharedPreferences (llamar en main() antes de runApp)
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    showCurrency = prefs.getBool(_kShowCurrency) ?? false;
    currencyCode = (prefs.getString(_kCurrencyCode) ?? 'USD').toUpperCase();

    final saved = prefs.getStringList(_kCurrenciesList);
    final base = (saved ?? currencies)
        .map((c) => c.trim().toUpperCase())
        .where((c) => c.isNotEmpty)
        .toList();

    // Dedup manteniendo orden
    final seen = <String>{};
    currencies = [
      for (final c in base)
        if (seen.add(c)) c
    ];

    // Ajusta currencyCode inválido
    if (!currencies.contains(currencyCode)) {
      currencyCode = currencies.isNotEmpty ? currencies.first : 'USD';
      await saveCurrencyCode(currencyCode);
    }

    // Persiste la lista si venía distinta
    if (saved == null || saved.length != currencies.length) {
      await saveCurrenciesList(currencies);
    }
  }

  // Persistencia puntual (sincroniza prefs + cache)
  static Future<void> saveShowCurrency(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    showCurrency = value;
    await prefs.setBool(_kShowCurrency, value);
  }

  static Future<void> saveCurrencyCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    currencyCode = code.toUpperCase();
    await prefs.setString(_kCurrencyCode, currencyCode);
  }

  static Future<void> saveCurrenciesList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    currencies = list
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toList();

    // Dedup
    final seen = <String>{};
    currencies = [
      for (final c in currencies)
        if (seen.add(c)) c
    ];

    await prefs.setStringList(_kCurrenciesList, currencies);
  }

  /// Añade un código si no existe, lo normaliza y persiste.
  static Future<void> addCurrencyIfMissing(String code) async {
    final up = code.trim().toUpperCase();
    if (up.isEmpty) return;
    if (!currencies.contains(up)) {
      final next = List<String>.from(currencies)..add(up);
      await saveCurrenciesList(next);
    }
  }

  /// Normaliza lista + corrige currencyCode en caso de quedar inválido.
  static Future<void> normalizeAndPersist() async {
    await saveCurrenciesList(currencies);
    if (!currencies.contains(currencyCode)) {
      currencyCode = currencies.isNotEmpty ? currencies.first : 'USD';
      await saveCurrencyCode(currencyCode);
    }
  }
}
