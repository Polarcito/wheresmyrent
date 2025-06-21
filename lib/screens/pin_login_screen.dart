import 'package:flutter/material.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({Key? key}) : super(key: key);

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _authService = AuthService();
  final _pinController = TextEditingController();
  String? _errorText;

  void _validatePin() async {
    final isValid = await _authService.validatePin(_pinController.text.trim());

    if (!mounted) return;

    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorText = AppLocalizations.of(context)!.login_invalidPin;
      });
    }
  }


  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
            AppLocalizations.of(context)!.login_enterPin,
            style: TextStyle(color: Colors.white),
          )
        ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "PIN"),
              onSubmitted: (_) => _validatePin(),
            ),
            const SizedBox(height: 16),
            if (_errorText != null)
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              onPressed: _validatePin,
              child: Text(
                AppLocalizations.of(context)!.login_unlock,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
