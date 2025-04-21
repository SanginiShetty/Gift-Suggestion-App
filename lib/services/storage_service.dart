import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Store user session
  Future<void> storeUserSession(String uid) async {
    await _secureStorage.write(key: 'uid', value: uid);
  }

  // Get user session
  Future<String?> getUserSession() async {
    return await _secureStorage.read(key: 'uid');
  }

  // Clear user session
  Future<void> clearUserSession() async {
    await _secureStorage.delete(key: 'uid');
  }
}