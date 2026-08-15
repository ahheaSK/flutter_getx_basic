import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/user_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../data/model/user_model.dart';
import '../../widget/app_drawer.dart';
import '../../widget/state_view.dart';
import '../../widget/user_tile.dart';

/// The main screen: a searchable, paginated, live-updating list of users.
class UserListScreen extends GetView<UserController> {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The drawer needs no wiring: Scaffold adds the hamburger button itself.
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('Users'.tr),
        actions: <Widget>[
          // A small dot that turns green once the SSE handshake arrives.
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: AppDimen.spaceSm),
              child: Center(child: _LiveDot(isLive: controller.isLive.value)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Unique tag: IndexedStack keeps every tab alive, so both FABs
        // exist at once and would otherwise share the default Hero tag.
        heroTag: 'user-fab',
        onPressed: controller.openCreate,
        icon: const Icon(Icons.add),
        label: Text('New user'.tr),
      ),
      body: Column(
        children: <Widget>[
          _SearchBar(controller: controller),
          Expanded(
            child: Obx(() {
              // First load — nothing to show yet.
              if (controller.isLoading.value) return const LoadingView();

              // First load failed — offer a retry instead of an empty screen.
              if (controller.errorMessage.isNotEmpty) {
                return ErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.loadFirstPage,
                );
              }

              if (controller.users.isEmpty) {
                return EmptyView(
                  message: controller.searchTerm.isEmpty
                      ? 'No users yet'.tr
                      : 'No user matches "@term"'.trParams(<String, String>{
                          'term': controller.searchTerm.value,
                        }),
                  icon: Icons.people_outline,
                  actionLabel: controller.searchTerm.isEmpty
                      ? 'New user'.tr
                      : 'Clear search'.tr,
                  onAction: controller.searchTerm.isEmpty
                      ? controller.openCreate
                      : controller.clearSearch,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshList,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppDimen.spaceMd,
                    AppDimen.spaceSm,
                    AppDimen.spaceMd,
                    // Leave room so the FAB never covers the last row.
                    AppDimen.spaceXl * 2.5,
                  ),
                  // One extra row at the end: the "loading more" footer.
                  itemCount: controller.users.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == controller.users.length) {
                      return _ListFooter(controller: controller);
                    }
                    final UserModel user = controller.users[index];
                    return UserTile(
                      user: user,
                      onTap: () => controller.openDetail(user),
                      onEdit: () => controller.openEdit(user),
                      onDelete: () => controller.confirmDelete(user),
                      onToggleEnabled: () => controller.toggleEnabled(user),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Search field plus the result count.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final UserController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.surface,
      padding: const EdgeInsets.fromLTRB(
        AppDimen.spaceMd,
        AppDimen.spaceSm,
        AppDimen.spaceMd,
        AppDimen.spaceMd,
      ),
      child: Column(
        children: <Widget>[
          TextField(
            controller: controller.searchC,
            // Typing does not fire a request directly — the controller
            // debounces this value by 400ms first.
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by username'.tr,
              prefixIcon: const Icon(Icons.search, size: AppDimen.iconMd),
              suffixIcon: Obx(
                () => controller.searchTerm.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.close, size: AppDimen.iconMd),
                        onPressed: controller.clearSearch,
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppDimen.spaceSm),
          Obx(
            () => Row(
              children: <Widget>[
                Text(
                  '@shown of @total shown'.trParams(<String, String>{
                    'shown': '${controller.users.length}',
                    'total': '${controller.total}',
                  }),
                  style: AppTextStyle.caption,
                ),
                const Spacer(),
                if (controller.isLive.value)
                  Text('live'.tr, style: AppTextStyle.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom of the list: a spinner while the next page loads, or the end marker.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.controller});

  final UserController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimen.spaceLg),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        );
      }

      if (!controller.hasMore && controller.users.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimen.spaceLg),
          child: Center(
            child: Text('End of list'.tr, style: AppTextStyle.caption),
          ),
        );
      }

      return const SizedBox(height: AppDimen.spaceLg);
    });
  }
}

/// Green when the event stream is open, grey when it is not.
class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isLive ? 'Live updates connected'.tr : 'Not connected'.tr,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLive ? AppColor.success : AppColor.textDisabled,
        ),
      ),
    );
  }
}
