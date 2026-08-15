import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/main_controller.dart';
import '../core/value/app_color.dart';
import 'home/home_screen.dart';
import 'post/post_list_screen.dart';
import 'setting/setting_screen.dart';
import 'user/user_list_screen.dart';

/// The tabbed shell the app lands on after login.
///
/// The body is an [IndexedStack], not a plain swap: it keeps all three tabs
/// alive, so scroll position, loaded pages and search text survive switching
/// away and back. Building only the visible tab would reset them every time.
///
/// Each tab is a full `Scaffold` of its own, which is what lets them keep their
/// own app bar, FAB and drawer without this shell knowing anything about them.
class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const <Widget>[
            HomeScreen(),
            PostListScreen(),
            UserListScreen(),
            SettingScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          indicatorColor: AppColor.primaryLight,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: AppColor.primary),
              label: 'Home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.article_outlined),
              selectedIcon: const Icon(Icons.article, color: AppColor.primary),
              label: 'Posts'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people, color: AppColor.primary),
              label: 'Users'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings, color: AppColor.primary),
              label: 'Settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
