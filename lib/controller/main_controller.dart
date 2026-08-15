import 'package:get/get.dart';

/// Owns which bottom-navigation tab is showing.
///
/// Nothing else: the tabs each have their own controller, so switching tabs is
/// a single int change and never rebuilds their content.
class MainController extends GetxController {
  final currentIndex = 0.obs;

  static const int tabHome = 0;
  static const int tabPosts = 1;
  static const int tabUsers = 2;
  static const int tabSetting = 3;

  void changeTab(int index) => currentIndex.value = index;
}
