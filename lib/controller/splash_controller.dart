import 'package:get/get.dart';

import '../core/util/api_exception.dart';
import '../core/util/logger.dart';
import '../data/model/user_model.dart';
import '../data/service/auth_service.dart';
import '../data/service/sse_service.dart';
import '../route/app_route.dart';

/// Decides where the app opens: the user list when a token is already stored,
/// the login screen when it is not.
///
/// This controller draws nothing — its only job is the redirect. That is why
/// [SplashBinding] must use `Get.put`, not `Get.lazyPut`: nothing on the screen
/// reads `controller`, so a lazy registration would never be built and the
/// splash would spin forever.
class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SseService _sseService = Get.find<SseService>();

  @override
  void onReady() {
    super.onReady();
    // onReady fires after the first frame, so navigating from here does not
    // fight with the widget that is still being built.
    _decide();
  }

  Future<void> _decide() async {
    Logger.d('Splash', 'deciding… hasToken=${_authService.isLoggedIn}');
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!_authService.isLoggedIn) {
      Logger.d('Splash', 'no token → login');
      Get.offAllNamed(AppRoute.login);
      return;
    }

    // The stored token may have expired while the app was closed. Asking the
    // server who we are is the cheapest way to find out — a 401 clears the
    // token inside ApiClient, so falling back to login is then correct.
    final result = await _authService.me();

    await result.fold(
      // Also covers "backend unreachable": better to show the login screen,
      // where the error is visible, than to sit on a spinner.
      (ApiException error) async {
        Logger.e('Splash', 'token check failed: ${error.message}');
        await _authService.logout();
        Get.offAllNamed(AppRoute.login);
      },
      (UserModel _) async {
        _sseService.connect();
        Logger.d('Splash', 'token valid → main');
        Get.offAllNamed(AppRoute.main);
      },
    );
  }
}
