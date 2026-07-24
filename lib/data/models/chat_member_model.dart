class ChatMemberModel {
  final int? userId;
  final String? fullName;
  final String? profilePicture;
  final int? lastLogin;
  final bool? isOnline;
  final String? lastMessage;
  final String? lastMessageTime;
  final int? unreadCount;
  final bool? isBlockedByMe;
  final bool? blockedMe;

  ChatMemberModel({
    this.userId,
    this.fullName,
    this.profilePicture,
    this.lastLogin,
    this.isOnline,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
    this.isBlockedByMe,
    this.blockedMe,
  });

  factory ChatMemberModel.fromJson(Map<String, dynamic> json) {
    return ChatMemberModel(
      userId: json['user_id'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      lastLogin: json['last_login'],
      isOnline: json['is_online'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'],
      isBlockedByMe: json['is_blocked_by_me'],
      blockedMe: json['blocked_me'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'last_login': lastLogin,
      'is_online': isOnline,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'is_blocked_by_me': isBlockedByMe,
      'blocked_me': blockedMe,
    };
  }
}
