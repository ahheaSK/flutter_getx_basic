import 'package:flutter/foundation.dart';

/// Tiny logging helper.
///
/// `debugPrint` instead of `print`: it throttles output so Android does not drop
/// long lines, and `kDebugMode` keeps all of it out of a release build.
class Logger {
  const Logger._();

  static void d(String tag, Object? message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  static void e(String tag, Object? message, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$tag] ERROR: $message');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}
