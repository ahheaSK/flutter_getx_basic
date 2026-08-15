import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/app_constant.dart';

/// Keeps the JWT on the device between launches.
///
/// The backend is stateless — it never stores a session — so "staying logged in"
/// is entirely the client holding on to this string until it expires.
///
/// `SharedPreferences` is plain, unencrypted storage. That is fine for a course
/// project; a real app would use `flutter_secure_storage` instead.
class TokenStorage {
  SharedPreferences? _prefs;

  /// Called once from `InitialBinding` before the first screen is built.
  Future<TokenStorage> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String? get token => _prefs?.getString(AppConstant.keyToken);

  String? get username => _prefs?.getString(AppConstant.keyUsername);

  bool get hasToken => (token ?? '').isNotEmpty;

  Future<void> save({required String token, required String username}) async {
    await _prefs?.setString(AppConstant.keyToken, token);
    await _prefs?.setString(AppConstant.keyUsername, username);
  }

  /// Called on logout and whenever the API answers 401.
  Future<void> clear() async {
    await _prefs?.remove(AppConstant.keyToken);
    await _prefs?.remove(AppConstant.keyUsername);
  }
}
