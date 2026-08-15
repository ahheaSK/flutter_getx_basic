import 'package:get/get.dart';

import '../controller/connection_controller.dart';
import '../core/util/api_client.dart';
import '../core/util/token_storage.dart';
import '../data/service/auth_service.dart';
import '../data/service/post_service.dart';
import '../data/service/slider_service.dart';
import '../data/service/sse_service.dart';
import '../data/service/user_service.dart';

/// Registers everything that must outlive any single screen.
///
/// Called once from `main()` before `runApp`, so the first screen already has
/// its services. `permanent: true` keeps them for the whole app run — the Dio
/// client, the stored token and the SSE connection survive navigation, unlike
/// controllers, which GetX disposes when their route is popped.
///
/// `init` is async because the token has to be read off disk before
/// [ApiClient] can attach it to the very first request.
///
/// Order matters: each service is built from the ones above it.
class DependencyInjectionBinding {
  const DependencyInjectionBinding._();

  static Future<void> init() async {
    // SharedPreferences is a plugin, so this needs the Flutter binding to be
    // initialised first — main() does that before calling here.
    final TokenStorage storage = await TokenStorage().init();
    Get.put<TokenStorage>(storage, permanent: true);

    Get.put<ApiClient>(ApiClient(storage), permanent: true);
    final ApiClient api = Get.find<ApiClient>();

    Get.put<AuthService>(AuthService(api, storage), permanent: true);
    Get.put<UserService>(UserService(api), permanent: true);
    Get.put<PostService>(PostService(api), permanent: true);
    Get.put<SliderService>(SliderService(api), permanent: true);
    Get.put<SseService>(SseService(api, storage), permanent: true);

    // `put`, not `lazyPut`: this controller's job is to *listen*. Nothing calls
    // Get.find on it except the drawer's status tile, so a lazy registration
    // would sit unbuilt and the connectivity subscription would never start —
    // the same trap that kept the splash screen spinning.
    Get.put<ConnectionController>(ConnectionController(), permanent: true);
  }
}
