import 'package:flutter/material.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({Key? key}) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _authService = AuthService();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  void _savePin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin != confirmPin) {
      setState(() {
        _errorText = AppLocalizations.of(context)!.login_pinMismatch;
      });
      return;
    }

    if (pin.length < 4) {
      setState(() {
        _errorText = AppLocalizations.of(context)!.login_validation;
      });
      return;
    }

    await _authService.savePin(pin);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }


  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          AppLocalizations.of(context)!.login_createPin,
          style: TextStyle(color: Colors.white),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.login_enterPin),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.login_confirmPin),
              ),
              const SizedBox(height: 16),
              if (_errorText != null)
                Text(_errorText!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: _savePin,
                child: Text(
                  AppLocalizations.of(context)!.login_savePin,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
