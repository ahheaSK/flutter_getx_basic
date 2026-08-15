import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/user_form_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../data/model/user_model.dart';
import '../../util/validator.dart';
import '../../widget/app_button.dart';
import '../../widget/app_text_field.dart';
import '../../widget/user_avatar.dart';

/// Create or edit a user — one screen for both, decided by `Get.arguments`.
class UserFormScreen extends GetView<UserFormController> {
  const UserFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.title))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimen.spaceLg),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(child: _AvatarPicker(controller: controller)),
                const SizedBox(height: AppDimen.spaceLg),

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
                  label: 'Nickname'.tr,
                  hint: 'The server generates one if you leave this empty'.tr,
                  controller: controller.nickNameC,
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) => Validator.optionalMaxLength(v, 100),
                ),

                // Password exists only on create: the backend's update endpoint
                // has no password field, since credential changes belong on
                // their own route.
                Obx(
                  () => controller.isEdit
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: AppDimen.spaceMd),
                          child: AppTextField(
                            label: 'Password'.tr,
                            hint: 'Student@123',
                            controller: controller.passwordC,
                            obscureText: controller.obscurePassword.value,
                            prefixIcon: Icons.lock_outline,
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
                ),

                const SizedBox(height: AppDimen.spaceXl),
                Obx(
                  () => AppButton(
                    label: controller.isEdit ? 'Update'.tr : 'Create user'.tr,
                    icon: Icons.check,
                    isLoading: controller.isSaving.value,
                    onPressed: controller.save,
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

/// Tappable avatar that opens a gallery / camera sheet.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.controller});

  final UserFormController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final UserModel? user = controller.editing.value;

      return Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              if (user != null)
                UserAvatar(
                  user: user,
                  size: AppDimen.avatarLg,
                  localFile: controller.pickedImage.value,
                )
              else
                _PlaceholderAvatar(file: controller.pickedImage.value),
              Material(
                color: AppColor.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _showSourceSheet(context),
                  child: const Padding(
                    padding: EdgeInsets.all(AppDimen.spaceSm),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimen.spaceSm),
          if (controller.isUploading.value)
            Text('Uploading...'.tr, style: AppTextStyle.caption)
          else
            Text(
              controller.isEdit
                  ? 'Tap to replace the photo'.tr
                  : 'Photo uploads after the user is created'.tr,
              style: AppTextStyle.caption,
            ),
        ],
      );
    });
  }

  /// In create mode the photo is uploaded only after the user exists, because
  /// the upload endpoint is `/api/users/{id}/image` and there is no id yet.
  void _showSourceSheet(BuildContext context) {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimen.radiusLg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppDimen.spaceSm),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('Choose from gallery'.tr),
                onTap: () {
                  Get.back<void>();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text('Take a photo'.tr),
                onTap: () {
                  Get.back<void>();
                  controller.pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: AppDimen.spaceSm),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar stand-in for create mode, where no [UserModel] exists yet.
class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar({this.file});

  final File? file;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimen.avatarLg,
      height: AppDimen.avatarLg,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primaryLight,
        border: Border.all(color: AppColor.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: file == null
          ? const Icon(Icons.person_outline, size: 40, color: AppColor.primary)
          : Image.file(file!, fit: BoxFit.cover),
    );
  }
}
