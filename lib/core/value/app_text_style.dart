import 'package:flutter/material.dart';

import 'app_color.dart';

/// Named text styles, so screens never hand-roll a `TextStyle`.
class AppTextStyle {
  const AppTextStyle._();

  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColor.textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColor.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColor.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AppColor.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle error = TextStyle(
    fontSize: 13,
    color: AppColor.danger,
  );
}
