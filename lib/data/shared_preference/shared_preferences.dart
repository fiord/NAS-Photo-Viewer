import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static Future<String?> getString({required String key}) async {
    final sharedPreference = await SharedPreferences.getInstance();
    return sharedPreference.getString(key);
  }

  static Future<bool> remove({required String key}) async {
    final sharedPreference = await SharedPreferences.getInstance();
    return await sharedPreference.remove(key);
  }

  static Future<bool> setString(
      {required String key, required String value}) async {
    final sharedPreference = await SharedPreferences.getInstance();
    return await sharedPreference.setString(key, value);
  }
}
