import 'package:flutter/material.dart';

import '../core/value/app_color.dart';
import '../core/value/app_dimen.dart';
import '../core/value/app_text_style.dart';

/// Labelled text field used by every form.
///
/// Wrapping `TextFormField` here means the label placement, spacing and error
/// styling are decided once instead of in each screen.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyle.caption),
        const SizedBox(height: AppDimen.spaceXs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          style: AppTextStyle.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColor.textDisabled),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: AppDimen.iconMd,
                    color: AppColor.textSecondary,
                  ),
            suffixIcon: suffix,
          ),
          // Re-validate as the user types, but only after the first failure,
          // so the form does not shout at someone still filling it in.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
        ),
      ],
    );
  }
}
