import '../user_model.dart';

/// Mirrors the backend's `AuthResponse` — what login and register both return.
class AuthResponse {
  AuthResponse({required this.token, required this.type, required this.user});

  /// The JWT. Sent back as `Authorization: Bearer <token>`.
  final String token;

  /// Always `"Bearer"`.
  final String type;

  final UserModel user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] as String? ?? '',
    type: json['type'] as String? ?? 'Bearer',
    user: UserModel.fromJson(
      (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    ),
  );
}
