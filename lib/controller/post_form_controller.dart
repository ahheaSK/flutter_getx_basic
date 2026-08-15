import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/util/api_exception.dart';
import '../data/model/post_model.dart';
import '../data/service/post_service.dart';
import '../util/ui_util.dart';

/// Create and edit a post, in one controller.
///
/// Exactly the shape of [UserFormController]: the mode comes from
/// `Get.arguments` — a [PostModel] means edit, null means create — so one
/// screen and one route serve both.
class PostFormController extends GetxController {
  final PostService _postService = Get.find<PostService>();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleC = TextEditingController();
  final TextEditingController contentC = TextEditingController();

  final isSaving = false.obs;
  final isUploading = false.obs;
  final published = true.obs;

  /// The post being edited, or null in create mode.
  final editing = Rxn<PostModel>();

  /// A photo chosen but not uploaded yet (create mode has no id to upload to).
  final pickedImage = Rxn<File>();

  bool get isEdit => editing.value != null;

  String get title => isEdit ? 'Edit post'.tr : 'New post'.tr;

  @override
  void onInit() {
    super.onInit();
    final Object? argument = Get.arguments;
    if (argument is PostModel) {
      editing.value = argument;
      titleC.text = argument.title;
      contentC.text = argument.content ?? '';
      published.value = argument.published;
    }
  }

  @override
  void onClose() {
    titleC.dispose();
    contentC.dispose();
    super.onClose();
  }

  void togglePublished(bool value) => published.value = value;

  /// Compressed before upload — a phone photo is several MB and the backend
  /// answers 413 above 5.
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (file == null) return;

      pickedImage.value = File(file.path);

      final PostModel? post = editing.value;
      if (post != null) await _upload(post.id, file.path);
    } catch (e) {
      UiUtil.error('${'Could not open the picker'.tr}: $e');
    }
  }

  Future<void> _upload(int id, String path) async {
    isUploading.value = true;
    final result = await _postService.uploadImage(id, path);
    isUploading.value = false;

    result.fold(
      (ApiException error) {
        UiUtil.error(error.message, title: 'Upload failed'.tr);
        pickedImage.value = null;
      },
      (PostModel updated) {
        editing.value = updated;
        UiUtil.success('Photo updated'.tr);
      },
    );
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving.value = true;
    final PostModel? existing = editing.value;

    // Create and update return the same shape, so the branch only picks the
    // request; everything after it is shared.
    final result = existing == null
        ? await _postService.create(
            title: titleC.text.trim(),
            content: contentC.text.trim(),
            published: published.value,
          )
        : await _postService.update(
            existing.id,
            title: titleC.text.trim(),
            content: contentC.text.trim(),
            published: published.value,
          );

    await result.fold(
      (ApiException error) async {
        isSaving.value = false;
        // Editing someone else's post lands here: the backend answers
        // "You can only modify your own posts".
        UiUtil.error(error.message, title: 'Could not save'.tr);
      },
      (PostModel saved) async {
        // A photo chosen before saving can only be uploaded now, because the
        // endpoint needs the id the server just assigned.
        final File? photo = pickedImage.value;
        if (existing == null && photo != null) {
          await _postService.uploadImage(saved.id, photo.path);
        }

        isSaving.value = false;
        UiUtil.success(
          (existing == null ? '@name created' : '@name updated').trParams(
            <String, String>{'name': saved.title},
          ),
        );
        // The list refreshes itself from the SSE frame this write produces.
        Get.back<void>();
      },
    );
  }
}
