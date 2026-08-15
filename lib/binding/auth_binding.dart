import 'package:get/get.dart';

import '../controller/auth_controller.dart';

/// Supplies [AuthController] to the login and register routes.
///
/// `lazyPut` builds it on first use and GetX disposes it when the route is
/// popped, which is what calls `onClose` and frees the text controllers.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
