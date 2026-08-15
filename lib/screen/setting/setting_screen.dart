import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/connection_controller.dart';
import '../../controller/setting_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../data/model/user_model.dart';
import '../../widget/app_button.dart';
import '../../widget/user_avatar.dart';

/// Settings tab — account, language, connection, and sign-out.
class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppDimen.spaceXl),
        children: <Widget>[
          const _AccountCard(),

          _SectionTitle('Your account'.tr),
          ListTile(
            leading: const Icon(
              Icons.edit_outlined,
              color: AppColor.textSecondary,
            ),
            title: Text('Edit profile'.tr, style: AppTextStyle.body),
            subtitle: Text(
              'Update your name and photo'.tr,
              style: AppTextStyle.caption,
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColor.textDisabled,
            ),
            onTap: controller.editProfile,
          ),

          _SectionTitle('Preferences'.tr),
          Obx(
            () => ListTile(
              leading: const Icon(
                Icons.translate,
                color: AppColor.textSecondary,
              ),
              title: Text('Language'.tr, style: AppTextStyle.body),
              subtitle: Text(
                'Switch between Khmer and English'.tr,
                style: AppTextStyle.caption,
              ),
              trailing: Text(
                controller.isKhmer.value ? 'ខ្មែរ' : 'English',
                style: AppTextStyle.caption.copyWith(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: controller.toggleLanguage,
            ),
          ),
          const _ConnectionRow(),

          _SectionTitle('About'.tr),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColor.textSecondary,
            ),
            title: Text('Version'.tr, style: AppTextStyle.body),
            trailing: const Text('1.0.0', style: AppTextStyle.caption),
          ),

          const SizedBox(height: AppDimen.spaceXl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimen.spaceMd),
            child: AppButton(
              label: 'Logout'.tr,
              icon: Icons.logout,
              color: AppColor.danger,
              onPressed: controller.logout,
            ),
          ),
        ],
      ),
    );
  }
}

/// Teal card showing the signed-in account.
///
/// Reads the full user from [SettingController.currentUser] once `/me` has
/// answered, and falls back to the username carried in the token until then —
/// so the card is never empty, even offline.
class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final SettingController controller = Get.find<SettingController>();

    return Obx(() {
      final UserModel? user = controller.currentUser.value;
      final String username = user?.username ?? controller.username;

      return Container(
        margin: const EdgeInsets.all(AppDimen.spaceMd),
        padding: const EdgeInsets.all(AppDimen.spaceLg),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(AppDimen.radiusLg),
        ),
        child: Row(
          children: <Widget>[
            if (user != null)
              UserAvatar(user: user, size: 56)
            else
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColor.primary),
              ),
            const SizedBox(width: AppDimen.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Signed in as'.tr,
                    style: AppTextStyle.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.displayName ?? (username.isEmpty ? '—' : username),
                    style: AppTextStyle.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user != null)
                    Text(
                      username,
                      style: AppTextStyle.caption.copyWith(
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Live online/offline row, fed by the permanent [ConnectionController].
class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow();

  @override
  Widget build(BuildContext context) {
    final ConnectionController connection = Get.find<ConnectionController>();

    return Obx(() {
      final bool online = connection.isConnected.value;
      final int type = connection.connectionType.value;

      return ListTile(
        leading: Icon(
          online
              ? (type == 2 ? Icons.signal_cellular_alt : Icons.wifi)
              : Icons.wifi_off,
          color: online ? AppColor.success : AppColor.danger,
        ),
        title: Text('Connection'.tr, style: AppTextStyle.body),
        trailing: Text(
          online ? 'Online'.tr : 'Offline'.tr,
          style: AppTextStyle.caption.copyWith(
            color: online ? AppColor.success : AppColor.danger,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}

/// Small grey heading between groups of rows.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimen.spaceMd,
        AppDimen.spaceLg,
        AppDimen.spaceMd,
        AppDimen.spaceSm,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyle.caption.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AppColor.textDisabled,
        ),
      ),
    );
  }
}
