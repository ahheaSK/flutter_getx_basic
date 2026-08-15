import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_dimen.dart';
import 'app_text_style.dart';

/// Assembles the tokens into the single [ThemeData] handed to `GetMaterialApp`.
///
/// Setting defaults here means a widget only overrides a style when it is
/// genuinely different, not to fix an inconsistent default.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.primary,
      primary: AppColor.primary,
    ).copyWith(surface: AppColor.surface),
    scaffoldBackgroundColor: AppColor.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.surface,
      foregroundColor: AppColor.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyle.heading,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColor.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimen.spaceMd,
        vertical: AppDimen.spaceMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimen.radiusSm),
        borderSide: const BorderSide(color: AppColor.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimen.radiusSm),
        borderSide: const BorderSide(color: AppColor.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimen.radiusSm),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimen.radiusSm),
        borderSide: const BorderSide(color: AppColor.danger),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColor.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimen.radiusMd),
        side: const BorderSide(color: AppColor.border),
      ),
    ),
  );
}
