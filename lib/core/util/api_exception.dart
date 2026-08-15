/// One exception type for every failed call, so controllers catch one thing.
///
/// The backend answers errors with a `BaseError` body:
/// ```json
/// { "detail": "Username already exists", "status": 400, "trackingId": "86a1…" }
/// ```
/// [message] carries that `detail` when present, so the text shown to the user
/// is the server's own wording rather than something invented on the client.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.trackingId});

  /// Safe to show in a snackbar.
  final String message;

  /// HTTP status, or null when the request never reached the server.
  final int? statusCode;

  /// The backend's log-correlation id — quote it when reporting a bug.
  final String? trackingId;

  /// The session is gone; the app should route back to login.
  bool get isUnauthorized => statusCode == 401;

  /// The server rejected the input — show it on the form, do not retry.
  bool get isValidation => statusCode == 400;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
