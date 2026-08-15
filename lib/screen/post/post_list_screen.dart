import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/post_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../data/model/post_model.dart';
import '../../util/formatter.dart';
import '../../widget/state_view.dart';

/// Posts tab — the same paginated, searchable, live-updating shape as the
/// users list, so the two read identically.
class PostListScreen extends GetView<PostController> {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts'.tr)),
      floatingActionButton: FloatingActionButton.extended(
        // Unique tag: IndexedStack keeps every tab alive, so both FABs
        // exist at once and would otherwise share the default Hero tag.
        heroTag: 'post-fab',
        onPressed: controller.openCreate,
        icon: const Icon(Icons.add),
        label: Text('New post'.tr),
      ),
      body: Column(
        children: <Widget>[
          _SearchBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingView();

              if (controller.errorMessage.isNotEmpty) {
                return ErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.loadFirstPage,
                );
              }

              if (controller.posts.isEmpty) {
                return EmptyView(
                  message: controller.searchTerm.isEmpty
                      ? 'No posts yet'.tr
                      : 'No user matches "@term"'.trParams(<String, String>{
                          'term': controller.searchTerm.value,
                        }),
                  icon: Icons.article_outlined,
                  actionLabel: controller.searchTerm.isEmpty
                      ? null
                      : 'Clear search'.tr,
                  onAction: controller.clearSearch,
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
                    // Room so the FAB never covers the last row.
                    AppDimen.spaceXl * 2.5,
                  ),
                  itemCount: controller.posts.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == controller.posts.length) {
                      return _Footer(controller: controller);
                    }
                    return _PostTile(post: controller.posts[index]);
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final PostController controller;

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
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by title'.tr,
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
            () => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '@shown of @total shown'.trParams(<String, String>{
                  'shown': '${controller.posts.length}',
                  'total': '${controller.total}',
                }),
                style: AppTextStyle.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One post row: image, title, byline, and a delete action.
class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    final String? url = post.fullImageUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimen.spaceSm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimen.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimen.radiusSm),
              child: SizedBox(
                width: 64,
                height: 64,
                child: url != null
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: AppColor.primaryLight,
                          child: Icon(Icons.article_outlined),
                        ),
                      )
                    : const ColoredBox(
                        color: AppColor.primaryLight,
                        child: Icon(
                          Icons.article_outlined,
                          color: AppColor.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppDimen.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          post.title,
                          style: AppTextStyle.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!post.published) ...<Widget>[
                        const SizedBox(width: AppDimen.spaceSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.dangerLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Draft'.tr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColor.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (post.content != null &&
                      post.content!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      post.content!,
                      style: AppTextStyle.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${post.author?.displayName ?? ''} · ${Formatter.relative(post.createdAt)}',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _PostMenu(post: post),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});

  final PostController controller;

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
      if (!controller.hasMore && controller.posts.isNotEmpty) {
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

/// Edit / publish / delete, the same menu shape the user rows use.
///
/// Every action goes through the controller, so the tile itself stays free of
/// business logic.
class _PostMenu extends StatelessWidget {
  const _PostMenu({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.find<PostController>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColor.textSecondary),
      onSelected: (String value) {
        switch (value) {
          case 'edit':
            controller.openEdit(post);
            break;
          case 'publish':
            controller.togglePublished(post);
            break;
          case 'delete':
            controller.confirmDelete(post);
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
          value: 'publish',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              post.published
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            title: Text(post.published ? 'Unpublish'.tr : 'Publish'.tr),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline, color: AppColor.danger),
            title: Text(
              'Delete'.tr,
              style: const TextStyle(color: AppColor.danger),
            ),
          ),
        ),
      ],
    );
  }
}
