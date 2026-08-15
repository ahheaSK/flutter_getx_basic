import 'package:get/get.dart';

import '../controller/user_form_controller.dart';

/// Supplies [UserFormController] to the create / edit route.
///
/// A fresh instance per visit is deliberate: reusing one would carry the last
/// user's text into the next form.
class UserFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserFormController>(() => UserFormController());
  }
}
