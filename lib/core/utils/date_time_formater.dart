// import 'package:intl/intl.dart';

// class DateTimeFormatter {
//   /// Chat format
//   static String chatTime(String dateTime) {
//     try {
//       final DateTime messageTime = DateTime.parse(dateTime);
//       final DateTime now = DateTime.now();

//       final Duration difference = now.difference(messageTime);

//       // Today
//       if (messageTime.year == now.year &&
//           messageTime.month == now.month &&
//           messageTime.day == now.day) {
//         return DateFormat('h:mm a').format(messageTime);
//       }

//       // Yesterday
//       final DateTime yesterday = now.subtract(const Duration(days: 1));

//       if (messageTime.year == yesterday.year &&
//           messageTime.month == yesterday.month &&
//           messageTime.day == yesterday.day) {
//         return "Yesterday";
//       }

//       // Less than 7 days
//       if (difference.inDays < 7) {
//         return DateFormat('EEEE').format(messageTime);
//       }

//       // Less than 30 days
//       if (difference.inDays < 30) {
//         return "${difference.inDays ~/ 7} week${difference.inDays ~/ 7 > 1 ? 's' : ''} ago";
//       }

//       // Less than 1 year
//       if (difference.inDays < 365) {
//         return DateFormat('MMMM d').format(messageTime);
//       }

//       // Older than 1 year
//       return DateFormat('MMM d, yyyy').format(messageTime);
//     } catch (e) {
//       return "";
//     }
//   }

//   /// Returns only the date
//   /// Example: Jul 27, 2026
//   static String onlyDate(String dateTime) {
//     try {
//       final DateTime date = DateTime.parse(dateTime);
//       return DateFormat('MMM d, yyyy').format(date);
//     } catch (e) {
//       return "";
//     }
//   }

//   /// Returns only the time
//   /// Example: 9:23 AM
//   static String onlyTime(String dateTime) {
//     try {
//       final DateTime date = DateTime.parse(dateTime);
//       return DateFormat('h:mm a').format(date);
//     } catch (e) {
//       return "";
//     }
//   }
// }
