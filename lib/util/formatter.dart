import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Date and text formatting shared by the screens.
class Formatter {
  const Formatter._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy · HH:mm');

  static String date(DateTime? value) =>
      value == null ? 'N/A'.tr : _date.format(value);

  static String dateTime(DateTime? value) =>
      value == null ? 'N/A'.tr : _dateTime.format(value);

  /// "just now" / "5m ago" / "3d ago", falling back to a date after a week.
  static String relative(DateTime? value) {
    if (value == null) return 'N/A'.tr;
    final Duration diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'just now'.tr;
    if (diff.inHours < 1) {
      return '@n minutes ago'.trParams(<String, String>{
        'n': '${diff.inMinutes}',
      });
    }
    if (diff.inDays < 1) {
      return '@n hours ago'.trParams(<String, String>{'n': '${diff.inHours}'});
    }
    if (diff.inDays < 7) {
      return '@n days ago'.trParams(<String, String>{'n': '${diff.inDays}'});
    }
    return date(value);
  }
}
