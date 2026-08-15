import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../controller/main_controller.dart';
import '../controller/post_controller.dart';
import '../controller/setting_controller.dart';
import '../controller/user_controller.dart';

/// Everything the tabbed shell needs.
///
/// All four are created up front rather than lazily, because an `IndexedStack`
/// builds every tab immediately — a lazy registration would be resolved on the
/// first build anyway, so deferring buys nothing and only adds a failure mode.
///
/// Creating them here also means each tab keeps its scroll position and its
/// loaded pages while you switch between tabs.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainController>(MainController());
    Get.put<HomeController>(HomeController());
    Get.put<PostController>(PostController());
    Get.put<UserController>(UserController());
    Get.put<SettingController>(SettingController());
  }
}
