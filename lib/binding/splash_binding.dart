import 'package:get/get.dart';

import '../controller/splash_controller.dart';

/// Supplies [SplashController] to the very first route.
///
/// `Get.put` here, not `Get.lazyPut` — and that difference is the whole reason
/// this screen works.
///
/// `lazyPut` only registers a *factory*; the controller is built on the first
/// `Get.find<T>()`, which for a `GetView` is the `controller` getter. But
/// [SplashScreen] draws nothing from its controller — just a logo and a
/// spinner — so nothing would ever call `Get.find`, the controller would never
/// be constructed, `onReady()` would never fire, and the splash would spin
/// forever.
///
/// `Get.put` constructs it immediately, when the route's dependencies are
/// registered. Use it for any controller whose job is a side effect (redirect,
/// analytics ping, background sync) rather than data the screen reads.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
