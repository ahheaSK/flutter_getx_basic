import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_constant.dart';
import '../core/util/api_exception.dart';
import '../data/model/response/page_response.dart';
import '../data/model/response/sse_event.dart';
import '../data/model/user_model.dart';
import '../data/model/request/user_request.dart';
import '../data/service/auth_service.dart';
import '../data/service/sse_service.dart';
import '../data/service/user_service.dart';
import '../route/app_route.dart';
import '../util/ui_util.dart';

/// The user list: paging, search, delete, and the live SSE refresh.
class UserController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final AuthService _authService = Get.find<AuthService>();
  final SseService _sseService = Get.find<SseService>();

  // --- State ----------------------------------------------------------------
  /// The rows collected so far. Pages are appended, not replaced.
  final users = <UserModel>[].obs;

  /// First load / refresh — the whole list is replaced by a spinner.
  final isLoading = false.obs;

  /// Appending the next page — only the footer shows a spinner.
  final isLoadingMore = false.obs;

  /// Non-empty when the first load failed, so the screen can offer Retry.
  final errorMessage = ''.obs;

  /// Whether the SSE stream is currently open (drives the "live" dot).
  final isLive = false.obs;

  final searchTerm = ''.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchC = TextEditingController();

  int _page = 0;
  int _totalPages = 1;
  int _total = 0;

  StreamSubscription<SseEvent>? _sseSub;

  int get total => _total;

  String get currentUsername => _authService.currentUsername ?? '';

  bool get hasMore => _page + 1 < _totalPages;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_onScroll);

    // Wait for typing to stop before hitting the API. Without this, every
    // keystroke would fire its own request and the answers could arrive
    // out of order.
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

  // --- Loading --------------------------------------------------------------

  /// First page: clears what is there and shows the full-screen spinner.
  Future<void> loadFirstPage() async {
    isLoading.value = true;
    errorMessage.value = '';
    _page = 0;

    final result = await _userService.getPage(_filter(0));
    isLoading.value = false;

    result.fold(
      (ApiException error) {
        // Full-screen error only on the FIRST load — there is no list to keep.
        errorMessage.value = error.message;
        users.clear();
      },
      (PageResponse<UserModel> page) {
        users.assignAll(page.items);
        _applyMeta(page);
      },
    );
  }

  /// Pull-to-refresh: same request, but no full-screen spinner so the list
  /// stays visible under the refresh indicator.
  Future<void> refreshList() async {
    errorMessage.value = '';
    _page = 0;

    final result = await _userService.getPage(_filter(0));

    result.fold(
      // A snackbar, not the error view: the list on screen is still valid.
      (ApiException error) => UiUtil.error(error.message),
      (PageResponse<UserModel> page) {
        users.assignAll(page.items);
        _applyMeta(page);
      },
    );
  }

  /// Appends the next page. Guarded so a fast scroll cannot fire it twice.
  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMore) return;

    isLoadingMore.value = true;

    final result = await _userService.getPage(_filter(_page + 1));
    isLoadingMore.value = false;

    result.fold((ApiException error) => UiUtil.error(error.message), (
      PageResponse<UserModel> page,
    ) {
      users.addAll(page.items);
      _applyMeta(page);
    });
  }

  /// Builds the query for one page. Returning the filter rather than the call
  /// keeps every Either inside the service layer.
  UserFilter _filter(int page) => UserFilter(
    page: page,
    size: AppConstant.pageSize,
    username: searchTerm.value.trim(),
    sortBy: 'createdAt',
    direction: 'desc',
  );

  void _applyMeta(PageResponse<UserModel> page) {
    _page = page.page;
    _totalPages = page.totalPages;
    _total = page.total;
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final double remaining =
        scrollController.position.maxScrollExtent -
        scrollController.position.pixels;
    if (remaining <= AppConstant.loadMoreThreshold) {
      loadMore();
    }
  }

  // --- Search ---------------------------------------------------------------

  void onSearchChanged(String value) => searchTerm.value = value;

  void clearSearch() {
    searchC.clear();
    searchTerm.value = '';
  }

  // --- Actions --------------------------------------------------------------

  Future<void> confirmDelete(UserModel user) async {
    final bool ok = await UiUtil.confirm(
      title: 'Delete user'.tr,
      message: '@name will be removed from the list'.trParams(<String, String>{
        'name': user.displayName,
      }),
      confirmText: 'Delete'.tr,
      destructive: true,
    );
    if (!ok) return;

    final result = await _userService.delete(user.id);

    result.fold((ApiException error) => UiUtil.error(error.message), (_) {
      // Remove locally for an instant response; the SSE frame will also
      // arrive and trigger a refresh, which reconciles anything missed.
      users.removeWhere((UserModel u) => u.id == user.id);
      _total = _total > 0 ? _total - 1 : 0;
      UiUtil.success(
        '@name deleted'.trParams(<String, String>{'name': user.displayName}),
      );
    });
  }

  Future<void> toggleEnabled(UserModel user) async {
    final result = await _userService.setEnabled(user.id, !user.enabled);

    result.fold((ApiException error) => UiUtil.error(error.message), (
      UserModel updated,
    ) {
      _replace(updated);
      UiUtil.success(
        updated.enabled ? 'Account enabled'.tr : 'Account disabled'.tr,
      );
    });
  }

  void openCreate() => Get.toNamed(AppRoute.userForm);

  void openEdit(UserModel user) =>
      Get.toNamed(AppRoute.userForm, arguments: user);

  void openDetail(UserModel user) =>
      Get.toNamed(AppRoute.userDetail, arguments: user);

  Future<void> logout() async {
    final bool ok = await UiUtil.confirm(
      title: 'Logout'.tr,
      message: 'You will need to sign in again.'.tr,
      confirmText: 'Logout'.tr,
    );
    if (!ok) return;

    await _sseService.disconnect();
    await _authService.logout();
    Get.offAllNamed(AppRoute.login);
  }

  /// Swaps one row in place, keeping its position in the list.
  void _replace(UserModel updated) {
    final int index = users.indexWhere((UserModel u) => u.id == updated.id);
    if (index >= 0) users[index] = updated;
  }

  // --- Live updates ---------------------------------------------------------

  /// Every create / update / delete / image upload on the server — from this
  /// device or any other — arrives here as a frame.
  void _listenToSse() {
    _sseSub = _sseService.events.listen((SseEvent event) {
      if (event.name == 'connected') {
        isLive.value = true;
        return;
      }
      if (!event.isUserChange) return;

      switch (event.action) {
        case SseAction.updated:
        case SseAction.imageUploaded:
          // An in-place swap avoids re-fetching the whole page and keeps the
          // user's scroll position exactly where it was.
          final UserModel? user = event.user;
          if (user != null) _replace(user);
          break;
        case SseAction.created:
        case SseAction.deleted:
          // These change which rows belong on which page, so the page
          // boundaries have to be recalculated by the server.
          refreshList();
          break;
        case SseAction.unknown:
          break;
      }
    });
  }
}
