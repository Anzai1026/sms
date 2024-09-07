import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

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

  static Future<void> setUser(User user) async {
    await _preferences?.setString('uid', user.id);
    await _preferences?.setString('name', user.name ?? '');
    await _preferences?.setString('imagePath', user.imagePath ?? '');
  }

  static User? getUser() {
    final String? id = _preferences?.getString('uid');
    final String? name = _preferences?.getString('name');
    final String? imagePath = _preferences?.getString('imagePath');

    if (id != null) {
      return User(id: id, name: name, imagePath: imagePath, email: '');
    }
    return null;
  }
}
