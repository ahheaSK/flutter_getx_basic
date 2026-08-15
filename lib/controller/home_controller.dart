import 'dart:async';

import 'package:get/get.dart';

import '../core/util/api_exception.dart';
import '../data/model/response/page_response.dart';
import '../data/model/post_model.dart';
import '../data/model/slider_model.dart';
import '../data/model/response/sse_event.dart';
import '../data/service/post_service.dart';
import '../data/service/slider_service.dart';
import '../data/service/sse_service.dart';

/// The home tab: the banner carousel plus the newest handful of posts.
class HomeController extends GetxController {
  final SliderService _sliderService = Get.find<SliderService>();
  final PostService _postService = Get.find<PostService>();
  final SseService _sseService = Get.find<SseService>();

  final banners = <SliderModel>[].obs;
  final latestPosts = <PostModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Which dot under the carousel is filled.
  final carouselIndex = 0.obs;

  StreamSubscription<SseEvent>? _sseSub;

  @override
  void onInit() {
    super.onInit();
    // The carousel and the posts are independent, so a failure in one must not
    // blank the other — see loadAll.
    loadAll();
    _listenToSse();
  }

  @override
  void onClose() {
    _sseSub?.cancel();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';

    // Both requests are STARTED here, before either is awaited, so they run
    // concurrently and cost one round-trip of time rather than two.
    final bannersCall = _sliderService.getCarousel();
    final postsCall = _postService.getPage(size: 5, published: true);

    final bannersResult = await bannersCall;
    final postsResult = await postsCall;

    // A failure in one must not blank the other, so they fold independently.
    bannersResult.fold(
      (ApiException e) => errorMessage.value = e.message,
      banners.assignAll,
    );

    postsResult.fold(
      (ApiException e) => errorMessage.value = e.message,
      (PageResponse<PostModel> page) => latestPosts.assignAll(page.items),
    );

    isLoading.value = false;
  }

  void onCarouselChanged(int index) => carouselIndex.value = index;

  /// Any post or banner change on the server refreshes this screen.
  void _listenToSse() {
    _sseSub = _sseService.events.listen((SseEvent event) {
      if (event.name == 'post-event' || event.name == 'slider-event') {
        loadAll();
      }
    });
  }
}
