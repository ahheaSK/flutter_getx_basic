import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/util/api_exception.dart';
import '../data/model/user_model.dart';
import '../data/model/request/user_request.dart';
import '../data/service/user_service.dart';
import '../util/ui_util.dart';

/// Create and edit, in one controller.
///
/// Which mode it is in comes from `Get.arguments`: a [UserModel] means edit,
/// null means create. That is why one screen and one route serve both.
class UserFormController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController nickNameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  final isSaving = false.obs;
  final isUploading = false.obs;
  final obscurePassword = true.obs;

  /// The user being edited, or null in create mode.
  final editing = Rxn<UserModel>();

  /// A photo chosen but not uploaded yet (create mode has no id to upload to).
  final pickedImage = Rxn<File>();

  bool get isEdit => editing.value != null;

  String get title => isEdit ? 'Edit user'.tr : 'New user'.tr;

  @override
  void onInit() {
    super.onInit();
    final Object? argument = Get.arguments;
    if (argument is UserModel) {
      editing.value = argument;
      usernameC.text = argument.username;
      nickNameC.text = argument.nickName ?? '';
    }
  }

  @override
  void onClose() {
    usernameC.dispose();
    nickNameC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.toggle();

  // --- Image ----------------------------------------------------------------

  /// Picks from the gallery or the camera.
  ///
  /// `imageQuality` compresses before upload — a modern phone photo is several
  /// megabytes, and the backend rejects anything over 5 MB with a 413.
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (file == null) return;

      pickedImage.value = File(file.path);

      // In edit mode the user already exists, so upload right away and let the
      // server answer with the new imageUrl.
      final UserModel? user = editing.value;
      if (user != null) await _upload(user.id, file.path);
    } catch (e) {
      UiUtil.error('${'Could not open the picker'.tr}: $e');
    }
  }

  Future<void> _upload(int id, String path) async {
    isUploading.value = true;

    final result = await _userService.uploadImage(id, path);

    isUploading.value = false;

    result.fold(
      (ApiException error) {
        // 413 means the file passed Tomcat's limit — tell the user plainly.
        UiUtil.error(error.message, title: 'Upload failed'.tr);
        pickedImage.value = null;
      },
      (UserModel updated) {
        editing.value = updated;
        UiUtil.success('Photo updated'.tr);
      },
    );
  }

  // --- Save -----------------------------------------------------------------

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving.value = true;

    final UserModel? existing = editing.value;

    // Create and update return the same Either shape, so the branch picks the
    // request and everything after it is shared.
    final result = existing == null
        ? await _userService.create(
            UserCreateRequest(
              username: usernameC.text.trim(),
              password: passwordC.text,
              nickName: nickNameC.text.trim(),
            ),
          )
        : await _userService.update(
            existing.id,
            UserUpdateRequest(
              username: usernameC.text.trim(),
              nickName: nickNameC.text.trim(),
            ),
          );

    await result.fold(
      (ApiException error) async {
        isSaving.value = false;
        UiUtil.error(error.message, title: 'Could not save'.tr);
      },
      (UserModel saved) async {
        // A photo chosen before saving can only be uploaded now, because the
        // upload endpoint needs the id the server just assigned.
        final File? photo = pickedImage.value;
        if (existing == null && photo != null) {
          await _userService.uploadImage(saved.id, photo.path);
        }

        isSaving.value = false;
        UiUtil.success(
          (existing == null ? '@name created' : '@name updated').trParams(
            <String, String>{'name': saved.displayName},
          ),
        );

        // The list refreshes itself from the SSE frame this write produces,
        // so popping is all that is needed here.
        Get.back<void>();
      },
    );
  }
}
