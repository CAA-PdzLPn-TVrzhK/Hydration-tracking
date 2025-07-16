import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    if (!kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static Future<void> saveString(String key, String value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    } else {
      await _prefs?.setString(key, value);
    }
  }

  static Future<String?> getString(String key) async {
    if (kIsWeb) {
      return html.window.localStorage[key];
    } else {
      return _prefs?.getString(key);
    }
  }

  static Future<void> saveInt(String key, int value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value.toString();
    } else {
      await _prefs?.setInt(key, value);
    }
  }

  static Future<int?> getInt(String key) async {
    if (kIsWeb) {
      final val = html.window.localStorage[key];
      return val != null ? int.tryParse(val) : null;
    } else {
      return _prefs?.getInt(key);
    }
  }

  static Future<void> saveBool(String key, bool value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value.toString();
    } else {
      await _prefs?.setBool(key, value);
    }
  }

  static Future<bool?> getBool(String key) async {
    if (kIsWeb) {
      final val = html.window.localStorage[key];
      if (val == null) return null;
      return val == 'true';
    } else {
      return _prefs?.getBool(key);
    }
  }

  static Future<void> remove(String key) async {
    if (kIsWeb) {
      html.window.localStorage.remove(key);
    } else {
      await _prefs?.remove(key);
    }
  }

  static Future<void> saveLanguage(String languageCode) async {
    await saveString('language_code', languageCode);
  }

  static Future<String?> getLanguage() async {
    return await getString('language_code');
  }
}
