import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  static Future<void> setPrefsInstance() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  static Future<void> setUid(String? uid) async {
    await _preferences?.setString('uid', uid ?? '');
  }

  static String? fetchUid() {
    return _preferences?.getString('uid');
  }

  static String? getUid() {
    print('UID from getUid: ${_preferences?.getString('uid')}');
    return _preferences?.getString('uid');
  }
}
