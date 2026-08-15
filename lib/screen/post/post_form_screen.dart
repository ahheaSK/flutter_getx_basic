import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/post_form_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../data/model/post_model.dart';
import '../../util/validator.dart';
import '../../widget/app_button.dart';
import '../../widget/app_text_field.dart';

/// Create or edit a post — one screen for both, decided by `Get.arguments`.
class PostFormScreen extends GetView<PostFormController> {
  const PostFormScreen({super.key});

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
                const _CoverPicker(),
                const SizedBox(height: AppDimen.spaceLg),

                AppTextField(
                  label: 'Title'.tr,
                  hint: 'My first post'.tr,
                  controller: controller.titleC,
                  prefixIcon: Icons.title,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      Validator.required(v, fieldKey: 'Title'),
                ),
                const SizedBox(height: AppDimen.spaceMd),

                Text('Content'.tr, style: AppTextStyle.caption),
                const SizedBox(height: AppDimen.spaceXs),
                TextFormField(
                  controller: controller.contentC,
                  maxLines: 6,
                  style: AppTextStyle.body,
                  decoration: InputDecoration(hintText: 'Write something…'.tr),
                ),
                const SizedBox(height: AppDimen.spaceMd),

                // Drafts stay listable but are marked in the list.
                Obx(
                  () => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: controller.published.value,
                    activeThumbColor: AppColor.primary,
                    title: Text('Published'.tr, style: AppTextStyle.body),
                    subtitle: Text(
                      controller.published.value
                          ? 'Visible to everyone'.tr
                          : 'Kept as a draft'.tr,
                      style: AppTextStyle.caption,
                    ),
                    onChanged: controller.togglePublished,
                  ),
                ),

                const SizedBox(height: AppDimen.spaceLg),
                Obx(
                  () => AppButton(
                    label: controller.isEdit ? 'Update'.tr : 'Create post'.tr,
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

/// Tappable cover image that opens a gallery / camera sheet.
class _CoverPicker extends StatelessWidget {
  const _CoverPicker();

  @override
  Widget build(BuildContext context) {
    final PostFormController controller = Get.find<PostFormController>();

    return Obx(() {
      final PostModel? post = controller.editing.value;
      final File? local = controller.pickedImage.value;
      final String? url = post?.fullImageUrl;

      return Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => _showSourceSheet(context, controller),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                borderRadius: BorderRadius.circular(AppDimen.radiusMd),
                border: Border.all(color: AppColor.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: local != null
                  ? Image.file(local, fit: BoxFit.cover, width: double.infinity)
                  : (url != null
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, _, _) =>
                                const _CoverPlaceholder(),
                          )
                        : const _CoverPlaceholder()),
            ),
          ),
          const SizedBox(height: AppDimen.spaceSm),
          if (controller.isUploading.value)
            Text('Uploading...'.tr, style: AppTextStyle.caption)
          else
            Text(
              controller.isEdit
                  ? 'Tap to replace the photo'.tr
                  : 'Photo uploads after the post is created'.tr,
              style: AppTextStyle.caption,
            ),
        ],
      );
    });
  }

  void _showSourceSheet(BuildContext context, PostFormController controller) {
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

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 40,
        color: AppColor.primary,
      ),
    );
  }
}
