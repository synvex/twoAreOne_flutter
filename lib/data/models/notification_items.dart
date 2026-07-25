class NotificationItem {
  final String avatarUrl;
  final String username;
  final String action;
  final String date;
  final String timeAgo;
  final bool isOnline;
  final bool showActions;

  const NotificationItem({
    required this.avatarUrl,
    required this.username,
    required this.action,
    required this.date,
    required this.timeAgo,
    this.isOnline = false,
    this.showActions = false,
  });
}
