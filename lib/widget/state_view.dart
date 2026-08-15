import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/value/app_color.dart';
import '../core/value/app_dimen.dart';
import '../core/value/app_text_style.dart';
import 'app_button.dart';

/// Full-screen placeholder for "nothing here yet".
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimen.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: AppColor.textDisabled),
            const SizedBox(height: AppDimen.spaceMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.caption,
            ),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: AppDimen.spaceLg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-screen error with a Retry button.
///
/// Used when the *first* load fails; later failures surface as a snackbar so
/// the list already on screen is not thrown away.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimen.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 56, color: AppColor.danger),
            const SizedBox(height: AppDimen.spaceMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.body,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppDimen.spaceLg),
              AppButton(
                label: 'Retry'.tr,
                icon: Icons.refresh,
                onPressed: onRetry,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centred spinner, so screens do not each build their own.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
