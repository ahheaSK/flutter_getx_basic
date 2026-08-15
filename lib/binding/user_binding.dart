import 'package:get/get.dart';

import '../controller/user_controller.dart';

/// Supplies [UserController] to the user list route.
///
/// `fenix: true` rebuilds the controller if the route is revisited after being
/// disposed — without it, navigating back to a popped list would find nothing.
class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
  }
}
