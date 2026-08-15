import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/splash_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';

/// Shown while [SplashController] decides between the list and login.
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.people_alt_rounded,
              size: 72,
              color: AppColor.primary,
            ),
            const SizedBox(height: AppDimen.spaceMd),
            Text('GetX Basic'.tr, style: AppTextStyle.title),
            const SizedBox(height: AppDimen.spaceXl),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
