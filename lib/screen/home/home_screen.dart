import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import '../../core/value/app_color.dart';
import '../../core/value/app_dimen.dart';
import '../../core/value/app_text_style.dart';
import '../../data/model/post_model.dart';
import '../../data/model/slider_model.dart';
import '../../util/formatter.dart';
import '../../widget/app_drawer.dart';
import '../../widget/state_view.dart';

/// Home tab: the banner carousel on top, the newest posts underneath.
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text('Home'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();

        // Only a hard failure with nothing to show blanks the screen.
        if (controller.errorMessage.isNotEmpty &&
            controller.banners.isEmpty &&
            controller.latestPosts.isEmpty) {
          return ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.loadAll,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAll,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppDimen.spaceXl),
            children: <Widget>[
              const _Carousel(),
              const SizedBox(height: AppDimen.spaceLg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimen.spaceMd,
                ),
                child: Text('Latest posts'.tr, style: AppTextStyle.heading),
              ),
              const SizedBox(height: AppDimen.spaceSm),
              ...controller.latestPosts.map(
                (PostModel p) => _LatestPostTile(post: p),
              ),
              if (controller.latestPosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppDimen.spaceXl),
                  child: Text(
                    'No posts yet'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.caption,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

/// The banner carousel, driven by `carousel_slider`.
class _Carousel extends StatelessWidget {
  const _Carousel();

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final List<SliderModel> banners = controller.banners;
      if (banners.isEmpty) return const SizedBox.shrink();

      return Column(
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              height: 190,
              viewportFraction: 0.88,
              autoPlay: banners.length > 1, // pointless with a single banner
              autoPlayInterval: const Duration(seconds: 4),
              enlargeCenterPage: true,
              // Feeds the dot indicator below.
              onPageChanged: (int index, CarouselPageChangedReason _) =>
                  controller.onCarouselChanged(index),
            ),
            items: banners.map((SliderModel b) => _Banner(banner: b)).toList(),
          ),
          const SizedBox(height: AppDimen.spaceSm),
          // Dots: filled for the visible banner.
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(banners.length, (int i) {
                final bool active = controller.carouselIndex.value == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? AppColor.primary : AppColor.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }
}

/// One banner: image with a readable caption over the bottom.
class _Banner extends StatelessWidget {
  const _Banner({required this.banner});

  final SliderModel banner;

  @override
  Widget build(BuildContext context) {
    final String? url = banner.fullImageUrl;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.spaceXs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimen.radiusLg),
        color: AppColor.primaryLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (url != null)
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.image_not_supported_outlined, size: 40),
            ),
          // Dark gradient so white text stays readable on any image.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Positioned(
            left: AppDimen.spaceMd,
            right: AppDimen.spaceMd,
            bottom: AppDimen.spaceMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (banner.subtitle != null && banner.subtitle!.isNotEmpty)
                  Text(
                    banner.subtitle!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact post row for the home tab.
class _LatestPostTile extends StatelessWidget {
  const _LatestPostTile({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    final String? url = post.fullImageUrl;

    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppDimen.spaceMd,
        0,
        AppDimen.spaceMd,
        AppDimen.spaceSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimen.spaceSm),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimen.radiusSm),
              child: SizedBox(
                width: 56,
                height: 56,
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
                  Text(
                    post.title,
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${post.author?.displayName ?? ''} · ${Formatter.relative(post.createdAt)}',
                    style: AppTextStyle.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
