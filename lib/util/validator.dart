import 'package:get/get.dart';

import '../constant/app_constant.dart';

/// Form validation, kept deliberately in step with the backend's `UserValidator`.
///
/// The server validates again regardless — client rules exist to give an answer
/// without a round-trip, not to be the only check.
///
/// Messages go through `.tr`, so a validation error appears in the active
/// language. `trParams` fills the `@placeholders` in the translation file.
class Validator {
  const Validator._();

  static final RegExp _email = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  /// One lowercase, one uppercase, one digit, one special character.
  static final RegExp _password = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d]).{8,100}$',
  );

  /// Returns null when valid — the shape `TextFormField.validator` expects.
  static String? username(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return '@field is required'.trParams(<String, String>{
        'field': 'Username'.tr,
      });
    }
    if (text.length > AppConstant.usernameMaxLength) {
      return 'Username must not exceed @max characters'.trParams(
        <String, String>{'max': '${AppConstant.usernameMaxLength}'},
      );
    }
    if (!_email.hasMatch(text)) {
      return 'Username must be a valid email address'.tr;
    }
    return null;
  }

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) {
      return '@field is required'.trParams(<String, String>{
        'field': 'Password'.tr,
      });
    }
    if (text.length < AppConstant.passwordMinLength) {
      return 'Password must be at least @min characters'.trParams(
        <String, String>{'min': '${AppConstant.passwordMinLength}'},
      );
    }
    if (!_password.hasMatch(text)) {
      return 'Password needs an uppercase, a lowercase, a number and a symbol'
          .tr;
    }
    return null;
  }

  /// Login only checks presence: the server decides whether it is correct, and
  /// applying the strength rules here would lock out older valid passwords.
  static String? required(String? value, {required String fieldKey}) {
    if ((value ?? '').trim().isEmpty) {
      return '@field is required'.trParams(<String, String>{
        'field': fieldKey.tr,
      });
    }
    return null;
  }

  static String? optionalMaxLength(String? value, int max, {String? fieldKey}) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (text.length > max) {
      return '@field must not exceed @max characters'.trParams(<String, String>{
        'field': (fieldKey ?? 'Nickname').tr,
        'max': '$max',
      });
    }
    return null;
  }
}
