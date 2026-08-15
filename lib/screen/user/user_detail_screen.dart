import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../data/model/user_model.dart';
import '../../route/app_route.dart';
import '../../util/formatter.dart';
import '../../widget/app_button.dart';
import '../../widget/user_avatar.dart';

/// Read-only view of one user.
///
/// A plain `StatelessWidget` rather than a `GetView`: the row arrives through
/// `Get.arguments` and nothing on this screen changes, so there is no state to
/// manage and no controller to create.
class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? argument = Get.arguments;
    if (argument is! UserModel) {
      return Scaffold(body: Center(child: Text('No user passed'.tr)));
    }
    final UserModel user = argument;

    return Scaffold(
      appBar: AppBar(title: Text('User detail'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimen.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  UserAvatar(user: user, size: AppDimen.avatarLg),
                  const SizedBox(height: AppDimen.spaceMd),
                  Text(user.displayName, style: AppTextStyle.title),
                  const SizedBox(height: AppDimen.spaceXs),
                  Text(user.username, style: AppTextStyle.caption),
                  const SizedBox(height: AppDimen.spaceSm),
                  _StatusChip(enabled: user.enabled),
                ],
              ),
            ),
            const SizedBox(height: AppDimen.spaceXl),

            _DetailRow(label: 'ID'.tr, value: '${user.id}'),
            _DetailRow(label: 'Username'.tr, value: user.username),
            _DetailRow(label: 'Nickname'.tr, value: user.nickName ?? 'N/A'.tr),
            _DetailRow(
              label: 'Image file'.tr,
              value: user.imageName ?? 'No image uploaded'.tr,
            ),
            _DetailRow(
              label: 'Created'.tr,
              value: Formatter.dateTime(user.createdAt),
            ),
            _DetailRow(
              label: 'Updated'.tr,
              value: Formatter.dateTime(user.updatedAt),
            ),

            const SizedBox(height: AppDimen.spaceXl),
            AppButton(
              label: 'Edit'.tr,
              icon: Icons.edit,
              onPressed: () =>
                  Get.offAndToNamed(AppRoute.userForm, arguments: user),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label on the left, value on the right, with a divider underneath.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimen.spaceSm),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 110,
                child: Text(label, style: AppTextStyle.caption),
              ),
              Expanded(child: Text(value, style: AppTextStyle.body)),
            ],
          ),
          const SizedBox(height: AppDimen.spaceSm),
          const Divider(height: 1, color: AppColor.border),
        ],
      ),
    );
  }
}

/// Enabled / disabled badge.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.spaceMd,
        vertical: AppDimen.spaceXs,
      ),
      decoration: BoxDecoration(
        color: enabled ? AppColor.successLight : AppColor.dangerLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        enabled ? 'Enabled'.tr : 'Disabled'.tr,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: enabled ? AppColor.success : AppColor.danger,
        ),
      ),
    );
  }
}
