import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  late FlutterSecureStorage _storage;

  SecureStorage() {
    _storage = const FlutterSecureStorage();
  }

  Future<String?> getData({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<bool> removeData({required String key}) async {
    await _storage.delete(key: key);
    return true;
  }

  Future<bool> setData({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
    return true;
  }
}
