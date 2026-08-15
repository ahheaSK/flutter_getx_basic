import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../util/validator.dart';
import '../../widget/app_button.dart';
import '../../widget/app_text_field.dart';

/// Sign-in screen.
///
/// Extends `GetView<AuthController>`, which gives a ready-made `controller`
/// getter — no `Get.find` call and no `StatefulWidget` needed, because all the
/// state lives in the controller.
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimen.spaceLg),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppDimen.spaceXl),
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: AppColor.primary,
                  ),
                  const SizedBox(height: AppDimen.spaceMd),
                  Text(
                    'Welcome back'.tr,
                    style: AppTextStyle.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimen.spaceXs),
                  Text(
                    'Sign in to your account'.tr,
                    style: AppTextStyle.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimen.spaceXl),

                  AppTextField(
                    label: 'Username'.tr,
                    hint: 'admin@example.com',
                    controller: controller.usernameC,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    textInputAction: TextInputAction.next,
                    // Login only checks presence: the server decides whether
                    // the value is correct, and the strength rules would lock
                    // out accounts created before they existed.
                    validator: (String? v) =>
                        Validator.required(v, fieldKey: 'Username'),
                  ),
                  const SizedBox(height: AppDimen.spaceMd),

                  Obx(
                    () => AppTextField(
                      label: 'Password'.tr,
                      hint: '••••••••',
                      controller: controller.passwordC,
                      obscureText: controller.obscurePassword.value,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.login(),
                      validator: (String? v) =>
                          Validator.required(v, fieldKey: 'Password'),
                      suffix: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: AppDimen.iconMd,
                          color: AppColor.textSecondary,
                        ),
                        onPressed: controller.toggleObscure,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimen.spaceLg),

                  // Only this button rebuilds while the request runs — the
                  // rest of the form is untouched.
                  Obx(
                    () => AppButton(
                      label: 'Login'.tr,
                      icon: Icons.login,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.login,
                    ),
                  ),
                  const SizedBox(height: AppDimen.spaceMd),

                  TextButton(
                    onPressed: controller.goToRegister,
                    child: Text("Don't have an account?".tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
