import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_constant.dart';
import '../core/util/api_exception.dart';
import '../data/model/response/page_response.dart';
import '../data/model/post_model.dart';
import '../data/model/response/sse_event.dart';
import '../data/service/post_service.dart';
import '../data/service/sse_service.dart';
import '../route/app_route.dart';
import '../util/ui_util.dart';

/// The posts tab: paginated infinite scroll, search, and live updates.
///
/// Deliberately the same shape as [UserController] — once you have read one of
/// these, the other holds no surprises.
class PostController extends GetxController {
  final PostService _postService = Get.find<PostService>();
  final SseService _sseService = Get.find<SseService>();

  final posts = <PostModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final searchTerm = ''.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchC = TextEditingController();

  int _page = 0;
  int _totalPages = 1;
  int _total = 0;

  StreamSubscription<SseEvent>? _sseSub;

  int get total => _total;

  bool get hasMore => _page + 1 < _totalPages;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    debounce<String>(
      searchTerm,
      (_) => refreshList(),
      time: const Duration(milliseconds: 400),
    );
    _listenToSse();
    loadFirstPage();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchC.dispose();
    _sseSub?.cancel();
    super.onClose();
  }

  Future<void> loadFirstPage() async {
    isLoading.value = true;
    errorMessage.value = '';
    _page = 0;

    final result = await _postService.getPage(
      page: 0,
      size: AppConstant.pageSize,
      title: searchTerm.value.trim(),
    );
    isLoading.value = false;

    result.fold(
      (ApiException e) {
        errorMessage.value = e.message;
        posts.clear();
      },
      (PageResponse<PostModel> page) {
        posts.assignAll(page.items);
        _applyMeta(page);
      },
    );
  }

  Future<void> refreshList() async {
    _page = 0;
    final result = await _postService.getPage(
      page: 0,
      size: AppConstant.pageSize,
      title: searchTerm.value.trim(),
    );
    result.fold((ApiException e) => UiUtil.error(e.message), (
      PageResponse<PostModel> page,
    ) {
      posts.assignAll(page.items);
      _applyMeta(page);
    });
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMore) return;

    isLoadingMore.value = true;
    final result = await _postService.getPage(
      page: _page + 1,
      size: AppConstant.pageSize,
      title: searchTerm.value.trim(),
    );
    isLoadingMore.value = false;

    result.fold((ApiException e) => UiUtil.error(e.message), (
      PageResponse<PostModel> page,
    ) {
      posts.addAll(page.items);
      _applyMeta(page);
    });
  }

  void _applyMeta(PageResponse<PostModel> page) {
    _page = page.page;
    _totalPages = page.totalPages;
    _total = page.total;
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final double remaining =
        scrollController.position.maxScrollExtent -
        scrollController.position.pixels;
    if (remaining <= AppConstant.loadMoreThreshold) loadMore();
  }

  void onSearchChanged(String value) => searchTerm.value = value;

  void clearSearch() {
    searchC.clear();
    searchTerm.value = '';
  }

  /// Only the author may delete — the backend answers 400 for anyone else, and
  /// that message is what the snackbar shows.
  Future<void> confirmDelete(PostModel post) async {
    final bool ok = await UiUtil.confirm(
      title: 'Delete post'.tr,
      message: '@name will be removed from the list'.trParams(<String, String>{
        'name': post.title,
      }),
      confirmText: 'Delete'.tr,
      destructive: true,
    );
    if (!ok) return;

    final result = await _postService.delete(post.id);
    result.fold((ApiException e) => UiUtil.error(e.message), (_) {
      posts.removeWhere((PostModel p) => p.id == post.id);
      _total = _total > 0 ? _total - 1 : 0;
      UiUtil.success(
        '@name deleted'.trParams(<String, String>{'name': post.title}),
      );
    });
  }

  void openCreate() => Get.toNamed(AppRoute.postForm);

  void openEdit(PostModel post) =>
      Get.toNamed(AppRoute.postForm, arguments: post);

  /// Publish / unpublish without opening the form. Sends only `published`,
  /// which the backend treats as a patch and leaves the text untouched.
  Future<void> togglePublished(PostModel post) async {
    final result = await _postService.update(
      post.id,
      published: !post.published,
    );

    result.fold((ApiException e) => UiUtil.error(e.message), (
      PostModel updated,
    ) {
      final int i = posts.indexWhere((PostModel p) => p.id == updated.id);
      if (i >= 0) posts[i] = updated;
      UiUtil.success(updated.published ? 'Published'.tr : 'Kept as a draft'.tr);
    });
  }

  void _listenToSse() {
    _sseSub = _sseService.events.listen((SseEvent event) {
      if (event.name == 'post-event') refreshList();
    });
  }
}
