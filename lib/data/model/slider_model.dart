import '../../constant/api_constant.dart';

/// Mirrors the backend's `SliderResponse` — one banner in the carousel.
class SliderModel {
  SliderModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageName,
    this.imageUrl,
    this.linkUrl,
    this.sortOrder = 0,
    this.active = true,
  });

  final int id;
  final String title;
  final String? subtitle;
  final String? imageName;

  /// Server-relative path; use [fullImageUrl] to display it.
  final String? imageUrl;

  /// Where tapping should lead; null means the banner is not tappable.
  final String? linkUrl;

  /// Lower shows first. The server already returns them in order.
  final int sortOrder;
  final bool active;

  String? get fullImageUrl {
    final String? path = imageUrl;
    if (path == null || path.isEmpty) return null;
    return ApiConstant.fileUrl(path);
  }

  factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String?,
    imageName: json['imageName'] as String?,
    imageUrl: json['imageUrl'] as String?,
    linkUrl: json['linkUrl'] as String?,
    sortOrder: json['sortOrder'] as int? ?? 0,
    active: json['active'] as bool? ?? true,
  );
}
