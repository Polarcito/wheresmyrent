import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _pinKey = 'user_pin';
  final _storage = const FlutterSecureStorage();

  // Guarda el PIN cifrado
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  // Verifica si ya hay un PIN guardado
  Future<bool> isPinSaved() async {
    String? pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  // Valida si el PIN ingresado es correcto
  Future<bool> validatePin(String inputPin) async {
    String? savedPin = await _storage.read(key: _pinKey);
    return savedPin?.trim() == inputPin.trim();
  }

  // Borra el PIN
  Future<void> resetPin() async {
    await _storage.delete(key: _pinKey);
  }

  Future<String?> getStoredPinForDebug() async {
    return await _storage.read(key: _pinKey);
  }
}
