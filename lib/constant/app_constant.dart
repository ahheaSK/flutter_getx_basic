/// App-wide values that are not URLs and not design tokens.
///
/// Design tokens (colours, spacing, text styles) live in `core/value/`.
class AppConstant {
  const AppConstant._();

  // The app name is not here: it is user-facing text, so it lives in
  // util/languages.dart and is read with `'GetX Basic'.tr`.

  // --- Keys used by SharedPreferences (see core/util/token_storage.dart) ---
  static const String keyToken = 'auth_token';
  static const String keyUsername = 'auth_username';

  // --- Pagination -----------------------------------------------------------
  /// Rows per page. The backend caps `size` at 100 and defaults to 20.
  static const int pageSize = 10;

  /// Load the next page once the list is scrolled this close to the bottom.
  static const double loadMoreThreshold = 200;

  // --- Networking ---
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// How long to wait before re-opening a dropped SSE stream.
  static const Duration sseRetryDelay = Duration(seconds: 5);

  // --- Validation (kept in step with the backend's UserValidator) ---
  static const int passwordMinLength = 8;
  static const int usernameMaxLength = 100;
}
