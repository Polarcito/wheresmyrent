import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/model/generic/app_theme.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import 'package:wheresmyrent/model/generic/locale_notifier.dart';
import 'package:wheresmyrent/model/generic/theme_notifier.dart';
import 'package:wheresmyrent/model/maintenance_entry.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/model/rent_payment.dart';
import 'package:wheresmyrent/screens/pin_login_screen.dart';
import 'package:wheresmyrent/screens/pin_setup_screen.dart';
import 'package:wheresmyrent/services/auth_service.dart';

late final ThemeNotifier themeNotifier;
late final LocaleNotifier localeNotifier;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  localeNotifier = LocaleNotifier();
  themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme();

  // Inicializa Hive y abre el box
  await Hive.initFlutter();
  Hive.registerAdapter(PropertyAdapter());
  Hive.registerAdapter(MonthlyRentBlockAdapter());
  Hive.registerAdapter(RentPaymentAdapter());
  Hive.registerAdapter(MaintenanceEntryAdapter());
  await Hive.openBox<Property>(Config.boxName);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _startScreen;

  @override
  void initState() {
    super.initState();
    _loadStartScreen();
  }

  void _loadStartScreen() async {
    final authService = AuthService();
    final hasPin = await authService.isPinSaved();
    setState(() {
      _startScreen = hasPin ? const PinLoginScreen() : const PinSetupScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              title: 'Where’s My Rent?',
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
              ],
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light, // Puedes volver a activar esto
              home: FutureBuilder<bool>(
                future: AuthService().isPinSaved(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return snapshot.data!
                      ? const PinLoginScreen()
                      : const PinSetupScreen();
                },
              ),
            );
          },
        );
      },
    );
  }
}
