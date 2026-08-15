import 'package:flutter/material.dart';

import '../core/value/app_color.dart';
import '../core/value/app_dimen.dart';
import '../core/value/app_text_style.dart';

/// The app's primary button.
///
/// It owns the busy state itself: while [isLoading] is true the label is
/// replaced by a spinner and `onPressed` is detached, so a double tap cannot
/// fire the same request twice.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color = AppColor.primary,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color color;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      height: AppDimen.buttonHeight,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimen.radiusSm),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: AppDimen.iconMd, color: Colors.white),
                    const SizedBox(width: AppDimen.spaceSm),
                  ],
                  Text(label, style: AppTextStyle.button),
                ],
              ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
