import 'package:get/get.dart';

import '../controller/post_form_controller.dart';

/// Supplies [PostFormController] to the create / edit route.
///
/// A fresh instance per visit: reusing one would carry the previous post's
/// text into the next form.
class PostFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostFormController>(() => PostFormController());
  }
}
