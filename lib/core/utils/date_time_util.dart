import 'package:intl/intl.dart';

class DateTimeUtil {
  /// Shared logic: given a DateTime (already in the correct/local timezone),
  /// return a smart relative label.
  static String _smartFormat(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dt.year, dt.month, dt.day);

    final diffDays = today.difference(messageDay).inDays;

    if (diffDays == 0) {
      // Today -> just show time
      return DateFormat('h:mm a').format(dt);
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays > 1 && diffDays < 7) {
      // Within the last week -> weekday name
      return DateFormat('EEEE').format(dt); // e.g. Monday
    } else if (dt.year == now.year) {
      // Same year, older than a week -> "Jul 15"
      return DateFormat('MMM d').format(dt);
    } else {
      // Different year -> "Jul 15, 2025"
      return DateFormat('MMM d, yyyy').format(dt);
    }
  }

  /// Input: 2026-07-30 11:08:00
  /// Output: 11:08 AM / Yesterday / Monday / Jul 15 / Jul 15, 2025
  /// Only formats the time, does NOT convert timezone.
  static String formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return _smartFormat(dt);
    } catch (e) {
      return dateTime;
    }
  }

  /// Input: UTC time -> 2026-07-30 11:08:00
  /// Output (Pakistan): 4:08 PM / Yesterday / Monday / Jul 15 / Jul 15, 2025
  static String utcToPkTime(String utcTime) {
    try {
      final utcDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(utcTime);
      final pkTime = utcDateTime.toLocal();
      return _smartFormat(pkTime);
    } catch (e) {
      return utcTime;
    }
  }
}
