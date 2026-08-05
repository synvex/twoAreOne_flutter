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
      return DateFormat('h:mm a').format(dt);
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays > 1 && diffDays < 7) {
      return DateFormat('EEEE').format(dt);
    } else if (dt.year == now.year) {
      return DateFormat('MMM d').format(dt);
    } else {
      return DateFormat('MMM d, yyyy').format(dt);
    }
  }

  /// Input: 2026-07-30 11:08:00
  static String formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return _smartFormat(dt);
    } catch (e) {
      return dateTime;
    }
  }

  /// Input: UTC time -> 2026-07-30 11:08:00
  static String utcToPkTime(String utcTime) {
    try {
      final utcDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(utcTime);
      final localTime = utcDateTime.toLocal();
      return _smartFormat(localTime);
    } catch (e) {
      return utcTime;
    }
  }

  /// Input: Unix timestamp (seconds or milliseconds)
  /// Examples:
  /// 1785232339      -> seconds
  /// 1785232339000   -> milliseconds
  static String unixToLocalTime(int unixTimestamp) {
    try {
      // Detect seconds vs milliseconds
      if (unixTimestamp.toString().length == 10) {
        unixTimestamp *= 1000;
      }

      final localTime = DateTime.fromMillisecondsSinceEpoch(
        unixTimestamp,
      ).toLocal();

      return _smartFormat(localTime);
    } catch (e) {
      return unixTimestamp.toString();
    }
  }
}
