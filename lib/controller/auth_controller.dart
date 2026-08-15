import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/util/api_exception.dart';
import '../data/model/request/auth_request.dart';
import '../data/model/response/auth_response.dart';
import '../data/service/auth_service.dart';
import '../data/service/sse_service.dart';
import '../route/app_route.dart';
import '../util/ui_util.dart';

/// Drives the login and register screens.
///
/// The controller owns the state (`isLoading`, `obscurePassword`) and the
/// text controllers; the screen only reads them. That split is what makes the
/// screen a pure `StatelessWidget`.
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SseService _sseService = Get.find<SseService>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController nickNameC = TextEditingController();

  /// `.obs` makes the value observable; an `Obx` around a widget rebuilds it
  /// whenever this changes.
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill the seeded account so the login screen is testable immediately.
    usernameC.text = 'admin@example.com';
    passwordC.text = 'Admin@123';
  }

  @override
  void onClose() {
    // TextEditingControllers hold native resources — always dispose them.
    usernameC.dispose();
    passwordC.dispose();
    nickNameC.dispose();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.toggle();

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    final result = await _authService.login(
      LoginRequest(username: usernameC.text.trim(), password: passwordC.text),
    );

    isLoading.value = false;

    // fold forces both outcomes to be handled — there is no way to reach the
    // AuthResponse without also saying what happens on failure.
    result.fold(
      // The backend answers "Invalid credentials" / "Account is disabled" —
      // show its wording rather than inventing one here.
      (ApiException error) =>
          UiUtil.error(error.message, title: 'Login failed'.tr),
      (AuthResponse _) {
        _sseService.connect();
        Get.offAllNamed(AppRoute.main);
      },
    );
  }

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    final result = await _authService.register(
      RegisterRequest(
        username: usernameC.text.trim(),
        password: passwordC.text,
        nickName: nickNameC.text.trim(),
      ),
    );

    isLoading.value = false;

    result.fold(
      (ApiException error) =>
          UiUtil.error(error.message, title: 'Registration failed'.tr),
      (AuthResponse _) {
        // Register returns a token as well, so there is no second login step.
        _sseService.connect();
        UiUtil.success('Welcome!'.tr);
        Get.offAllNamed(AppRoute.main);
      },
    );
  }

  /// Clears the fields when moving between login and register, so the
  /// pre-filled admin credentials do not leak into a new account.
  void goToRegister() {
    usernameC.clear();
    passwordC.clear();
    nickNameC.clear();
    Get.toNamed(AppRoute.register);
  }
}
