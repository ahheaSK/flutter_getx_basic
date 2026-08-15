import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../util/validator.dart';
import '../../widget/app_button.dart';
import '../../widget/app_text_field.dart';

/// Create an account.
///
/// Unlike login, this screen applies the full password rules up front — they
/// match the backend's `UserValidator`, so the user sees the requirement before
/// a round-trip rather than after a 400.
class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create your account'.tr)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimen.spaceLg),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  label: 'Username (email)'.tr,
                  hint: 'student@example.com',
                  controller: controller.usernameC,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                  textInputAction: TextInputAction.next,
                  validator: Validator.username,
                ),
                const SizedBox(height: AppDimen.spaceMd),

                AppTextField(
                  label: 'Nickname (optional)'.tr,
                  hint: 'The server generates one if you leave this empty'.tr,
                  controller: controller.nickNameC,
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) => Validator.optionalMaxLength(v, 100),
                ),
                const SizedBox(height: AppDimen.spaceMd),

                Obx(
                  () => AppTextField(
                    label: 'Password'.tr,
                    hint: 'Student@123',
                    controller: controller.passwordC,
                    obscureText: controller.obscurePassword.value,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.register(),
                    validator: Validator.password,
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
                const SizedBox(height: AppDimen.spaceSm),

                Text(
                  'At least 8 characters with an uppercase, a lowercase, a number and a symbol.'
                      .tr,
                  style: AppTextStyle.caption,
                ),
                const SizedBox(height: AppDimen.spaceLg),

                Obx(
                  () => AppButton(
                    label: 'Register'.tr,
                    icon: Icons.person_add_alt,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.register,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
