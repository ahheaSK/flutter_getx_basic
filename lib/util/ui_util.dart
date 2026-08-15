import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/value/app_color.dart';
import '../core/value/app_dimen.dart';

/// Snackbars and dialogs.
///
/// GetX can show these without a `BuildContext`, which is why a controller can
/// call them directly instead of passing context down from the widget tree.
class UiUtil {
  const UiUtil._();

  static void success(String message, {String? title}) {
    _snack(
      title ?? 'Done'.tr,
      message,
      AppColor.success,
      AppColor.successLight,
      Icons.check_circle_outline,
    );
  }

  static void error(String message, {String? title}) {
    _snack(
      title ?? 'Something went wrong'.tr,
      message,
      AppColor.danger,
      AppColor.dangerLight,
      Icons.error_outline,
    );
  }

  static void info(String message, {String? title}) {
    _snack(
      title ?? 'Info'.tr,
      message,
      AppColor.primary,
      AppColor.primaryLight,
      Icons.info_outline,
    );
  }

  static void _snack(
    String title,
    String message,
    Color accent,
    Color background,
    IconData icon,
  ) {
    // Closing the previous one first stops a burst of SSE events from stacking
    // half a dozen snackbars on top of each other.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: background,
      colorText: AppColor.textPrimary,
      icon: Icon(icon, color: accent),
      margin: const EdgeInsets.all(AppDimen.spaceMd),
      borderRadius: AppDimen.radiusSm,
      duration: const Duration(seconds: 3),
    );
  }

  /// Yes / no dialog. Resolves to false when dismissed by tapping outside.
  static Future<bool> confirm({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
  }) async {
    final bool? result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimen.radiusMd),
        ),
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text(cancelText ?? 'Cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? AppColor.danger : AppColor.primary,
            ),
            onPressed: () => Get.back<bool>(result: true),
            child: Text(confirmText ?? 'Confirm'.tr),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
