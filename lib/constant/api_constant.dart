import 'dart:io';

import 'package:flutter/foundation.dart';

/// Every URL the app talks to, in one place.
///
/// Mirrors the Spring Boot project `project-spring-boot-user-image-sse`,
/// which serves on port 8910.
class ApiConstant {
  const ApiConstant._();

  /// Port the backend listens on (`SERVER_PORT` in its `.env`).
  static const String _port = '8910';

  /// Override at build time without touching the code:
  ///
  /// ```bash
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8910
  /// ```
  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Where the backend lives, resolved per platform.
  ///
  /// `localhost` means something different on every target:
  /// * Android emulator — the emulator itself, so the host machine is `10.0.2.2`
  /// * iOS simulator — shares the Mac's network, so `localhost` is correct
  /// * real device — neither works; pass your machine's LAN IP via `API_BASE_URL`
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:$_port';
    return 'http://localhost:$_port';
  }

  // --- Auth (public) ---
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';

  // --- Users (Bearer token required) ---
  static const String users = '/api/users';
  static const String currentUser = '/api/users/me';

  static String userById(int id) => '/api/users/$id';

  static String userEnabled(int id) => '/api/users/$id/enabled';

  static String userImage(int id) => '/api/users/$id/image';

  // --- Posts (Bearer token required) ---
  static const String posts = '/api/posts';

  static String postById(int id) => '/api/posts/$id';

  static String postImage(int id) => '/api/posts/$id/image';

  // --- Sliders ---
  /// Public: the active carousel, in display order.
  static const String sliders = '/api/sliders';

  /// Protected: every banner including hidden ones.
  static const String slidersManage = '/api/sliders/manage';

  // --- Files (public GET) ---
  /// The backend returns `imageUrl` as a path such as `/api/files/3-a1b2.png`,
  /// so it has to be joined with [baseUrl] before an `Image.network` can load it.
  static String fileUrl(String imagePath) => '$baseUrl$imagePath';

  // --- SSE ---
  /// `EventSource` cannot send headers, so the backend also accepts the token
  /// as a query parameter on this route.
  static String sseSubscribe(String token) =>
      '$baseUrl/api/sse/subscribe?access_token=$token';
}
