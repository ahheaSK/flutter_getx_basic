import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/model/user_model.dart';
import '../data/service/auth_service.dart';
import '../core/util/api_exception.dart';
import '../data/service/sse_service.dart';
import '../route/app_route.dart';
import '../util/ui_util.dart';

/// The settings tab: who is signed in, language, and logout.
///
/// It holds no Either of its own — nothing here calls the API except `logout`,
/// which is local (the backend keeps no session to end).
class SettingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SseService _sseService = Get.find<SseService>();

  static const Locale localeKm = Locale('km', 'KH');
  static const Locale localeEn = Locale('en', 'US');

  /// Drives the language row; `.obs` so the row updates the moment it changes.
  final isKhmer = true.obs;

  /// The signed-in user, loaded from `/api/users/me`.
  ///
  /// The token only carries the username, so the nickname and avatar have to be
  /// fetched — and re-fetched after the profile form pops.
  final currentUser = Rxn<UserModel>();
  final isLoadingProfile = false.obs;

  String get username => _authService.currentUsername ?? '';

  @override
  void onInit() {
    super.onInit();
    // Get.locale is null until the first switch; the app starts in Khmer.
    isKhmer.value = (Get.locale ?? localeKm).languageCode == 'km';
    loadProfile();
  }

  /// Loads the current user. Failures are quiet: the card falls back to the
  /// username from the token, which is always available offline.
  Future<void> loadProfile() async {
    isLoadingProfile.value = true;
    final result = await _authService.me();
    isLoadingProfile.value = false;

    result.fold(
      (ApiException _) => currentUser.value = null,
      (UserModel user) => currentUser.value = user,
    );
  }

  /// Opens the existing user form on the signed-in account.
  ///
  /// Reuses `UserFormScreen` rather than duplicating it — that screen already
  /// does nickname editing and avatar upload, and it decides between create and
  /// edit purely from the argument it is given.
  Future<void> editProfile() async {
    final UserModel? user = currentUser.value;
    if (user == null) {
      await loadProfile();
      if (currentUser.value == null) {
        UiUtil.error('Could not load your profile'.tr);
        return;
      }
    }

    await Get.toNamed<void>(AppRoute.userForm, arguments: currentUser.value);
    // The form may have changed the name or the photo, so re-read it.
    await loadProfile();
  }

  /// Rebuilds every widget that used `.tr` — no restart, no state lost.
  void toggleLanguage() {
    isKhmer.value = !isKhmer.value;
    Get.updateLocale(isKhmer.value ? localeKm : localeEn);
  }

  Future<void> logout() async {
    final bool ok = await UiUtil.confirm(
      title: 'Logout'.tr,
      message: 'You will need to sign in again.'.tr,
      confirmText: 'Logout'.tr,
    );
    if (!ok) return;

    // Close the event stream before dropping the token, or the server would
    // keep an orphaned emitter open until its own timeout.
    await _sseService.disconnect();
    await _authService.logout();
    Get.offAllNamed(AppRoute.login);
  }
}
