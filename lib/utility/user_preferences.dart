import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future clearPrefs() async => _preferences.clear();
  static Future<void> setStringValue(String key, String value) async {
    _preferences = await SharedPreferences.getInstance();
    await _preferences.setString(key, value);
  }

  static Future<String?> getStringValue(String key) async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences.getString(key);
  }

  static Future<void> setBoolValue(String key, bool value) async {
    _preferences = await SharedPreferences.getInstance();
    await _preferences.setBool(key, value);
  }

  static Future<bool?> getBoolValue(String key) async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences.getBool(key);
  }

  static Future<void> removeValue(String key) async {
    _preferences = await SharedPreferences.getInstance();
    await _preferences.remove(key);
  }
}