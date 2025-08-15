import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheresmyrent/model/services/settings_service.dart';

/// Muestra siempre el currency a la IZQUIERDA.
/// Sin decimales si el valor es entero; 2 decimales si tiene fracción.
String formatAmountWithCurrencySync(BuildContext context, double amount) {
  final hasDecimals = (amount % 1) != 0;
  final localeName = Localizations.localeOf(context).toString();

  final formatter = NumberFormat.decimalPattern(localeName)
    ..minimumFractionDigits = hasDecimals ? 2 : 0
    ..maximumFractionDigits = hasDecimals ? 2 : 0;

  final n = formatter.format(amount);

  if (!SettingsService.showCurrency || SettingsService.currencyCode.isEmpty) {
    return n;
  }
  return '${SettingsService.currencyCode} $n';
}
