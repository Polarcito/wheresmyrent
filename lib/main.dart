import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import 'package:wheresmyrent/screens/pin_login_screen.dart';
import 'package:wheresmyrent/screens/pin_setup_screen.dart';
import 'package:wheresmyrent/services/auth_service.dart';

void main() {
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
    return MaterialApp(
      title: 'Where’s My Rent?',
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: _startScreen ??
          const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
