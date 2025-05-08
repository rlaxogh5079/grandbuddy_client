import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  late FlutterSecureStorage storage;

  factory SecureStorage() {
    return _instance;
  }

  SecureStorage._internal() {
    storage = const FlutterSecureStorage();
  }
}
