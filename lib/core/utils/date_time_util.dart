import 'package:intl/intl.dart';

class DateTimeUtil {
  /// Input: 2026-07-30 11:08:00
  /// Output: 11:08 AM
  /// Only formats the time, does NOT convert timezone.
  static String formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  /// Input: UTC time -> 2026-07-30 11:08:00
  /// Output (Pakistan): 4:08 PM
  static String utcToPkTime(String utcTime) {
    try {
      final utcDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(utcTime);

      final pkTime = utcDateTime.toLocal();

      return DateFormat("h:mm a").format(pkTime);
    } catch (e) {
      return utcTime;
    }
  }
}
