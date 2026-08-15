import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'binding/dependency_injection_binding.dart';
import 'core/value/app_theme.dart';
import 'route/app_page.dart';
import 'route/app_route.dart';
import 'util/languages.dart';

Future<void> main() async {
  // Required before any plugin call — DependencyInjectionBinding reads the
  // saved token from SharedPreferences, which is a plugin.
  WidgetsFlutterBinding.ensureInitialized();

  // Awaited before runApp so the first screen already has its services.
  await DependencyInjectionBinding.init();

  runApp(const MyApp());
}

/// `GetMaterialApp` instead of `MaterialApp`: it installs the navigator that
/// lets controllers route and show snackbars without a `BuildContext`, and it
/// is what wires up `translations` / `locale` below.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Basic'.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // --- Language -----------------------------------------------------------
      // `translations` holds the app's own strings; `.tr` on any String reads
      // from it. `locale` is what the app starts in, and `fallbackLocale` is
      // used for any key the active locale is missing.
      //
      // To follow the phone's language instead of forcing Khmer, swap `locale`
      // for `Get.deviceLocale`. To switch at runtime:
      //     Get.updateLocale(const Locale('en', 'US'));
      translations: Languages(),
      locale: const Locale('km', 'KH'),
      fallbackLocale: const Locale('en', 'US'),

      // These translate Flutter's *own* widgets — the text-selection menu, the
      // date picker, tooltips. Without them a non-English locale falls back to
      // English inside those built-in widgets.
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('km', 'KH'), Locale('en', 'US')],

      initialRoute: AppRoute.splash,
      getPages: AppPage.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
