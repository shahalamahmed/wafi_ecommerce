import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static final SecureStorage _instance = SecureStorage._();
  factory SecureStorage() => _instance;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Keys
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyTenantId = 'tenant_id';
  static const String _keyUserRole = 'user_role';

  // Save
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<void> saveUserId(String uid) async {
    await _storage.write(key: _keyUserId, value: uid);
  }

  Future<void> saveTenantId(String tenantId) async {
    await _storage.write(key: _keyTenantId, value: tenantId);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  // Get
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<String?> getTenantId() async {
    return await _storage.read(key: _keyTenantId);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  // Clear (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}