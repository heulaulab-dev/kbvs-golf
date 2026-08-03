import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase [LocalStorage] backed by `flutter_secure_storage`.
///
/// Replaces the default `SharedPreferencesLocalStorage`, which stores the
/// session JWT + refresh token as plaintext. Secure storage encrypts it
/// (Keystore on Android, Keychain on iOS).
class SecureStorageLocalStorage extends LocalStorage {
  SecureStorageLocalStorage({required this.persistSessionKey});

  final String persistSessionKey;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    return await _storage.containsKey(key: persistSessionKey);
  }

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: persistSessionKey);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(key: persistSessionKey, value: persistSessionString);
  }
}

/// Supabase [GotrueAsyncStorage] backed by `flutter_secure_storage`.
///
/// Stores the PKCE code verifier (needed to complete email confirmation)
/// in secure storage instead of SharedPreferences.
class SecureStorageGotrueAsyncStorage extends GotrueAsyncStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<String?> getItem({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> removeItem({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }
}
