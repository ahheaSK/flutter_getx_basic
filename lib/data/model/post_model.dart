import '../../constant/api_constant.dart';

/// Mirrors the backend's `PostResponse`.
///
/// The author arrives embedded rather than as a bare id, so a list row can be
/// rendered without a second request per post.
class PostModel {
  PostModel({
    required this.id,
    required this.title,
    this.content,
    this.imageName,
    this.imageUrl,
    this.published = true,
    this.author,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? content;
  final String? imageName;
  final String? imageUrl;
  final bool published;
  final PostAuthor? author;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get fullImageUrl {
    final String? path = imageUrl;
    if (path == null || path.isEmpty) return null;
    return ApiConstant.fileUrl(path);
  }

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    content: json['content'] as String?,
    imageName: json['imageName'] as String?,
    imageUrl: json['imageUrl'] as String?,
    published: json['published'] as bool? ?? true,
    author: json['author'] is Map<String, dynamic>
        ? PostAuthor.fromJson(json['author'] as Map<String, dynamic>)
        : null,
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  static DateTime? _date(Object? v) {
    if (v is! String || v.isEmpty) return null;
    return DateTime.tryParse(v)?.toLocal();
  }
}

/// The compact byline block the backend embeds in every post.
class PostAuthor {
  PostAuthor({
    required this.id,
    required this.username,
    this.nickName,
    this.imageUrl,
  });

  final int id;
  final String username;
  final String? nickName;
  final String? imageUrl;

  String get displayName =>
      (nickName != null && nickName!.trim().isNotEmpty) ? nickName! : username;

  String? get fullImageUrl {
    final String? path = imageUrl;
    if (path == null || path.isEmpty) return null;
    return ApiConstant.fileUrl(path);
  }

  factory PostAuthor.fromJson(Map<String, dynamic> json) => PostAuthor(
    id: json['id'] as int? ?? 0,
    username: json['username'] as String? ?? '',
    nickName: json['nickName'] as String?,
    imageUrl: json['imageUrl'] as String?,
  );
}
