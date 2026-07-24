import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Port of `AsyncKeys` from `src/global/Helpers/AsyncManager.js`.
class StorageKeys {
  StorageKeys._();

  static const String isAlreadyLogin = 'IS_ALREADY_LOGIN';
  static const String accessToken = 'ACCESS_TOKEN';
  static const String userInfo = 'USER_INFO';
  static const String screenType = 'ScreenType';
}

/// Port of `src/global/Helpers/AsyncManager.js` (AsyncStorage -> SharedPreferences).
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sp async => _prefs ??= await SharedPreferences.getInstance();

  /// storeObject
  Future<void> saveObject(String key, Object value) async {
    final sp = await _sp;
    await sp.setString(key, jsonEncode(value));
  }

  /// storeValue
  Future<void> saveValue(String key, String value) async {
    final sp = await _sp;
    await sp.setString(key, value);
  }

  /// fetchData -> returns raw string (same as AsyncStorage.getItem)
  Future<String?> fetch(String key) async {
    final sp = await _sp;
    return sp.getString(key);
  }

  /// convenience helper (RN callers JSON.parse the result of fetch() themselves;
  /// this mirrors that pattern for object-shaped values).
  Future<Map<String, dynamic>?> fetchObject(String key) async {
    final raw = await fetch(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// removeData
  Future<void> remove(String key) async {
    final sp = await _sp;
    await sp.remove(key);
  }

  /// clearAllData
  Future<void> clearAll() async {
    final sp = await _sp;
    await sp.clear();
  }
}
