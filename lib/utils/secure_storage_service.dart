import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'enums.dart';

class SecureStorage {
  static SecureStorage? _instance;
  static FlutterSecureStorage? _storage;
  static const String _accessTokenKey = 'auth-token';
  static const String _refreshTokenKey = 'refresh-token';
  static const String _accessTokenExpiryKey = 'access-token-expiry';
  static const String _refreshTokenExpiryKey = 'refresh-token-expiry';
  static const String _medicalDisclaimerKey = 'medical-disclaimer';
  static const String _userEmailKey = 'user-data';
  static const String _captureModeKey = 'capture-mode';
  static const String _biometricConsentKey = 'biometric-consent';
  static const String _aiPolicyAcceptedKey = 'ai-policy-accepted';
  static const String _arShowcaseSeenKey = 'ar-showcase-seen';

  SecureStorage._();

  factory SecureStorage() {
    return _instance ??= SecureStorage._();
  }

  /// Load token once at app startup
  Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  /// Save token to storage + update cache
  Future<void> saveSecureString({
    required String key,
    required String value,
  }) async {
    await _storage!.write(key: key, value: value);
  }

  Future<String?> getSecureString({required String key}) async {
    return await _storage!.read(key: key);
  }

  /// Remove token from storage + cache
  Future<void> deleteSecureString({required String key}) async {
    await _storage!.delete(key: key);
  }

  Future<void> clearAllSecureStrings() async {
    final value = await getSecureString(
      key: SharedPreferencesKeys.biometricAuthKey.keyText,
    );
    final email = await getUserEmail();
    log('BIOMETRIC KEY: $value $email');
    await _storage!.deleteAll();
    await _storage!.write(
      key: SharedPreferencesKeys.biometricAuthKey.keyText,
      value: value,
    );
    await saveUserEmail(email);
  }

  Future<void> saveToken(String token) async {
    await _storage?.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage?.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage?.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage?.read(key: _refreshTokenKey);
  }

  Future<void> saveAccessTokenExpiry(DateTime expiryDate) async {
    await _storage?.write(
      key: _accessTokenExpiryKey,
      value: expiryDate.subtract(const Duration(minutes: 1)).toIso8601String(),
    );
  }

  Future<DateTime?> getAccessTokenExpiry() async {
    final expiryDate = await _storage?.read(key: _accessTokenExpiryKey);
    if (expiryDate == null) {
      return null;
    }
    return DateTime.tryParse(expiryDate);
  }

  Future<void> saveRefreshTokenExpiry(DateTime date) async {
    await _storage?.write(
      key: _refreshTokenExpiryKey,
      value: date.subtract(const Duration(minutes: 1)).toIso8601String(),
    );
  }

  Future<DateTime?> getRefreshTokenExpiry() async {
    final expiryDate = await _storage?.read(key: _refreshTokenExpiryKey);
    if (expiryDate == null) {
      return null;
    }
    return DateTime.tryParse(expiryDate);
  }

  Future<void> saveMedicalDisclaimer() async {
    await _storage?.write(key: _medicalDisclaimerKey, value: 'true');
  }

  Future<bool> getMedicalDisclaimer() async {
    final disclaimer = await _storage?.read(key: _medicalDisclaimerKey);
    return disclaimer == null;
  }

  Future<void> saveUserEmail(String? email) async {
    log('SAVING EMAIL: $email');
    await _storage?.write(key: _userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage?.read(key: _userEmailKey);
  }

  Future<void> saveCaptureMode(bool isAutomatic) async {
    await _storage?.write(key: _captureModeKey, value: isAutomatic.toString());
  }

  Future<bool?> getCaptureMode() async {
    final mode = await _storage?.read(key: _captureModeKey);
    if (mode == null) return null;
    return mode == 'true';
  }

  Future<void> clearCaptureMode() async {
    await _storage?.delete(key: _captureModeKey);
  }

  Future<void> saveBiometricConsent() async {
    await _storage?.write(key: _biometricConsentKey, value: 'true');
  }

  Future<bool> getBiometricConsent() async {
    final consent = await _storage?.read(key: _biometricConsentKey);
    return consent == 'true';
  }

  Future<void> saveAiPolicyAccepted() async {
    await _storage?.write(key: _aiPolicyAcceptedKey, value: 'true');
  }

  Future<bool> getAiPolicyAccepted() async {
    final accepted = await _storage?.read(key: _aiPolicyAcceptedKey);
    return accepted == 'true';
  }

  Future<void> saveArShowcaseSeen() async {
    await _storage?.write(key: _arShowcaseSeenKey, value: 'true');
  }

  Future<bool> getArShowcaseSeen() async {
    final seen = await _storage?.read(key: _arShowcaseSeenKey);
    return seen == 'true';
  }
}
