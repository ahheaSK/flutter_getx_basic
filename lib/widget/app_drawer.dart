import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/connection_controller.dart';
import '../core/value/app_color.dart';
import '../core/value/app_dimen.dart';
import '../core/value/app_text_style.dart';
import '../data/service/auth_service.dart';
import '../data/service/sse_service.dart';
import '../route/app_route.dart';
import '../util/ui_util.dart';

/// The app's navigation drawer.
///
/// It depends only on the permanent services, never on a screen's controller,
/// so the same widget can be dropped into any `Scaffold` without wiring.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    final String username = authService.currentUsername ?? '';

    return Drawer(
      backgroundColor: AppColor.surface,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            _Header(username: username),
            const SizedBox(height: AppDimen.spaceSm),

            _Item(
              icon: Icons.people_outline,
              label: 'Users'.tr,
              onTap: () {
                Get.back<void>(); // close the drawer first
                if (Get.currentRoute != AppRoute.main) {
                  Get.offAllNamed(AppRoute.main);
                }
              },
            ),
            _Item(
              icon: Icons.person_add_alt,
              label: 'New user'.tr,
              onTap: () {
                Get.back<void>();
                Get.toNamed(AppRoute.userForm);
              },
            ),

            const Divider(height: AppDimen.spaceLg, color: AppColor.border),

            const _LanguageTile(),
            const _ConnectionTile(),

            const Spacer(),
            const Divider(height: 1, color: AppColor.border),

            _Item(
              icon: Icons.logout,
              label: 'Logout'.tr,
              color: AppColor.danger,
              onTap: () => _logout(),
            ),
            const SizedBox(height: AppDimen.spaceSm),
          ],
        ),
      ),
    );
  }

  /// Kept here rather than in a controller so the drawer works on any screen.
  Future<void> _logout() async {
    Get.back<void>(); // close the drawer before the dialog

    final bool ok = await UiUtil.confirm(
      title: 'Logout'.tr,
      message: 'You will need to sign in again.'.tr,
      confirmText: 'Logout'.tr,
    );
    if (!ok) return;

    await Get.find<SseService>().disconnect();
    await Get.find<AuthService>().logout();
    Get.offAllNamed(AppRoute.login);
  }
}

/// Teal header with the signed-in account.
class _Header extends StatelessWidget {
  const _Header({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimen.spaceLg),
      color: AppColor.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              _initials,
              style: const TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: AppDimen.spaceMd),
          Text(
            'GetX Basic'.tr,
            style: AppTextStyle.heading.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            username.isEmpty ? '—' : username,
            style: AppTextStyle.caption.copyWith(color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// First two letters of the local part — the domain says nothing about who
  /// this is, so it is dropped.
  String get _initials {
    if (username.isEmpty) return '?';
    final String local = username.split('@').first;
    return (local.length >= 2 ? local.substring(0, 2) : local).toUpperCase();
  }
}

/// Switches between Khmer and English at runtime.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  static const Locale _km = Locale('km', 'KH');
  static const Locale _en = Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
    // Get.locale can be null before the first switch; the app starts in Khmer.
    final bool isKhmer = (Get.locale ?? _km).languageCode == 'km';

    return ListTile(
      leading: const Icon(Icons.translate, color: AppColor.textSecondary),
      title: Text('Language'.tr, style: AppTextStyle.body),
      trailing: Text(
        isKhmer ? 'ខ្មែរ' : 'English',
        style: AppTextStyle.caption.copyWith(
          color: AppColor.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      // updateLocale rebuilds every widget that used `.tr`, with no restart
      // and no state lost.
      onTap: () => Get.updateLocale(isKhmer ? _en : _km),
    );
  }
}

/// Live online / offline indicator, fed by [ConnectionController].
class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile();

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

/// One tappable row, so every drawer item looks the same.
class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColor.textSecondary),
      title: Text(
        label,
        style: AppTextStyle.body.copyWith(color: color ?? AppColor.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
