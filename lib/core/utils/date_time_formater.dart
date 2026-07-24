import 'package:intl/intl.dart';

class DateTimeFormatter {
  static String chatTime(String dateTime) {
    try {
      final DateTime messageTime = DateTime.parse(dateTime);
      final DateTime now = DateTime.now();

      final Duration difference = now.difference(messageTime);

      // Today
      if (messageTime.year == now.year &&
          messageTime.month == now.month &&
          messageTime.day == now.day) {
        return DateFormat('h:mm a').format(messageTime);
      }

      // Yesterday
      final DateTime yesterday = now.subtract(const Duration(days: 1));

      if (messageTime.year == yesterday.year &&
          messageTime.month == yesterday.month &&
          messageTime.day == yesterday.day) {
        return "Yesterday";
      }

      // Less than 7 days
      if (difference.inDays < 7) {
        return DateFormat('EEEE').format(messageTime); // Friday
      }

      // Less than 30 days
      if (difference.inDays < 30) {
        return "${difference.inDays} weeks ago";
      }

      // Less than 1 year
      if (difference.inDays < 365) {
        return DateFormat('MMMM d').format(messageTime);
        // June 10
      }

      // Older than 1 year
      return DateFormat('MMM d, yyyy').format(messageTime);
      // Jun 10, 2026
    } catch (e) {
      return "";
    }
  }
}
