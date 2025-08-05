import 'package:flutter/material.dart';

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es')); // Idioma predeterminado

  void setLocale(Locale locale) {
    value = locale;
  }
}
