// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login_createPin => 'Create PIN';

  @override
  String get login_enterPin => 'Enter PIN';

  @override
  String get login_confirmPin => 'Confirm PIN';

  @override
  String get login_savePin => 'Save PIN';

  @override
  String get login_pinMismatch => 'PINs do not match';

  @override
  String get login_invalidPin => 'Invalid PIN';

  @override
  String get login_unlock => 'Unlock';

  @override
  String get login_validation => 'PIN must be at least 4 digits';

  @override
  String get title => 'Where’s My Rent?';

  @override
  String get home_welcome => 'Welcome to Where’s My Rent!';

  @override
  String get home_Logout => 'Logout';

  @override
  String get home_AddProperty => 'Agregar propiedad';
}
