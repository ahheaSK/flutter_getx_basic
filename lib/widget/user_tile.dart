import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/value/app_color.dart';
import '../core/value/app_dimen.dart';
import '../core/value/app_text_style.dart';
import '../data/model/user_model.dart';
import '../util/formatter.dart';
import 'user_avatar.dart';

/// One row in the user list.
///
/// Kept free of controllers: every action is a callback, so the same tile could
/// be reused on another screen with different behaviour.
class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleEnabled,
  });

  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleEnabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimen.spaceSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimen.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.spaceMd),
          child: Row(
            children: <Widget>[
              UserAvatar(user: user, size: AppDimen.avatarSm),
              const SizedBox(width: AppDimen.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!user.enabled) ...<Widget>[
                          const SizedBox(width: AppDimen.spaceSm),
                          const _DisabledChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.username,
                      style: AppTextStyle.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Created @time'.trParams(<String, String>{
                        'time': Formatter.relative(user.createdAt),
                      }),
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.textDisabled,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColor.textSecondary,
                ),
                onSelected: (String value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'toggle':
                      onToggleEnabled?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_outlined),
                      title: Text('Edit'.tr),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'toggle',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        user.enabled ? Icons.block : Icons.check_circle_outline,
                      ),
                      title: Text(user.enabled ? 'Disable'.tr : 'Enable'.tr),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.delete_outline,
                        color: AppColor.danger,
                      ),
                      title: Text(
                        'Delete'.tr,
                        style: const TextStyle(color: AppColor.danger),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small badge shown when `enabled` is false.
class _DisabledChip extends StatelessWidget {
  const _DisabledChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.dangerLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Disabled'.tr,
        style: const TextStyle(
          fontSize: 11,
          color: AppColor.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
