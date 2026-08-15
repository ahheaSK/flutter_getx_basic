import '../user_model.dart';

/// What the server does to a user, as sent on the `user-event` stream.
enum SseAction { created, updated, deleted, imageUploaded, unknown }

/// One decoded frame from `GET /api/sse/subscribe`.
///
/// The backend writes:
/// ```
/// event:user-event
/// data:{"action":"CREATED","user":{…},"timestamp":"…"}
/// ```
class SseEvent {
  SseEvent({
    required this.name,
    required this.action,
    this.user,
    this.userId,
    this.raw = const <String, dynamic>{},
  });

  /// The SSE event name: `connected`, `user-event`, or `message`.
  final String name;

  final SseAction action;

  /// Present for CREATED / UPDATED / IMAGE_UPLOADED.
  final UserModel? user;

  /// DELETED sends only `{ id, username }`, so the full model is not available.
  final int? userId;

  final Map<String, dynamic> raw;

  factory SseEvent.fromJson(String name, Map<String, dynamic> json) {
    final SseAction action = _actionOf(json['action'] as String?);
    final Object? userJson = json['user'];

    UserModel? user;
    int? userId;

    if (userJson is Map<String, dynamic>) {
      userId = userJson['id'] as int?;
      // A delete payload carries only id + username, so building a full model
      // would invent defaults for fields the server never sent.
      if (action != SseAction.deleted) {
        user = UserModel.fromJson(userJson);
      }
    }

    return SseEvent(
      name: name,
      action: action,
      user: user,
      userId: userId,
      raw: json,
    );
  }

  static SseAction _actionOf(String? value) {
    switch (value) {
      case 'CREATED':
        return SseAction.created;
      case 'UPDATED':
        return SseAction.updated;
      case 'DELETED':
        return SseAction.deleted;
      case 'IMAGE_UPLOADED':
        return SseAction.imageUploaded;
      default:
        return SseAction.unknown;
    }
  }

  /// True for the frames that should make a list refresh itself.
  bool get isUserChange => name == 'user-event' && action != SseAction.unknown;

  /// Short sentence for the snackbar shown when an event arrives.
  String get label {
    final String who = user?.displayName ?? 'A user';
    switch (action) {
      case SseAction.created:
        return '$who was created';
      case SseAction.updated:
        return '$who was updated';
      case SseAction.deleted:
        return 'A user was deleted';
      case SseAction.imageUploaded:
        return '$who changed their photo';
      case SseAction.unknown:
        return 'Users changed';
    }
  }
}
