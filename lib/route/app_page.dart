import 'package:get/get.dart';

import '../binding/auth_binding.dart';
import '../binding/main_binding.dart';
import '../binding/post_form_binding.dart';
import '../binding/splash_binding.dart';
import '../binding/user_binding.dart';
import '../binding/user_form_binding.dart';
import '../screen/auth/login_screen.dart';
import '../screen/auth/register_screen.dart';
import '../screen/main_screen.dart';
import '../screen/post/post_form_screen.dart';
import '../screen/splash/splash_screen.dart';
import '../screen/user/user_detail_screen.dart';
import '../screen/user/user_form_screen.dart';
import '../screen/user/user_list_screen.dart';
import 'app_route.dart';

/// The route table handed to `GetMaterialApp`.
///
/// Each page pairs a screen with its binding, so the controller is created as
/// the route opens and disposed as it closes — no manual wiring in the widget.
class AppPage {
  const AppPage._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoute.splash,
      page: SplashScreen.new,
      binding: SplashBinding(),
    ),
    GetPage<void>(
      name: AppRoute.login,
      page: LoginScreen.new,
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: AppRoute.register,
      page: RegisterScreen.new,
      // Same binding as login: both screens drive one AuthController.
      binding: AuthBinding(),
    ),
    GetPage<void>(
      name: AppRoute.main,
      page: MainScreen.new,
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: AppRoute.userList,
      page: UserListScreen.new,
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: AppRoute.postForm,
      page: PostFormScreen.new,
      binding: PostFormBinding(),
    ),
    GetPage<void>(
      name: AppRoute.userForm,
      page: UserFormScreen.new,
      binding: UserFormBinding(),
    ),
    GetPage<void>(name: AppRoute.userDetail, page: UserDetailScreen.new),
  ];
}
