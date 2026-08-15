import '../../constant/api_constant.dart';

/// Mirrors the backend's `UserResponse`.
///
/// The password hash is deliberately absent there, so it cannot appear here.
class UserModel {
  UserModel({
    required this.id,
    required this.username,
    this.nickName,
    this.enabled = true,
    this.imageName,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int id;

  /// Login identity — an email, stored lowercased by the backend.
  final String username;

  /// Display name; the backend generates one when the client sends none.
  final String? nickName;

  final bool enabled;

  /// Stored file name, e.g. `3-a1b2c3.png`. Null when no image was uploaded.
  final String? imageName;

  /// Server-relative path, e.g. `/api/files/3-a1b2c3.png`.
  /// Use [fullImageUrl] to display it.
  final String? imageUrl;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Absolute URL for `Image.network`, or null when there is no image.
  ///
  /// The backend returns a path rather than a full URL, so the host has to be
  /// added on the client — which is what lets the same response work from an
  /// emulator, a simulator, and a real device.
  String? get fullImageUrl {
    final String? path = imageUrl;
    if (path == null || path.isEmpty) return null;
    return ApiConstant.fileUrl(path);
  }

  /// What to show when there is no nickname.
  String get displayName {
    final String? nick = nickName;
    if (nick != null && nick.trim().isNotEmpty) return nick;
    return username;
  }

  /// One or two letters for the avatar placeholder.
  ///
  /// `Study Buddy` → `SB`, `admin@example.com` → `AD`. The domain is dropped
  /// first: splitting the whole address would turn `admin@example.com` into
  /// `AE`, which says nothing about the person.
  String get initials {
    String source = displayName.trim();
    if (source.isEmpty) return '?';

    final int at = source.indexOf('@');
    if (at > 0) source = source.substring(0, at);

    final List<String> parts = source
        .split(RegExp(r'[\s._-]+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';

    // Two words → one letter from each.
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    // One word → its first two letters.
    final String only = parts.first;
    return (only.length >= 2 ? only.substring(0, 2) : only).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int? ?? 0,
    username: json['username'] as String? ?? '',
    nickName: json['nickName'] as String?,
    enabled: json['enabled'] as bool? ?? true,
    imageName: json['imageName'] as String?,
    imageUrl: json['imageUrl'] as String?,
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
  );

  /// Timestamps arrive as ISO-8601 UTC strings; a null or malformed value
  /// should not take the whole list down.
  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
